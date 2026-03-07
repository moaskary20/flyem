import 'package:shared_preferences/shared_preferences.dart';

/// مفاتيح التفضيلات: اللغة، اكتمال شاشة الإعداد الأولي، تسجيل الدخول.
class AppPreferences {
  /// اكتمال الإعداد الأولي: بعد اختيار اللغة والعملة والضغط على «متابعة» يُحفظ true
  /// فلا تظهر شاشة «اختر اللغة والعملة» مرة أخرى إلا بعد إعادة تثبيت التطبيق.
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyAppLocale = 'app_locale';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, value);
  }

  static Future<String> getAppLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppLocale) ?? 'ar';
  }

  static Future<void> setAppLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppLocale, localeCode);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  static Future<void> setAuth(int? userId, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null || token == null) {
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyAuthToken);
    } else {
      await prefs.setInt(_keyUserId, userId);
      await prefs.setString(_keyAuthToken, token);
    }
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
