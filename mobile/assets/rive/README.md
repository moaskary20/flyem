# أيقونات Rive للـ Navigation Bar

لتفعيل **أيقونات Rive المتحركة** في شريط التنقل السفلي:

## 1. إضافة ملفات Rive

ضع ملفات `.riv` في هذا المجلد. يمكنك استخدام أحد الخيارين:

### خيار أ: ملف منفصل لكل أيقونة (موصى به)

| الملف         | الاستخدام   |
|--------------|-------------|
| `search.riv`     | البحث       |
| `shipments.riv`  | الشحنات     |
| `trips.riv`      | الرحلات     |
| `messages.riv`   | الرسائل     |
| `more.riv`       | المزيد      |

### خيار ب: ملف واحد يحتوي عدة Artboards

أنشئ ملفاً واحداً (مثلاً `nav_icons.riv`) فيه عدة artboards بأسماء: `search`, `shipments`, `trips`, `messages`, `more`، ثم عدّل المسارات في `main_nav_screen.dart` لاستخدام هذا الملف مع تغيير `artboardName` لكل عنصر.

## 2. مواصفات ملف Rive

- **State Machine**: اسم افتراضي `State Machine` (يمكن تغييره في الكود).
- **Input بولياني**: اسم افتراضي `active` أو `isActive` — عند `true` تُعرض الحركة المفعّلة، وعند `false` الحالة الافتراضية.

يمكنك تحميل أيقونات جاهزة من:
- [Rive Community - Animated Icons](https://rive.app/community/)
- ابحث عن "animated icon" أو "bottom nav" وصدّر الملفات أو الـ artboards المطلوبة.

## 3. تفعيل الأيقونات في التطبيق

في الملف `lib/screens/main_nav_screen.dart` غيّر:

```dart
const bool _useRiveIcons = true;
```

ثم شغّل التطبيق من جديد.

## 4. تخصيص أسماء الـ Artboard أو الـ State Machine

إذا كانت أسماء الـ artboard أو الـ state machine أو الـ input في ملفك مختلفة، عدّلها في استدعاء `RiveNavItem` عبر:

- `artboardName`: اسم الـ artboard (غالباً `Main`).
- `stateMachineName`: اسم الـ State Machine (افتراضي `State Machine`).
- `activeInputName`: اسم الـ input البولياني (افتراضي `active`).
