# ربط شاشات التطبيق بلوحة التحكم (Admin Panel)

## ملخص الواجهات البرمجية (API)

| المسار | الوصف | لوحة التحكم |
|--------|--------|-------------|
| `GET/POST /api/shipments` | الشحنات (بحث، إنشاء، عرض، حذف) | إدارة الشحنات > الشحنات |
| `GET /api/countries` | الدول | إدارة الموقع > الدول |
| `GET /api/cities` | المدن (حسب الدولة) | إدارة الموقع > المدن |
| `GET/POST /api/trips` | الرحلات (قائمة المستخدم، إنشاء، عرض، حذف) | إدارة الشحنات > الرحلات |
| `GET /api/faqs` | الأسئلة الشائعة | إدارة المحتوى > FAQs |
| `GET /api/coupons` | الكوبونات المتاحة | إدارة المعاملات > الكوبونات |
| `GET /api/settings` | إعدادات التطبيق (مفتاح-قيمة) | الإعدادات |
| `GET /api/currencies` | العملات النشطة (لاختيار العملة في الإعدادات) | إدارة المعاملات > العملات |
| `GET/POST /api/conversations` | قائمة محادثات المستخدم، إنشاء محادثة | المحادثات (Conversations) |
| `GET /api/conversations/{id}` | رسائل محادثة واحدة | المحادثات + الرسائل (Messages) |
| `POST /api/conversations/{id}/messages` | إرسال رسالة في محادثة | الرسائل (Messages) |
| `GET /api/payment-methods` | وسائل الدفع النشطة | إدارة المعاملات > وسائل الدفع |
| `POST /api/trips/{id}/send-request` | إرسال طلب على رحلة (دفع) | الطلبات، المعاملات، وسائل الدفع |
| `POST /api/shipments/{id}/send-request` | إرسال طلب على شحنة (دفع) | الطلبات، المعاملات، وسائل الدفع |

---

## شاشة تلو الأخرى

### 1. البحث (Search)
- **المصدر:**
  - **تبويب شحنات:** `ShipmentsService.getShipments()` مع فلترة من/إلى (دولة من الـ API).
  - **تبويب رحلات:** `TripsService.getTripsForSearch()` لعرض كل الرحلات النشطة مع فلتر اختياري.
  - **من/إلى:** اختيار الدولة من قائمة (كل الدول من الـ seed) مع بحث عند الكتابة (`GET /api/countries?search=`).
- **لوحة التحكم:** الشحنات، الرحلات، الدول (إدارة الموقع > الدول)، المدن (إدارة الموقع > المدن).
- **الـ seed:** `database/data/countries.php` + `CountrySeeder` و`CitySeeder` — دول كثيرة + مدن رئيسية.
- **الحالة:** مربوطة بالكامل.

### 2. شحناتي (My Shipments)
- **المصدر:** `ShipmentsService.getMyShipments(userId)` ثم تبويبات (الصفقات، الرحلات المناسبة، التفاصيل).
- **لوحة التحكم:** الشحنات، الطلبات (Requests)، المستخدمون.
- **الحالة:** مربوطة (قائمة الشحنات، تفاصيل، حذف، إضافة شحنة).
- **إرسال طلب (دفع):** من شاشة تفاصيل الشحنة زر «إرسال طلب» يفتح **شاشة الدفع** (`ShipmentPaymentScreen`) — نفس آلية الرحلات: اختيار وسيلة دفع، إتمام الدفع، ثم التوجيه إلى الرسائل وفتح المحادثة مع صاحب الشحنة (`POST /api/shipments/{id}/send-request`).

### 3. رحلات (Trips)
- **المصدر:** `TripsService.getMyTrips(userId)` — قائمة الرحلات، `TripsService.createTrip()` عند إضافة رحلة من نموذج «أضف رحلتك».
- **لوحة التحكم:** إدارة الشحنات > الرحلات (عرض/إنشاء/تعديل الرحلات).
- **الحالة:** مربوطة (عرض القائمة من API، إنشاء رحلة يظهر في اللوحة).
- **إرسال طلب (دفع):** من شاشة تفاصيل الرحلة زر «إرسال طلب» يفتح **شاشة الدفع** (`TripPaymentScreen`). المستخدم يختار وسيلة دفع من قائمة تُجلب من `GET /api/payment-methods` (مرتبطة بإدارة المعاملات > وسائل الدفع). عند «إتمام الدفع» يُستدعى `POST /api/trips/{id}/send-request` (مع token). بعد النجاح يتم التوجيه إلى **شاشة الرسائل** وفتح **المحادثة** مع صاحب الرحلة تلقائياً.

### 4. الرسائل (Messages)
- **المصدر:**
  - **تبويب المحادثات:** `ConversationsService.getConversations()` — قائمة محادثات المستخدم من الـ API. الضغط على محادثة يفتح شاشة المحادثة مع `getConversation(id)` و`sendMessage(id, text)`.
  - تبويبات (الاخبار، تطابقات، اتفاقات) واجهة فقط — يمكن ربطها لاحقاً.
