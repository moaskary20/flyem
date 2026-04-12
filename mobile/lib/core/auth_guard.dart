import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/login_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

/// يتحقق من تسجيل الدخول؛ إن لم يكن مسجّلاً يفتح [LoginScreen] ويعيد true بعد نجاح الدخول.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (await AuthService.isLoggedIn()) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => const LoginScreen(popOnSuccess: true),
    ),
  );
  return result == true;
}

/// بعد تسجيل الدخول: يمنع السوق إن كان الحساب محظوراً أو غير مُفعّل وغير موثّق.
Future<bool> ensureAccountActiveForMarketplace(BuildContext context) async {
  final profile = await AuthService.getCurrentUser();
  if (profile != null && profile.canUseMarketplace) {
    return true;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.accountNotActiveForMarketplace)),
    );
  }
  return false;
}
