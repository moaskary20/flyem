<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Request as RequestModel;
use App\Models\Setting;
use App\Models\Shipment;
use App\Models\Trip;
use App\Services\PayPalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PayPalOrderController extends Controller
{
    /**
     * إنشاء طلب PayPal لدفع طلب رحلة (يفتح التطبيق رابط الموافقة).
     */
    public function forTrip(Request $request, Trip $trip): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $trip->user_id === (int) $user->id) {
            return response()->json(['message' => 'لا يمكن إرسال طلب على رحلتك.'], 422);
        }

        if (RequestModel::where('trip_id', $trip->id)->where('requester_id', $user->id)->exists()) {
            return response()->json(['message' => 'لقد أرسلت طلباً على هذه الرحلة مسبقاً.'], 422);
        }

        if (RequestModel::hasBlockingRequestWithListingOwner((int) $user->id, (int) $trip->user_id)) {
            return response()->json([
                'message' => 'لديك طلب مفتوح مع صاحب هذه الرحلة على إعلان آخر؛ أنهِ الطلب السابق أو انتظر حتى يُرفض قبل إرسال طلب جديد لنفس الشخص.',
            ], 422);
        }

        $paypal = app(PayPalService::class);
        if (! $paypal->isReady()) {
            return response()->json(['message' => 'PayPal غير متاح. فعّل البوابة من لوحة التحكم.'], 422);
        }

        $trip->loadMissing('currency:id,code');
        $amount = $this->tripPayAmount($trip);
        $currency = strtoupper($trip->currency?->code ?? 'USD');

        $returnUrl = route('paypal.return', [], true);
        $cancelUrl = route('paypal.cancel', [], true);

        $result = $paypal->createOrder((string) $amount, $currency, $returnUrl, $cancelUrl);
        if (! ($result['ok'] ?? false)) {
            return response()->json(['message' => $result['message'] ?? 'خطأ PayPal'], 422);
        }

        return response()->json([
            'data' => [
                'order_id' => $result['order_id'],
                'approve_url' => $result['approve_url'],
            ],
        ]);
    }

    /**
     * إنشاء طلب PayPal لدفع طلب شحنة.
     */
    public function forShipment(Request $request, Shipment $shipment): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $shipment->user_id === (int) $user->id) {
            return response()->json(['message' => 'لا يمكن إرسال طلب على شحنتك.'], 422);
        }

        if (RequestModel::where('shipment_id', $shipment->id)->where('requester_id', $user->id)->exists()) {
            return response()->json(['message' => 'لقد أرسلت طلباً على هذه الشحنة مسبقاً.'], 422);
        }

        if (RequestModel::hasBlockingRequestWithListingOwner((int) $user->id, (int) $shipment->user_id)) {
            return response()->json([
                'message' => 'لديك طلب مفتوح مع صاحب هذه الشحنة على إعلان آخر؛ أنهِ الطلب السابق أو انتظر حتى يُرفض قبل إرسال طلب جديد لنفس الشخص.',
            ], 422);
        }

        $paypal = app(PayPalService::class);
        if (! $paypal->isReady()) {
            return response()->json(['message' => 'PayPal غير متاح. فعّل البوابة من لوحة التحكم.'], 422);
        }

        $shipment->loadMissing('currency:id,code');
        $amount = $this->shipmentPayAmount($shipment);
        $currency = strtoupper($shipment->currency?->code ?? 'USD');

        $returnUrl = route('paypal.return', [], true);
        $cancelUrl = route('paypal.cancel', [], true);

        $result = $paypal->createOrder((string) $amount, $currency, $returnUrl, $cancelUrl);
        if (! ($result['ok'] ?? false)) {
            return response()->json(['message' => $result['message'] ?? 'خطأ PayPal'], 422);
        }

        return response()->json([
            'data' => [
                'order_id' => $result['order_id'],
                'approve_url' => $result['approve_url'],
            ],
        ]);
    }

    private function tripPayAmount(Trip $trip): float
    {
        $minTripPriceSetting = Setting::where('key', 'min_trip_price')->first();
        $minTripPrice = $minTripPriceSetting && filled($minTripPriceSetting->value)
            ? (float) $minTripPriceSetting->value
            : null;

        $amount = (float) ($trip->price_per_kg ?? 0);
        if ($minTripPrice !== null && $minTripPrice > 0) {
            $amount = $amount > 0 ? max($amount, $minTripPrice) : $minTripPrice;
        }
        if ($amount <= 0) {
            $amount = 1;
        }

        return $amount;
    }

    private function shipmentPayAmount(Shipment $shipment): float
    {
        $amount = (float) ($shipment->price_min ?? 1);
        if ($amount <= 0) {
            $amount = 1;
        }

        return $amount;
    }
}
