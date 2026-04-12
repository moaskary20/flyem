<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserPayoutAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserPayoutAccountController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $list = $user->payoutAccounts()->orderByDesc('is_primary')->orderBy('id')->get();

        return response()->json([
            'data' => $list->map(fn (UserPayoutAccount $a) => $this->toArray($a)),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validate([
            'iban' => ['nullable', 'string', 'max:64'],
            'bank_name' => ['nullable', 'string', 'max:255'],
            'account_holder' => ['nullable', 'string', 'max:255'],
            'nickname' => ['nullable', 'string', 'max:80'],
            'is_primary' => ['sometimes', 'boolean'],
        ]);

        if (empty($validated['iban'] ?? null) && empty($validated['bank_name'] ?? null) && empty($validated['account_holder'] ?? null)) {
            return response()->json(['message' => __('At least one of IBAN, bank name, or account holder is required.')], 422);
        }

        $isPrimary = (bool) ($validated['is_primary'] ?? false);
        $count = $user->payoutAccounts()->count();
        if ($count === 0) {
            $isPrimary = true;
        }

        $account = DB::transaction(function () use ($user, $validated, $isPrimary) {
            if ($isPrimary) {
                $user->payoutAccounts()->update(['is_primary' => false]);
            }
            /** @var UserPayoutAccount $created */
            $created = $user->payoutAccounts()->create([
                'iban' => $validated['iban'] ?? null,
                'bank_name' => $validated['bank_name'] ?? null,
                'account_holder' => $validated['account_holder'] ?? null,
                'nickname' => $validated['nickname'] ?? null,
                'is_primary' => $isPrimary,
            ]);

            return $created;
        });

        $this->syncUserBankFields($user->fresh());

        return response()->json(['data' => $this->toArray($account)], 201);
    }

    public function update(Request $request, UserPayoutAccount $payoutAccount): JsonResponse
    {
        $user = $request->user();
        if ($payoutAccount->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'iban' => ['nullable', 'string', 'max:64'],
            'bank_name' => ['nullable', 'string', 'max:255'],
            'account_holder' => ['nullable', 'string', 'max:255'],
            'nickname' => ['nullable', 'string', 'max:80'],
            'is_primary' => ['sometimes', 'boolean'],
        ]);

        DB::transaction(function () use ($payoutAccount, $user, $validated) {
            if (($validated['is_primary'] ?? false) === true) {
                $user->payoutAccounts()->where('id', '!=', $payoutAccount->id)->update(['is_primary' => false]);
            }
            $payoutAccount->update([
                'iban' => array_key_exists('iban', $validated) ? $validated['iban'] : $payoutAccount->iban,
                'bank_name' => array_key_exists('bank_name', $validated) ? $validated['bank_name'] : $payoutAccount->bank_name,
                'account_holder' => array_key_exists('account_holder', $validated) ? $validated['account_holder'] : $payoutAccount->account_holder,
                'nickname' => array_key_exists('nickname', $validated) ? $validated['nickname'] : $payoutAccount->nickname,
                'is_primary' => array_key_exists('is_primary', $validated) ? (bool) $validated['is_primary'] : $payoutAccount->is_primary,
            ]);
        });

        $payoutAccount->refresh();
        $this->syncUserBankFields($user->fresh());

        return response()->json(['data' => $this->toArray($payoutAccount)]);
    }

    public function destroy(Request $request, UserPayoutAccount $payoutAccount): JsonResponse
    {
        $user = $request->user();
        if ($payoutAccount->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $wasPrimary = $payoutAccount->is_primary;
        $payoutAccount->delete();

        if ($wasPrimary) {
            $next = $user->payoutAccounts()->orderBy('id')->first();
            if ($next) {
                $next->update(['is_primary' => true]);
            }
        }

        $this->syncUserBankFields($user->fresh());

        return response()->json(['message' => 'deleted']);
    }

    public function setPrimary(Request $request, UserPayoutAccount $payoutAccount): JsonResponse
    {
        $user = $request->user();
        if ($payoutAccount->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        DB::transaction(function () use ($user, $payoutAccount) {
            $user->payoutAccounts()->update(['is_primary' => false]);
            $payoutAccount->update(['is_primary' => true]);
        });

        $this->syncUserBankFields($user->fresh());

        return response()->json(['data' => $this->toArray($payoutAccount->fresh())]);
    }

    private function toArray(UserPayoutAccount $a): array
    {
        return [
            'id' => $a->id,
            'iban' => $a->iban,
            'bank_name' => $a->bank_name,
            'account_holder' => $a->account_holder,
            'nickname' => $a->nickname,
            'is_primary' => (bool) $a->is_primary,
        ];
    }

    private function syncUserBankFields(User $user): void
    {
        $p = $user->payoutAccounts()->where('is_primary', true)->first();
        if ($p) {
            $user->update([
                'bank_iban' => $p->iban,
                'bank_name' => $p->bank_name,
                'bank_account_holder' => $p->account_holder,
            ]);
        } else {
            $user->update([
                'bank_iban' => null,
                'bank_name' => null,
                'bank_account_holder' => null,
            ]);
        }
    }
}