- **لوحة التحكم:** المحادثات (Conversations)، الرسائل (Messages). إنشاء/تعديل محادثات ورسائل من اللوحة يظهر في التطبيق.
- **الحالة:** تبويب المحادثات مربوط بالكامل بالـ API ولوحة التحكم. الـ seed يضيف محادثات ورسائل وهمية للاختبار.

### 5. المزيد (More)
- **الملف الشخصي:** اسم المستخدم ثابت — لاحقاً من API المستخدمين.
- **الإعدادات:** واجهة محلية — يمكن جلب نصوص/قيم من `GET /api/settings`. **عملة التطبيق:** المستخدم يختار عملة من قائمة العملات (`GET /api/currencies`)؛ النتيجة تُحفظ محلياً وتُستخدم لفلترة الشحنات والرحلات في شاشة البحث (عرض البنود بالعملة المختارة فقط).
- **تفاصيل الدفع:** شاشة ثابتة — لاحقاً من Payments في اللوحة.
- **الكوبونات:** `ContentService.getCoupons()` — القائمة من لوحة التحكم (كوبونات متاحة).
- **قائمة الرغبات:** واجهة فقط.
- **الأسئلة الشائعة:** `ContentService.getFaqs()` — المحتوى من لوحة التحكم (FAQs).
- **الخصوصية والشروط:** واجهة ثابتة أو من إعدادات/صفحات.
- **الدعم الفني:** شاشة ثابتة — لاحقاً ربط مع تذاكر الدعم (Support Tickets).
- **مشاركة التطبيق / من نحن:** ثابت.
- **الحالة:** FAQ و Coupons مربوطة؛ الباقي يمكن ربطه لاحقاً عبر Settings أو واجهات المستخدم/الدعم.

---

## تحقق الربط: التطبيق ↔ API ↔ لوحة التحكم

### مسارات الـ API المستخدمة من التطبيق (routes/api.php)

| المسار | التطبيق يستدعيه | لوحة التحكم (Filament) |
|--------|------------------|-------------------------|
| `POST /api/login` | AuthService.login | — |
| `POST /api/register` | AuthService.register | — |
| `GET /api/user` (مع token) | AuthService.getCurrentUser | المستخدمون |
| `GET /api/countries` | ShipmentsService, AddTrip, AddShipment, Search | Countries |
| `GET /api/cities` | ShipmentsService, AddTrip, AddShipment | Cities |
| `GET /api/shipments` | Search, getMyShipments | Shipments |
| `POST /api/shipments` | AddShipmentScreen | Shipments |
| `GET /api/shipments/{id}` | MyShipments, ShipmentDetails | Shipments |
| `DELETE /api/shipments/{id}` | MyShipments (حذف) | Shipments |
| `POST /api/shipments/{id}/send-request` | ShipmentPaymentScreen | Requests, Payments, PaymentMethods |
| `GET /api/trips` | TripsScreen, Search | Trips |
| `POST /api/trips` | AddTripFormScreen | Trips |
| `GET /api/trips/{id}` | TripDetailsScreen | Trips |
| `DELETE /api/trips/{id}` | TripsScreen (حذف) | Trips |
| `POST /api/trips/{id}/send-request` | TripPaymentScreen | Requests, Payments, PaymentMethods |
| `GET /api/payment-methods` | TripPaymentScreen, ShipmentPaymentScreen | PaymentMethods |
| `GET /api/conversations` | MessagesScreen | Conversations |
| `GET /api/conversations/{id}` | ChatScreen | Conversations, Messages |
| `POST /api/conversations/{id}/messages` | ChatScreen | Messages |
| `GET /api/banners` | SearchScreen (سلايدر) | Banners |
| `GET /api/places` | FilterSheet, SearchFormSection (بحث من/إلى) | — (PlaceController من countries/cities) |
| `GET /api/currencies` | SettingsScreen, LanguageCurrencyScreen | Currencies |
| `GET /api/faqs` | FaqScreen | Faqs |
| `GET /api/coupons` | CouponsScreen | Coupons |
| `GET /api/settings` | ContentService.getSettings (متاح للتطبيق) | Settings |

**ملاحظة:** تم إضافة `GET /api/payment-methods` إلى `routes/api.php` لربط شاشتي الدفع (رحلة/شحنة) بوسائل الدفع في لوحة التحكم.

### ميزات واجهة فقط (بدون API حالي)

- تبويبات الرسائل: الاخبار، تطابقات، اتفاقات (واجهة).
- قائمة الرغبات، تفاصيل الدفع، الدعم الفني، الخصوصية والشروط، من نحن، مشاركة التطبيق (ثابتة أو لاحقاً).
- صور شحنة التسوق (محفوظة محلياً؛ رفع الملفات للـ API لاحقاً عند دعمه).

---

## إعدادات مهمة للتشغيل

- **التطبيق:** `mobile/lib/core/api_config.dart` — `kApiBaseUrl` (عنوان الـ backend). المستخدم الحالي يُجلب من `AuthService.getUserId()` بعد تسجيل الدخول.
- **الخادم:** تشغيل Laravel (`php artisan serve` أو على منفذ 8000) وتشغيل migrations وتهيئة البيانات (دول، مدن، عملة افتراضية، وسائل دفع نشطة) حتى تعمل الشحنات والرحلات والدفع بدون أخطاء.
