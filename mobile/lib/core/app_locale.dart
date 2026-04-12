import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_strings.dart';

/// يزامن لغة [MaterialApp] مع نصوص [AppStrings] ويُحدَّث من الإعدادات أو شاشة الإعداد الأولي.
class AppLocale {
  AppLocale._();

  static final ValueNotifier<Locale> notifier = ValueNotifier(const Locale('ar'));

  static Locale get locale => notifier.value;

  static TextDirection get textDirection =>
      locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  static void setLocale(Locale locale) {
    final code = locale.languageCode == 'en' ? 'en' : 'ar';
    AppStrings.setLanguageCode(code);
    notifier.value = Locale(code);
  }
}
