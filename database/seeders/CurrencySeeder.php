<?php

namespace Database\Seeders;

use App\Models\Currency;
use Illuminate\Database\Seeder;

class CurrencySeeder extends Seeder
{
    public function run(): void
    {
        Currency::updateOrCreate(
            ['code' => 'USD'],
            ['name' => 'دولار أمريكي', 'symbol' => '$', 'exchange_rate' => 1, 'is_default' => true, 'is_active' => true]
        );
        Currency::updateOrCreate(
            ['code' => 'SAR'],
            ['name' => 'ريال سعودي', 'symbol' => '﷼', 'exchange_rate' => 3.75, 'is_active' => true]
        );
        Currency::updateOrCreate(
            ['code' => 'EGP'],
            ['name' => 'جنيه مصري', 'symbol' => 'ج.م', 'exchange_rate' => 30.5, 'is_active' => true]
        );
    }
}
