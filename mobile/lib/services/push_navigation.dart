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
      final sub = map['requests_sub'];
      final idx = int.tryParse(sub ?? '');
      openRequestsTab(requestsTabIndex: idx);
    }
  }

  /// [requestsTabIndex] تبويب داخل مركز الطلبات (0–4)، أو null للافتراضي 0.
  static void openRequestsTab({int? requestsTabIndex}) {
    final nav = navigatorKey?.currentState;
    if (nav == null) return;
    final idx = (requestsTabIndex ?? 0).clamp(0, 4);
    nav.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainNavScreen(
          initialIndex: 3,
          initialRequestsTabIndex: idx,
        ),
      ),
      (_) => false,
    );
  }
}
