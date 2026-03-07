<?php

namespace Database\Seeders;

use App\Models\Country;
use App\Models\Currency;
use App\Models\Shipment;
use App\Models\User;
use Illuminate\Database\Seeder;

class ShipmentSeeder extends Seeder
{
    public const DEFAULT_IMAGE = 'default_shipment.png';

    public function run(): void
    {
        $usd = Currency::where('code', 'USD')->first();
        $users = User::where('role', 'user')->get();
        if ($users->isEmpty()) {
            return;
        }

        $shipments = [
            [
                'title' => 'Buy MacBook Air',
                'weight' => 2.5,
                'quantity' => 1,
                'product_link' => 'https://www.apple.com/shop',
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'USA', 'to_city' => 'New York',
                'deadline' => now()->addDays(2),
                'price' => 105.0,
                'images' => [self::DEFAULT_IMAGE],
                'type' => 'electronics',
            ],
            [
                'title' => 'Hair Extensions',
                'weight' => 0.4,
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'USA', 'to_city' => 'New York',
                'deadline' => now()->addDays(2),
                'price' => 24.2,
                'images' => [self::DEFAULT_IMAGE],
            ],
            [
                'title' => 'Toys',
                'weight' => 1.2,
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'USA', 'to_city' => 'New York',
                'deadline' => now()->addDays(5),
                'price' => 35.0,
                'images' => [self::DEFAULT_IMAGE],
            ],
            [
                'title' => '4 UGREEN Air Tracker Tags',
                'weight' => 0.4,
                'from_country' => 'USA', 'from_city' => 'New York',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'deadline' => now()->addDays(7),
                'price' => 15.0,
                'images' => [self::DEFAULT_IMAGE],
            ],
            [
                'title' => 'شراء TEREA Summer',
                'weight' => 0.3,
                'from_country' => 'EGY', 'from_city' => 'Cairo',
                'to_country' => 'TUR', 'to_city' => 'Istanbul',
                'deadline' => now()->addDays(3),
                'price' => 10.0,
                'images' => [self::DEFAULT_IMAGE],
            ],
            [
                'title' => 'جهاز اختبار المنحنى',
                'weight' => 1.2,
                'from_country' => 'CHN', 'from_city' => 'Beijing',
                'to_country' => 'EGY', 'to_city' => 'Cairo',
                'deadline' => now()->addDays(14),
                'price' => 25.0,
                'images' => [self::DEFAULT_IMAGE],
            ],
        ];

        foreach ($shipments as $i => $s) {
            $fromCountry = Country::where('code', $s['from_country'])->first();
            $toCountry = Country::where('code', $s['to_country'])->first();
            $fromCity = $fromCountry?->cities()->where('name_en', $s['from_city'])->first();
            $toCity = $toCountry?->cities()->where('name_en', $s['to_city'])->first();
            if (! $fromCountry || ! $toCountry || ! $fromCity || ! $toCity || ! $usd) {
                continue;
            }
            Shipment::firstOrCreate(
                [
                    'title' => $s['title'],
                    'from_country_id' => $fromCountry->id,
                    'to_country_id' => $toCountry->id,
                    'user_id' => $users[$i % $users->count()]->id,
                ],
                [
                    'from_city_id' => $fromCity->id,
                    'to_city_id' => $toCity->id,
                    'weight' => $s['weight'],
                    'weight_unit' => 'kg',
                    'quantity' => $s['quantity'] ?? 1,
                    'product_link' => $s['product_link'] ?? null,
                    'deadline_date' => $s['deadline'],
                    'price_min' => $s['price'],
                    'currency_id' => $usd->id,
                    'status' => 'active',
                    'images' => $s['images'],
                    'type' => $s['type'] ?? 'other',
                ]
            );
        }
    }
}
