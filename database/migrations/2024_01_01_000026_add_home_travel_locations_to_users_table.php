<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->unsignedBigInteger('home_country_id')->nullable()->after('city_id');
            $table->unsignedBigInteger('home_city_id')->nullable()->after('home_country_id');
            $table->unsignedBigInteger('travel_country_id')->nullable()->after('home_city_id');
            $table->unsignedBigInteger('travel_city_id')->nullable()->after('travel_country_id');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->foreign('home_country_id')->references('id')->on('countries')->nullOnDelete();
            $table->foreign('home_city_id')->references('id')->on('cities')->nullOnDelete();
            $table->foreign('travel_country_id')->references('id')->on('countries')->nullOnDelete();
            $table->foreign('travel_city_id')->references('id')->on('cities')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['home_country_id']);
            $table->dropForeign(['home_city_id']);
            $table->dropForeign(['travel_country_id']);
            $table->dropForeign(['travel_city_id']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['home_country_id', 'home_city_id', 'travel_country_id', 'travel_city_id']);
        });
    }
};
