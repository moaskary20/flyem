import 'package:flutter/material.dart';
import 'package:flyem_app/screens/main_nav_screen.dart';

/// فتح تبويب الطلبات من payload إشعار محلي أو FCM.
class PushNavigation {
  PushNavigation._();

  static GlobalKey<NavigatorState>? navigatorKey;

  static void handlePayload(String? raw) {
    if (raw == null || raw.isEmpty) return;
    final map = <String, String>{};
    for (final part in raw.split('&')) {
      final i = part.indexOf('=');
      if (i <= 0) continue;
      final k = Uri.decodeComponent(part.substring(0, i));
      final v = Uri.decodeComponent(part.substring(i + 1));
      map[k] = v;
    }
    if (map['tab'] == 'requests') {
      openRequestsTab();
    }
  }

  static void openRequestsTab() {
    final nav = navigatorKey?.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainNavScreen(initialIndex: 3)),
      (_) => false,
    );
  }
}
