<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class SettingController extends Controller
{
    /**
     * إعدادات التطبيق (مفتاح-قيمة) للاستخدام في المزيد/الإعدادات.
     * يمكن تمرير group مثل "app" أو "support" لتصفية النتائج.
     */
    public function index(): JsonResponse
    {
        $settings = Cache::remember('api_settings', 300, function () {
            $arr = [];
            foreach (Setting::all() as $s) {
                $arr[$s->key] = $s->value;
            }
            return $arr;
        });

        return response()->json(['data' => $settings]);
    }
}
