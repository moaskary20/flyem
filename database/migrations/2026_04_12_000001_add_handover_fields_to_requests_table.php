<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('requests', function (Blueprint $table) {
            $table->timestamp('custody_confirmed_at')->nullable()->after('status');
            $table->timestamp('delivery_confirmed_at')->nullable()->after('custody_confirmed_at');
        });
    }

    public function down(): void
    {
        Schema::table('requests', function (Blueprint $table) {
            $table->dropColumn(['custody_confirmed_at', 'delivery_confirmed_at']);
        });
    }
};
