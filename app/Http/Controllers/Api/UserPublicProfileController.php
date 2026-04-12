<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Request as DealRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserPublicProfileController extends Controller
{
    /**
     * ملف عام للمستخدم: الاسم الأول، التقييم، دولتَي المنزل والسفر.
     * إن كان المستخدم المُصدِر للطلب شريكاً في طلب مدفوع نشط مع المُستهدف، يُعرض رقم التواصل وصورة الملف.
     */
    public function show(Request $request, User $user): JsonResponse
    {
        $user->load(['homeCountry:id,name_ar', 'travelCountry:id,name_ar']);

        $name = trim((string) ($user->name ?? ''));
        $parts = preg_split('/\s+/u', $name, 2, PREG_SPLIT_NO_EMPTY);
        $firstName = $parts[0] ?? 'مستخدم';

        $viewer = $request->user();
        $revealsContact = $viewer
            && (int) $viewer->id !== (int) $user->id
            && DealRequest::trustedPeersShareActiveDeal((int) $viewer->id, (int) $user->id);

        $data = [
            'id' => $user->id,
            'first_name' => $firstName,
            'has_last_name' => ! empty($parts[1] ?? ''),
            'rating' => $user->rating !== null ? (float) $user->rating : 0.0,
            'home_country_name' => $user->homeCountry?->name_ar ?? '',
            'travel_country_name' => $user->travelCountry?->name_ar ?? '',
            'reveals_contact' => $revealsContact,
        ];

        if ($revealsContact) {
            $phone = trim((string) ($user->travel_phone ?: $user->phone ?: ''));
            $photoPath = trim((string) ($user->getRawOriginal('profile_photo') ?? $user->profile_photo ?? ''));
            $data['contact_phone'] = $phone !== '' ? $phone : null;
            $data['profile_photo_url'] = $photoPath !== '' ? url('storage/'.ltrim($photoPath, '/')) : null;
        } else {
            $data['contact_phone'] = null;
            $data['profile_photo_url'] = null;
        }

        return response()->json(['data' => $data]);
    }
}
