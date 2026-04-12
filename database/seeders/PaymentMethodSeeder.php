<?php

namespace Database\Seeders;

use App\Models\PaymentMethod;
use Illuminate\Database\Seeder;

class PaymentMethodSeeder extends Seeder
{
    public function run(): void
    {
        $methods = [
            ['name_ar' => 'بطاقة ائتمان', 'name_en' => 'Credit Card', 'code' => 'card', 'sort_order' => 1],
            ['name_ar' => 'محفظة إلكترونية', 'name_en' => 'Wallet', 'code' => 'wallet', 'sort_order' => 2],
            ['name_ar' => 'تحويل بنكي', 'name_en' => 'Bank Transfer', 'code' => 'bank_transfer', 'sort_order' => 3],
            ['name_ar' => 'PayPal', 'name_en' => 'PayPal', 'code' => 'paypal', 'sort_order' => 4],
        ];

        foreach ($methods as $m) {
            PaymentMethod::updateOrCreate(
                ['code' => $m['code']],
                array_merge($m, ['is_active' => true])
            );
        }
    }
}
