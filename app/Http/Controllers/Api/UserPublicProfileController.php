<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class UserPublicProfileController extends Controller
{
    /**
     * ملف عام للمستخدم (للعرض من التطبيق): الاسم الأول، التقييم، دولتَي المنزل والسفر فقط.
     * لا يُرجع هاتفاً ولا بريداً ولا صورة ولا الاسم الكامل.
     */
    public function show(User $user): JsonResponse
    {
        $user->load(['homeCountry:id,name_ar', 'travelCountry:id,name_ar']);

        $name = trim((string) ($user->name ?? ''));
        $parts = preg_split('/\s+/u', $name, 2, PREG_SPLIT_NO_EMPTY);
        $firstName = $parts[0] ?? 'مستخدم';

        return response()->json([
            'data' => [
                'id' => $user->id,
                'first_name' => $firstName,
                'has_last_name' => ! empty($parts[1] ?? ''),
                'rating' => $user->rating !== null ? (float) $user->rating : 0.0,
                'home_country_name' => $user->homeCountry?->name_ar ?? '',
                'travel_country_name' => $user->travelCountry?->name_ar ?? '',
            ],
        ]);
    }
}
