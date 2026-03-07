<?php

namespace Database\Seeders;

use App\Models\Country;
use App\Models\Currency;
use App\Models\Trip;
use App\Models\User;
use Illuminate\Database\Seeder;

class TripSeeder extends Seeder
{
    public function run(): void
    {
        $usd = Currency::where('code', 'USD')->first();
        $users = User::where('role', 'user')->get();
        if ($users->isEmpty() || ! $usd) {
            return;
        }

        $trips = [
            [
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'USA', 'to_city' => 'New York',
                'departure' => now()->addDays(3),
                'available_weight' => 23,
                'price_per_kg' => 8.5,
                'travel_method' => 'flight',
                'notes' => 'رحلة مباشرة القاهرة - نيويورك',
            ],
            [
                'from_country' => 'USA', 'from_city' => 'New York',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'departure' => now()->addDays(7),
                'available_weight' => 15,
                'price_per_kg' => 7.0,
                'travel_method' => 'flight',
                'notes' => 'Return flight',
            ],
            [
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'TUR', 'to_city' => 'Istanbul',
                'departure' => now()->addDays(5),
                'available_weight' => 20,
                'price_per_kg' => 5.0,
                'travel_method' => 'flight',
                'notes' => 'رحلة إلى إسطنبول',
            ],
            [
                'from_country' => 'SAU', 'from_city' => 'Riyadh',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'departure' => now()->addDays(2),
                'available_weight' => 30,
                'price_per_kg' => 4.0,
                'travel_method' => 'flight',
                'notes' => 'الرياض - القاهرة',
            ],
            [
                'from_country' => 'ARE', 'from_city' => 'Dubai',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'departure' => now()->addDays(4),
                'available_weight' => 25,
                'price_per_kg' => 6.0,
                'travel_method' => 'flight',
                'notes' => 'دبي - القاهرة',
            ],
            [
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'SAU', 'to_city' => 'Jeddah',
                'departure' => now()->addDays(10),
                'available_weight' => 18,
                'price_per_kg' => 5.5,
                'travel_method' => 'flight',
                'notes' => 'رحلة عمرة',
            ],
            [
                'from_country' => 'GBR', 'from_city' => 'London',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'departure' => now()->addDays(14),
                'available_weight' => 20,
                'price_per_kg' => 9.0,
                'travel_method' => 'flight',
                'notes' => 'London to Cairo',
            ],
            [
                'from_country' => 'DEU', 'from_city' => 'Frankfurt',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'departure' => now()->addDays(6),
                'available_weight' => 22,
                'price_per_kg' => 7.5,
                'travel_method' => 'flight',
                'notes' => 'فرانكفورت - القاهرة',
            ],
        ];

        foreach ($trips as $i => $t) {
            $fromCountry = Country::where('code', $t['from_country'])->first();
            $toCountry = Country::where('code', $t['to_country'])->first();
            $fromCity = $fromCountry?->cities()->where('name_en', $t['from_city'])->first();
            $toCity = $toCountry?->cities()->where('name_en', $t['to_city'])->first();
            if (! $fromCountry || ! $toCountry || ! $fromCity || ! $toCity) {
                continue;
            }

            Trip::firstOrCreate(
                [
                    'user_id' => $users[$i % $users->count()]->id,
                    'from_country_id' => $fromCountry->id,
                    'from_city_id' => $fromCity->id,
                    'to_country_id' => $toCountry->id,
                    'to_city_id' => $toCity->id,
                    'departure_date' => $t['departure'],
                ],
                [
                    'travel_method' => $t['travel_method'],
                    'available_weight' => $t['available_weight'],
                    'weight_unit' => 'kg',
                    'price_per_kg' => $t['price_per_kg'],
                    'currency_id' => $usd->id,
                    'notes' => $t['notes'],
                    'status' => 'active',
                ]
            );
        }
    }
}
