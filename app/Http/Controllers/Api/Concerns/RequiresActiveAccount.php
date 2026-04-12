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
        if ($user->status === 'banned') {
            return response()->json([
                'message' => 'هذا الحساب محظور ولا يمكنه استخدام التطبيق.',
            ], 422);
        }

        $verified = ($user->verification_status ?? '') === 'verified';
        $active = ($user->status ?? '') === 'active';

        if (! $active && ! $verified) {
            return response()->json([
                'message' => 'لا يمكنك إنشاء إعلانات أو إرسال طلبات حتى يُفعَّل حسابك أو يُوثَّق من الإدارة.',
            ], 422);
        }

        return null;
    }
}
