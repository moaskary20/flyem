<?php

namespace Database\Seeders;

use App\Models\City;
use App\Models\Country;
use Illuminate\Database\Seeder;

class CitySeeder extends Seeder
{
    public function run(): void
    {
        $cities = [
            ['country' => 'EGY', 'name_ar' => 'القاهرة', 'name_en' => 'Cairo'],
            ['country' => 'EGY', 'name_ar' => 'الإسكندرية', 'name_en' => 'Alexandria'],
            ['country' => 'EGY', 'name_ar' => 'الجيزة', 'name_en' => 'Giza'],
            ['country' => 'EGY', 'name_ar' => 'شرم الشيخ', 'name_en' => 'Sharm El Sheikh'],
            ['country' => 'USA', 'name_ar' => 'نيويورك', 'name_en' => 'New York'],
            ['country' => 'USA', 'name_ar' => 'لوس أنجلوس', 'name_en' => 'Los Angeles'],
            ['country' => 'USA', 'name_ar' => 'شيكاغو', 'name_en' => 'Chicago'],
            ['country' => 'USA', 'name_ar' => 'هيوستن', 'name_en' => 'Houston'],
            ['country' => 'USA', 'name_ar' => 'ميامي', 'name_en' => 'Miami'],
            ['country' => 'TUR', 'name_ar' => 'إسطنبول', 'name_en' => 'Istanbul'],
            ['country' => 'TUR', 'name_ar' => 'أنقرة', 'name_en' => 'Ankara'],
            ['country' => 'TUR', 'name_ar' => 'أنطاليا', 'name_en' => 'Antalya'],
            ['country' => 'CHN', 'name_ar' => 'بكين', 'name_en' => 'Beijing'],
            ['country' => 'CHN', 'name_ar' => 'شانغهاي', 'name_en' => 'Shanghai'],
            ['country' => 'CHN', 'name_ar' => 'غوانغتشو', 'name_en' => 'Guangzhou'],
            ['country' => 'ARE', 'name_ar' => 'دبي', 'name_en' => 'Dubai'],
            ['country' => 'ARE', 'name_ar' => 'أبوظبي', 'name_en' => 'Abu Dhabi'],
            ['country' => 'ARE', 'name_ar' => 'الشارقة', 'name_en' => 'Sharjah'],
            ['country' => 'SAU', 'name_ar' => 'الرياض', 'name_en' => 'Riyadh'],
            ['country' => 'SAU', 'name_ar' => 'جدة', 'name_en' => 'Jeddah'],
            ['country' => 'SAU', 'name_ar' => 'مكة', 'name_en' => 'Makkah'],
            ['country' => 'SAU', 'name_ar' => 'المدينة المنورة', 'name_en' => 'Madinah'],
            ['country' => 'KWT', 'name_ar' => 'الكويت', 'name_en' => 'Kuwait City'],
            ['country' => 'QAT', 'name_ar' => 'الدوحة', 'name_en' => 'Doha'],
            ['country' => 'BHR', 'name_ar' => 'المنامة', 'name_en' => 'Manama'],
            ['country' => 'OMN', 'name_ar' => 'مسقط', 'name_en' => 'Muscat'],
            ['country' => 'JOR', 'name_ar' => 'عمان', 'name_en' => 'Amman'],
            ['country' => 'LBN', 'name_ar' => 'بيروت', 'name_en' => 'Beirut'],
            ['country' => 'GBR', 'name_ar' => 'لندن', 'name_en' => 'London'],
            ['country' => 'GBR', 'name_ar' => 'مانشستر', 'name_en' => 'Manchester'],
            ['country' => 'FRA', 'name_ar' => 'باريس', 'name_en' => 'Paris'],
            ['country' => 'DEU', 'name_ar' => 'برلين', 'name_en' => 'Berlin'],
            ['country' => 'DEU', 'name_ar' => 'فرانكفورت', 'name_en' => 'Frankfurt'],
            ['country' => 'ITA', 'name_ar' => 'روما', 'name_en' => 'Rome'],
            ['country' => 'ITA', 'name_ar' => 'ميلانو', 'name_en' => 'Milan'],
            ['country' => 'ESP', 'name_ar' => 'مدريد', 'name_en' => 'Madrid'],
            ['country' => 'ESP', 'name_ar' => 'برشلونة', 'name_en' => 'Barcelona'],
            ['country' => 'IND', 'name_ar' => 'مومباي', 'name_en' => 'Mumbai'],
            ['country' => 'IND', 'name_ar' => 'دلهي', 'name_en' => 'Delhi'],
            ['country' => 'PAK', 'name_ar' => 'كراتشي', 'name_en' => 'Karachi'],
            ['country' => 'PAK', 'name_ar' => 'لاهور', 'name_en' => 'Lahore'],
            ['country' => 'MYS', 'name_ar' => 'كوالالمبور', 'name_en' => 'Kuala Lumpur'],
            ['country' => 'SGP', 'name_ar' => 'سنغافورة', 'name_en' => 'Singapore'],
            ['country' => 'CAN', 'name_ar' => 'تورونتو', 'name_en' => 'Toronto'],
            ['country' => 'CAN', 'name_ar' => 'فانكوفر', 'name_en' => 'Vancouver'],
            ['country' => 'AUS', 'name_ar' => 'سيدني', 'name_en' => 'Sydney'],
            ['country' => 'AUS', 'name_ar' => 'ملبورن', 'name_en' => 'Melbourne'],
            ['country' => 'BRA', 'name_ar' => 'ساو باولو', 'name_en' => 'Sao Paulo'],
            ['country' => 'BRA', 'name_ar' => 'ريو دي جانيرو', 'name_en' => 'Rio de Janeiro'],
            ['country' => 'COL', 'name_ar' => 'بوغوتا', 'name_en' => 'Bogota'],
            ['country' => 'ARG', 'name_ar' => 'بوينس آيرس', 'name_en' => 'Buenos Aires'],
        ];

        foreach ($cities as $c) {
            $country = Country::where('code', $c['country'])->first();
            if ($country) {
                City::updateOrCreate(
                    ['country_id' => $country->id, 'name_en' => $c['name_en']],
                    ['name_ar' => $c['name_ar'], 'is_active' => true]
                );
            }
        }

        // إضافة مدينة رئيسية لكل دولة ليس لها مدن بعد
        $countryCodesInCities = array_unique(array_column($cities, 'country'));
        foreach (Country::where('is_active', true)->get() as $country) {
            if (in_array($country->code, $countryCodesInCities)) {
                continue;
            }
            $nameAr = 'مدينة ' . ($country->name_ar ?? 'الرئيسية');
            $nameEn = ($country->name_en ?? 'Main') . ' City';
            City::firstOrCreate(
                [
                    'country_id' => $country->id,
                    'name_en' => $nameEn,
                ],
                [
                    'name_ar' => $nameAr,
                    'is_active' => true,
                ]
            );
        }
    }
}

