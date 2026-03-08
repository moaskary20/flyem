<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->boolean('can_pickup_in_current_country')->default(false)->after('notes');
            $table->boolean('can_deliver_in_other_country')->default(false)->after('can_pickup_in_current_country');
            $table->boolean('can_return_on_cancel')->default(false)->after('can_deliver_in_other_country');
            $table->unsignedTinyInteger('return_before_days')->nullable()->after('can_return_on_cancel');
        });
    }

    public function down(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->dropColumn([
                'can_pickup_in_current_country',
                'can_deliver_in_other_country',
                'can_return_on_cancel',
                'return_before_days',
            ]);
        });
    }
};
