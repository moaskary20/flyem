import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/screens/login_screen.dart';
import 'package:flyem_app/screens/personal_profile_screen.dart';
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
/// يعرض حواراً يوجّه المستخدم إلى [PersonalProfileScreen] لمراجعة التوثيق وحالة التفعيل.
Future<bool> ensureAccountActiveForMarketplace(BuildContext context) async {
  final profile = await AuthService.getCurrentUser();
  if (profile != null && profile.canUseMarketplace) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(AppStrings.marketplaceBlockedDialogTitle),
      content: SingleChildScrollView(
        child: Text(
          profile == null
              ? AppStrings.accountNotActiveForMarketplace
              : AppStrings.marketplaceBlockedDialogBody,
          style: const TextStyle(height: 1.35),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: Text(AppStrings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: Colors.black87),
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const PersonalProfileScreen(openedFromMarketplaceGate: true),
                ),
              );
            });
          },
          child: Text(AppStrings.openAccountVerificationPage),
        ),
      ],
    ),
  );
  return false;
}
