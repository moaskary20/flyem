# فلاي إم - تطبيق الموبايل (Flyem Mobile)

تطبيق Flutter لمنصة الشحن بين المسافرين، مرتبط بلوحة التحكم Laravel (Filament).

## المتطلبات

- Flutter SDK (^3.10.7)
- Dart ^3.10.7

## التشغيل

```bash
cd mobile
flutter pub get
flutter run
```

## البنية

- `lib/` — كود التطبيق (شاشات، خدمات، نماذج)
- `android/` — إعدادات أندرويد
- `ios/` — إعدادات iOS

## الربط مع الـ API

الـ Backend يعمل على مشروع Laravel في المجلد الأب. يمكن ربط التطبيق عبر REST API أو Sanctum عند تفعيله.
