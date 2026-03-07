<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\City;
use App\Models\Country;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlaceController extends Controller
{
    /**
     * بحث عن أماكن (مدينة + بلد أو بلد فقط) للاقتراح عند الكتابة في من/إلى.
     * GET /api/places?q=قاه
     */
    public function index(Request $request): JsonResponse
    {
        $q = $request->input('q', '');
        $q = trim($q);
        if (mb_strlen($q) < 1) {
            return response()->json(['data' => []]);
        }

        $term = '%' . $q . '%';
        $data = [];

        // مدن (مدينة، بلد)
        $cities = City::query()
            ->with('country:id,name_ar,name_en,code')
            ->where('cities.is_active', true)
            ->whereHas('country', fn ($c) => $c->where('is_active', true))
            ->where(function ($query) use ($term) {
                $query->where('cities.name_ar', 'like', $term)
                    ->orWhere('cities.name_en', 'like', $term)
                    ->orWhereHas('country', function ($c) use ($term) {
                        $c->where('name_ar', 'like', $term)->orWhere('name_en', 'like', $term);
                    });
            })
            ->orderBy('cities.name_ar')
            ->limit(20)
            ->get(['cities.id', 'cities.country_id', 'cities.name_ar', 'cities.name_en']);

        foreach ($cities as $city) {
            $country = $city->country;
            $data[] = [
                'country_id' => $city->country_id,
                'city_id' => $city->id,
                'city_name_ar' => $city->name_ar,
                'country_name_ar' => $country->name_ar ?? '',
                'display' => $city->name_ar . '، ' . ($country->name_ar ?? $country->name_en),
            ];
        }

        // بلدان تطابق البحث (اختيار البلد فقط)
        $countries = Country::where('is_active', true)
            ->where(function ($c) use ($term) {
                $c->where('name_ar', 'like', $term)->orWhere('name_en', 'like', $term)->orWhere('code', 'like', $term);
            })
            ->orderBy('name_ar')
            ->limit(10)
            ->get(['id', 'name_ar', 'name_en']);

        foreach ($countries as $country) {
            $data[] = [
                'country_id' => $country->id,
                'city_id' => null,
                'city_name_ar' => '',
                'country_name_ar' => $country->name_ar,
                'display' => $country->name_ar,
            ];
        }

        return response()->json(['data' => $data]);
    }
}
