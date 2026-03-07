<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Country;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CountryController extends Controller
{
    /**
     * قائمة الدول (للبحث والفلترة). اختياري: search للاقتراح عند الكتابة.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Country::where('is_active', true);

        if ($request->filled('search')) {
            $term = '%' . $request->search . '%';
            $query->where(function ($q) use ($term) {
                $q->where('name_ar', 'like', $term)
                    ->orWhere('name_en', 'like', $term)
                    ->orWhere('code', 'like', $term);
            });
        }

        $countries = $query->orderBy('name_ar')->get(['id', 'name_ar', 'name_en', 'code']);

        return response()->json(['data' => $countries]);
    }
}
