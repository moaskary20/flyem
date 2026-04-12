<?php

namespace App\Services;

use App\Models\UserDeviceToken;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmPushService
{
    /**
     * إرسال إشعار FCM لجميع أجهزة المستخدم (Legacy HTTP API).
     * يتطلب FCM_SERVER_KEY في .env؛ إن وُجدت القيمة فارغة يُتخطى الإرسال بصمت.
     *
     * @param  array<string, string>  $data
     */
    public function sendToUser(int $userId, string $title, string $body, array $data = []): void
    {
        $key = config('services.fcm.server_key');
        if (! is_string($key) || trim($key) === '') {
            return;
        }

        $tokens = UserDeviceToken::query()
            ->where('user_id', $userId)
            ->pluck('token')
            ->unique()
            ->values()
            ->all();

        if ($tokens === []) {
            return;
        }

        $stringData = [];
        foreach ($data as $k => $v) {
            $stringData[(string) $k] = is_scalar($v) ? (string) $v : json_encode($v);
        }

        foreach (array_chunk($tokens, 500) as $chunk) {
            try {
                $response = Http::timeout(15)
                    ->withHeaders([
                        'Authorization' => 'key='.$key,
                        'Content-Type' => 'application/json',
                    ])
                    ->post('https://fcm.googleapis.com/fcm/send', [
                        'registration_ids' => $chunk,
                        'notification' => [
                            'title' => $title,
                            'body' => $body,
                        ],
                        'data' => $stringData,
                        'priority' => 'high',
                    ]);

                if (! $response->successful()) {
                    Log::warning('FCM send failed', [
                        'status' => $response->status(),
                        'body' => $response->body(),
                    ]);
                }
            } catch (\Throwable $e) {
                Log::warning('FCM send exception: '.$e->getMessage());
            }
        }
    }
}
