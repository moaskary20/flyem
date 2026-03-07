<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * تسجيل الدخول: email + password
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => [__('auth.failed')],
            ]);
        }

        $token = Str::random(80);
        $user->forceFill(['api_token' => hash('sha256', $token)])->save();

        return response()->json([
            'user' => $user->only(['id', 'name', 'email', 'phone']),
            'token' => $token,
        ]);
    }

    /**
     * الاشتراك: first_name, last_name, email, phone, password
     */
    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'required|string|max:50',
            'home_phone' => ['nullable', 'string', 'max:50'],
            'travel_phone' => ['nullable', 'string', 'max:50'],
            'password' => 'required|string|min:8|confirmed',
        ], [], [
            'first_name' => __('First name'),
            'last_name' => __('Last name'),
            'email' => __('Email'),
            'phone' => __('Phone'),
            'password' => __('Password'),
        ]);

        $user = User::create([
            'name' => $request->first_name . ' ' . $request->last_name,
            'email' => $request->email,
            'phone' => $request->phone,
            'home_phone' => $request->home_phone,
            'travel_phone' => $request->travel_phone,
            'password' => Hash::make($request->password),
            'api_token' => hash('sha256', $token = Str::random(80)),
        ]);

        return response()->json([
            'user' => $user->only(['id', 'name', 'email', 'phone']),
            'token' => $token,
        ], 201);
    }

    /**
     * بيانات المستخدم الحالي (يتطلب مصادقة).
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $user->loadCount(['shipments', 'trips']);
        $user->load(['homeCountry:id,name_ar,name_en', 'homeCity:id,name_ar,name_en', 'travelCountry:id,name_ar,name_en', 'travelCity:id,name_ar,name_en']);

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone ?? '',
                'profile_photo' => $user->profile_photo,
                'verification_status' => $user->verification_status ?? 'unverified',
                'rating' => $user->rating ? (float) $user->rating : null,
                'shipments_count' => $user->shipments_count ?? 0,
                'trips_count' => $user->trips_count ?? 0,
                'home_country_id' => $user->home_country_id,
                'home_city_id' => $user->home_city_id,
                'home_country_name' => $user->homeCountry?->name_ar ?? $user->homeCountry?->name_en ?? null,
                'home_city_name' => $user->homeCity?->name_ar ?? $user->homeCity?->name_en ?? null,
                'travel_country_id' => $user->travel_country_id,
                'travel_city_id' => $user->travel_city_id,
                'travel_country_name' => $user->travelCountry?->name_ar ?? $user->travelCountry?->name_en ?? null,
                'travel_city_name' => $user->travelCity?->name_ar ?? $user->travelCity?->name_en ?? null,
                'bank_iban' => $user->bank_iban,
                'bank_name' => $user->bank_name,
                'bank_account_holder' => $user->bank_account_holder,
                'home_phone' => $user->home_phone,
                'travel_phone' => $user->travel_phone,
            ],
        ]);
    }

    /**
     * تحديث بيانات الملف الشخصي (الدولة/المدينة الأم والسفر).
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $validated = $request->validate([
            'home_country_id' => ['nullable', 'integer', 'exists:countries,id'],
            'home_city_id' => ['nullable', 'integer', 'exists:cities,id'],
            'travel_country_id' => ['nullable', 'integer', 'exists:countries,id'],
            'travel_city_id' => ['nullable', 'integer', 'exists:cities,id'],
            'bank_iban' => ['nullable', 'string', 'max:50'],
            'bank_name' => ['nullable', 'string', 'max:255'],
            'bank_account_holder' => ['nullable', 'string', 'max:255'],
            'home_phone' => ['nullable', 'string', 'max:50'],
            'travel_phone' => ['nullable', 'string', 'max:50'],
        ]);

        $user->update([
            'home_country_id' => $validated['home_country_id'] ?? null,
            'home_city_id' => $validated['home_city_id'] ?? null,
            'travel_country_id' => $validated['travel_country_id'] ?? null,
            'travel_city_id' => $validated['travel_city_id'] ?? null,
            'bank_iban' => $validated['bank_iban'] ?? null,
            'bank_name' => $validated['bank_name'] ?? null,
            'bank_account_holder' => $validated['bank_account_holder'] ?? null,
            'home_phone' => $validated['home_phone'] ?? null,
            'travel_phone' => $validated['travel_phone'] ?? null,
        ]);

        return response()->json(['message' => 'updated', 'data' => ['id' => $user->id]]);
    }

    /**
     * تسجيل الخروج (إبطال التوكن من جهة العميل يكفي؛ اختياري: مسح التوكن من السيرفر).
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user) {
            $user->forceFill(['api_token' => null])->save();
        }

        return response()->json(['message' => __('Logged out successfully')]);
    }
}
