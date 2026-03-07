<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            ['key' => 'app_name', 'value' => 'فلاي إم', 'group' => 'general', 'type' => 'text', 'label_ar' => 'اسم التطبيق'],
            ['key' => 'app_description', 'value' => 'منصة شحن بين المسافرين', 'group' => 'general', 'type' => 'text', 'label_ar' => 'وصف التطبيق'],
            ['key' => 'contact_email', 'value' => 'info@flyem.app', 'group' => 'contact', 'type' => 'text', 'label_ar' => 'البريد الإلكتروني للتواصل'],
            ['key' => 'contact_phone', 'value' => '+966500000000', 'group' => 'contact', 'type' => 'text', 'label_ar' => 'رقم هاتف التواصل'],
            ['key' => 'commission_rate', 'value' => '10', 'group' => 'payment', 'type' => 'number', 'label_ar' => 'نسبة العمولة (%)'],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(['key' => $setting['key']], $setting);
        }
    }
}
