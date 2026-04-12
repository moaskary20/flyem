<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

/**
 * تشغيل بيانات الدول ثم المدن (من countries.php + CitySeeder).
 * الاستخدام: php artisan db:seed --class=CountriesAndCitiesSeeder
 */
class CountriesAndCitiesSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            CountrySeeder::class,
            CitySeeder::class,
        ]);
    }
}
