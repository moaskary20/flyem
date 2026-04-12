<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PayPalService
{
    public function isReady(): bool
    {
        if (Setting::where('key', 'paypal_enabled')->first()?->value !== '1') {
            return false;
        }
        $id = trim((string) (Setting::where('key', 'paypal_client_id')->first()?->value ?? ''));
        $secret = trim((string) (Setting::where('key', 'paypal_client_secret')->first()?->value ?? ''));

        return $id !== '' && $secret !== '';
    }

    private function baseUrl(): string
    {
        $mode = Setting::where('key', 'paypal_mode')->first()?->value ?? 'sandbox';

        return $mode === 'live'
            ? 'https://api-m.paypal.com'
            : 'https://api-m.sandbox.paypal.com';
    }

    private function accessToken(): ?string
    {
        $clientId = trim((string) (Setting::where('key', 'paypal_client_id')->first()?->value ?? ''));
        $secret = trim((string) (Setting::where('key', 'paypal_client_secret')->first()?->value ?? ''));

        $resp = Http::asForm()
            ->withBasicAuth($clientId, $secret)
            ->timeout(30)
            ->post($this->baseUrl().'/v1/oauth2/token', [
                'grant_type' => 'client_credentials',
            ]);

        if (! $resp->successful()) {
            Log::warning('PayPal OAuth failed', ['status' => $resp->status(), 'body' => $resp->body()]);

            return null;
        }

        return $resp->json('access_token');
    }

    /**
     * @return array{ok: bool, order_id?: string, approve_url?: string, message?: string}
     */
    public function createOrder(string $amount, string $currencyCode, string $returnUrl, string $cancelUrl): array
    {
        if (! $this->isReady()) {
            return ['ok' => false, 'message' => 'PayPal غير مفعّل أو غير مُكوَّن في لوحة التحكم.'];
        }

        $token = $this->accessToken();
        if (! $token) {
            return ['ok' => false, 'message' => 'تعذّر الاتصال بـ PayPal. تحقق من Client ID والسر والبيئة (Sandbox/Live).'];
        }

        $value = number_format(max((float) $amount, 0.01), 2, '.', '');
        $raw = strtoupper(preg_replace('/[^A-Za-z]/', '', $currencyCode) ?: 'USD');
        $ccy = strlen($raw) >= 3 ? substr($raw, 0, 3) : 'USD';

        $payload = [
            'intent' => 'CAPTURE',
            'purchase_units' => [[
                'amount' => [
                    'currency_code' => $ccy,
                    'value' => $value,
                ],
            ]],
            'application_context' => [
                'return_url' => $returnUrl,
                'cancel_url' => $cancelUrl,
                'user_action' => 'PAY_NOW',
            ],
        ];

        $resp = Http::withToken($token)
            ->acceptJson()
            ->asJson()
            ->timeout(45)
            ->post($this->baseUrl().'/v2/checkout/orders', $payload);

        if (! $resp->successful()) {
            Log::warning('PayPal create order failed', ['status' => $resp->status(), 'body' => $resp->body()]);

            return ['ok' => false, 'message' => 'فشل إنشاء طلب الدفع في PayPal.'];
        }

        $id = $resp->json('id');
        $links = $resp->json('links') ?? [];
        $approve = null;
        foreach ($links as $link) {
            if (($link['rel'] ?? '') === 'approve') {
                $approve = $link['href'] ?? null;
                break;
            }
        }

        if (! $id || ! $approve) {
            return ['ok' => false, 'message' => 'استجابة PayPal غير متوقعة.'];
        }

        return ['ok' => true, 'order_id' => $id, 'approve_url' => $approve];
    }

    /**
     * @return array{ok: bool, capture_id?: string, message?: string}
     */
    public function captureOrder(string $orderId): array
    {
        if (! $this->isReady()) {
            return ['ok' => false, 'message' => 'PayPal غير مفعّل.'];
        }

        $token = $this->accessToken();
        if (! $token) {
            return ['ok' => false, 'message' => 'تعذّر الاتصال بـ PayPal.'];
        }

        $captureUrl = $this->baseUrl().'/v2/checkout/orders/'.rawurlencode($orderId).'/capture';
        $resp = Http::withToken($token)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->withBody('{}', 'application/json')
            ->timeout(45)
            ->post($captureUrl);

        if (! $resp->successful()) {
            Log::warning('PayPal capture failed', ['status' => $resp->status(), 'body' => $resp->body()]);

            return ['ok' => false, 'message' => 'لم يُستكمل الدفع في PayPal. أكمل الموافقة في المتصفح ثم اضغط «إتمام الدفع» مرة أخرى.'];
        }

        $status = $resp->json('status');
        if ($status !== 'COMPLETED') {
            return ['ok' => false, 'message' => 'حالة الدفع في PayPal: '.($status ?? 'غير معروف')];
        }

        $captureId = data_get($resp->json(), 'purchase_units.0.payments.captures.0.id');

        return ['ok' => true, 'capture_id' => $captureId ?: $orderId];
    }
}
