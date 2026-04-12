<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserVerification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
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
            'home_phone' => ['required', 'string', 'max:50'],
            'travel_phone' => ['required', 'string', 'max:50'],
            'password' => 'required|string|min:8|confirmed',
        ], [], [
            'first_name' => __('First name'),
            'last_name' => __('Last name'),
            'email' => __('Email'),
            'home_phone' => __('Phone (home country)'),
            'travel_phone' => __('Phone (travel country)'),
            'password' => __('Password'),
        ]);

        $user = User::create([
            'name' => $request->first_name . ' ' . $request->last_name,
            'email' => $request->email,
            'phone' => $request->home_phone,
            'home_phone' => $request->home_phone,
            'travel_phone' => $request->travel_phone,
            'password' => Hash::make($request->password),
            'api_token' => hash('sha256', $token = Str::random(80)),
            'verification_status' => 'pending',
        ]);

        UserVerification::create([
            'user_id' => $user->id,
            'status' => 'pending',
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

        $user->loadCount(['shipments', 'trips', 'ratingsReceived']);
        $with = [
            'homeCountry:id,name_ar,name_en',
            'homeCity:id,name_ar,name_en',
            'travelCountry:id,name_ar,name_en',
            'travelCity:id,name_ar,name_en',
        ];
        if (Schema::hasTable('user_payout_accounts')) {
            $with[] = 'payoutAccounts';
        }
        $user->load($with);

        $profilePhotoUrl = null;
        if ($user->profile_photo) {
            $base = rtrim(config('app.url'), '/');
            $path = trim(preg_replace('/\s+/', '', $user->profile_photo));
            if ($path !== '') {
                $profilePhotoUrl = $base.'/storage/'.ltrim($path, '/');
            }
        }

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone ?? '',
                'profile_photo' => $profilePhotoUrl,
                'verification_status' => $user->verification_status ?? 'unverified',
                'documents_verified' => ($user->verification_status ?? 'unverified') === 'verified',
                'phone_verified' => (bool) ($user->phone_verified ?? false),
                'rating' => $user->rating ? (float) $user->rating : null,
                'wallet_balance' => round((float) ($user->wallet_balance ?? 0), 2),
                'ratings_count' => $user->ratings_received_count ?? 0,
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
                'payout_accounts' => Schema::hasTable('user_payout_accounts')
                    ? $user->payoutAccounts->sortByDesc('is_primary')->values()->map(fn ($a) => [
                        'id' => $a->id,
                        'iban' => $a->iban,
                        'bank_name' => $a->bank_name,
                        'account_holder' => $a->account_holder,
                        'nickname' => $a->nickname,
                        'is_primary' => (bool) $a->is_primary,
                    ])
                    : [],
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

        $fillable = [
            'home_country_id', 'home_city_id', 'travel_country_id', 'travel_city_id',
            'bank_iban', 'bank_name', 'bank_account_holder', 'home_phone', 'travel_phone',
        ];
        $data = [];
        foreach ($fillable as $field) {
            if (array_key_exists($field, $validated)) {
                $data[$field] = $validated[$field];
            }
        }
        if ($data !== []) {
            $user->update($data);
        }

        return response()->json(['message' => 'updated', 'data' => ['id' => $user->id]]);
    }

    /**
     * رفع صورة الملف الشخصي (multipart/form-data مع profile_photo).
     */
    public function updateProfilePhoto(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $request->validate([
            'profile_photo' => ['required', 'file', 'mimes:jpeg,jpg,png,gif', 'max:5120'],
        ], [], ['profile_photo' => __('Profile photo')]);

        // قيمة العمود كما في قاعدة البيانات (بدون المُحوِّل) لتفادي مسار خاطئ عند الحذف.
        $oldPathRaw = $user->getRawOriginal('profile_photo');
        $oldPath = is_string($oldPathRaw) ? trim(preg_replace('/\s+/', '', $oldPathRaw)) : '';

        $stored = $request->file('profile_photo')->store('profiles', 'public');
        if (! is_string($stored) || $stored === '') {
            return response()->json(['message' => __('Could not store the file.')], 500);
        }

        $path = trim($stored);
        $user->forceFill(['profile_photo' => $path])->save();

        if ($oldPath !== '' && $oldPath !== $path && Storage::disk('public')->exists($oldPath)) {
            Storage::disk('public')->delete($oldPath);
        }

        $base = rtrim(config('app.url'), '/');
        $profilePhotoUrl = $base.'/storage/'.ltrim($path, '/');

        return response()->json([
            'message' => 'updated',
            'data' => ['profile_photo' => $profilePhotoUrl],
        ]);
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
