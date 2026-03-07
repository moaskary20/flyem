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
            ],
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
