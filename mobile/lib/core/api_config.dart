/// Base URL for backend API (production server).
const String kApiBaseUrl = 'https://flyem.caesar-agency.co.uk';

/// إذا فشل تحليل النطاق (Failed host lookup) على الموبايل، يُجرّب التطبيق هذا الرابط.
/// ضع هنا عنوان السيرفر بـ IP إن وُجد، مثلاً: 'https://123.45.67.89'
const String? kApiBaseUrlFallback = null;

/// على الموبايل قد يرفض الجهاز شهادة SSL للسيرفر؛ تفعيل هذا يسمح بالاتصال (للتشغيل فقط).
const bool kAllowInsecureSSL = true;

/// المستخدم الحالي (لشحناتي وإنشاء شحنة). استبدله بآلية تسجيل دخول لاحقاً.
const int kCurrentUserId = 2;
