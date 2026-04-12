<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserDeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    /**
     * تسجيل أو تحديث توكن FCM للجهاز الحالي.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $request->validate([
            'token' => 'required|string|max:512',
            'platform' => 'nullable|string|in:android,ios',
        ], [], [
            'token' => 'token',
            'platform' => 'platform',
        ]);

        $token = $request->input('token');
        $platform = $request->input('platform', 'android');

        UserDeviceToken::query()->updateOrCreate(
            ['token' => $token],
            [
                'user_id' => $user->id,
                'platform' => $platform,
                'last_used_at' => now(),
            ]
        );

        return response()->json(['data' => ['message' => 'تم حفظ التوكن.']]);
    }

    /**
     * إزالة توكن جهاز (عند تسجيل الخروج من الجهاز).
     */
    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $request->validate([
            'token' => 'required|string|max:512',
        ]);

        UserDeviceToken::query()
            ->where('user_id', $user->id)
            ->where('token', $request->input('token'))
            ->delete();

        return response()->json(['data' => ['message' => 'تم حذف التوكن.']]);
    }
}
