<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\JsonResponse;

class CouponController extends Controller
{
    /**
     * قائمة الكوبونات المتاحة للمستخدم (لشاشة الكوبونات).
     */
    public function index(): JsonResponse
    {
        $coupons = Coupon::where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('expiry_date')->orWhere('expiry_date', '>=', now()->toDateString());
            })
            ->orderBy('expiry_date')
            ->get(['id', 'code', 'discount_type', 'discount_value', 'expiry_date']);

        $data = $coupons->map(function ($c) {
            return [
                'id' => $c->id,
                'code' => $c->code,
                'discount_type' => $c->discount_type,
                'discount_value' => (float) $c->discount_value,
                'expiry_date' => $c->expiry_date?->format('Y-m-d'),
            ];
        });

        return response()->json(['data' => $data]);
    }
}
