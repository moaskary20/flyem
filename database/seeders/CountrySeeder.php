<?php

namespace Database\Seeders;

use App\Models\Country;
use Illuminate\Database\Seeder;

class CountrySeeder extends Seeder
{
    public function run(): void
    {
        $countries = require __DIR__ . '/../data/countries.php';

        foreach ($countries as $c) {
            Country::updateOrCreate(
                ['code' => $c['code']],
                array_merge($c, ['is_active' => true])
            );
        }
    }
}
