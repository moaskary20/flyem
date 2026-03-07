<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use Illuminate\Http\JsonResponse;

class CurrencyController extends Controller
{
    /**
     * قائمة العملات النشطة (لاختيار العملة في إعدادات التطبيق).
     */
    public function index(): JsonResponse
    {
        $currencies = Currency::where('is_active', true)
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
