<?php

namespace App\Http\Controllers\Api\Concerns;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

trait RequiresActiveAccount
{
    protected function rejectUnlessActiveAccount(Request $request): ?JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }
        if ($user->status !== 'active') {
            return response()->json([
                'message' => 'حسابك غير مُفعّل بعد. لا يمكن إنشاء إعلانات أو إرسال طلبات حتى يتم تفعيل الحساب من الإدارة.',
            ], 422);
        }

        return null;
    }
}
