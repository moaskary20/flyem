<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\City;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CityController extends Controller
{
    /**
     * قائمة المدن. إجباري: country_id. اختياري: search للاقتراح عند الكتابة.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate(['country_id' => 'required|integer|exists:countries,id']);

        $query = City::where('country_id', $request->country_id)
            ->where('is_active', true);

        if ($request->filled('search')) {
            $term = '%' . $request->search . '%';
            $query->where(function ($q) use ($term) {
                $q->where('name_ar', 'like', $term)
                    ->orWhere('name_en', 'like', $term);
            });
        }

        $cities = $query->orderBy('name_ar')->get(['id', 'name_ar', 'name_en', 'country_id']);

        return response()->json(['data' => $cities]);
    }
}
