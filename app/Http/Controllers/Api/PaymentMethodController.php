<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use Illuminate\Http\JsonResponse;

class PaymentMethodController extends Controller
{
    /**
     * قائمة وسائل الدفع النشطة (لشاشة الدفع في التطبيق).
     */
    public function index(): JsonResponse
    {
        $methods = PaymentMethod::where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('name_ar')
            ->get(['id', 'name_ar', 'name_en', 'code']);

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
