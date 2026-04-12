<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_payout_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('iban', 64)->nullable();
            $table->string('bank_name', 255)->nullable();
            $table->string('account_holder', 255)->nullable();
            $table->string('nickname', 80)->nullable();
            $table->boolean('is_primary')->default(false);
            $table->timestamps();
        });

        if (! Schema::hasTable('users')) {
            return;
        }

        $users = DB::table('users')->select('id', 'bank_iban', 'bank_name', 'bank_account_holder')->get();
        foreach ($users as $u) {
            if (($u->bank_iban ?? '') === '' && ($u->bank_name ?? '') === '' && ($u->bank_account_holder ?? '') === '') {
                continue;
            }
            DB::table('user_payout_accounts')->insert([
                'user_id' => $u->id,
                'iban' => $u->bank_iban,
                'bank_name' => $u->bank_name,
                'account_holder' => $u->bank_account_holder,
                'nickname' => null,
                'is_primary' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('user_payout_accounts');
    }
};
