<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            AdminUserSeeder::class,
            SettingsSeeder::class,
            CountrySeeder::class,
            CitySeeder::class,
            CurrencySeeder::class,
            UserSeeder::class,
            ShipmentSeeder::class,
            TripSeeder::class,
            ConversationSeeder::class,
            PaymentMethodSeeder::class,
        ]);
    }
}
