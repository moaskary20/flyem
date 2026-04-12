<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use App\Services\PayPalService;
use Illuminate\Http\JsonResponse;

class PaymentMethodController extends Controller
{
    /**
     * قائمة وسائل الدفع النشطة (لشاشة الدفع في التطبيق).
     * PayPal يظهر فقط عند تفعيل البوابة وتعبئة المفاتيح في لوحة التحكم.
     */
    public function index(): JsonResponse
    {
        $paypalReady = app(PayPalService::class)->isReady();

        $methods = PaymentMethod::where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('name_ar')
            ->get(['id', 'name_ar', 'name_en', 'code']);

        if (! $paypalReady) {
            $methods = $methods->reject(fn ($m) => $m->code === 'paypal')->values();
        }

        return response()->json([
            'data' => $methods->map(fn ($m) => [
                'id' => $m->id,
                'name_ar' => $m->name_ar,
                'name_en' => $m->name_en,
                'code' => $m->code,
            ]),
        ]);
    }
}
