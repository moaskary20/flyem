<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use Illuminate\Http\JsonResponse;

class CurrencyController extends Controller
{
    /**
     * قائمة العملات (لاختيار العملة في إعدادات التطبيق).
     * تُرجع كل العملات لضمان ظهورها في التطبيق مثل لوحة الإدارة.
     */
    public function index(): JsonResponse
    {
        $currencies = Currency::query()
            ->orderBy('name')
            ->get(['id', 'name', 'symbol', 'code']);

        $data = $currencies->map(fn ($c) => [
            'id' => $c->id,
            'name' => $c->name,
            'symbol' => $c->symbol,
            'code' => $c->code,
        ]);

        return response()->json(['data' => $data]);
    }
}
