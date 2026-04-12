import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:flyem_app/services/push_navigation.dart';

/// تهيئة FCM، تسجيل التوكن على الخادم، وعرض إشعارات عند وصول رسالة والتوجيه عند الضغط.
class PushMessagingService {
  PushMessagingService._();

  static bool _initialized = false;

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    PushNavigation.navigatorKey = navigatorKey;
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (Platform.isAndroid) {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
        final n = msg.notification;
        final title = n?.title ?? 'FlyEm';
        final body = n?.body ?? '';
        final data = <String, String>{};
        msg.data.forEach((k, v) => data[k] = v.toString());
        if (!data.containsKey('tab')) {
          data['tab'] = 'requests';
        }
        await LocalNotificationService.showNotification(
          id: LocalNotificationService.uniqueNotificationId(),
          title: title,
          body: body,
          payload: data,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
        final data = msg.data;
        final tab = data['tab']?.toString();
        if (tab == 'requests') {
          PushNavigation.openRequestsTab();
        }
      });

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final tab = initial.data['tab']?.toString();
          if (tab == 'requests') {
            PushNavigation.openRequestsTab();
          }
        });
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        AppPreferences.setCachedFcmToken(t);
        syncTokenWithBackend();
      });

      _initialized = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('PushMessagingService.initialize: $e');
        debugPrintStack(stackTrace: st);
      }
    }
  }

  static Future<void> syncTokenWithBackend() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final loggedIn = await AppPreferences.isLoggedIn();
      if (!loggedIn) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await AppPreferences.setCachedFcmToken(token);
      final authToken = await AppPreferences.getAuthToken();
      if (authToken == null || authToken.isEmpty) return;
      await ApiClient.post(
        '/api/user/fcm-token',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
        preventDuplicate: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('syncTokenWithBackend: $e');
    }
  }

  static Future<void> unregisterFromBackend() async {
    try {
      final authToken = await AppPreferences.getAuthToken();
      final token =
          (await FirebaseMessaging.instance.getToken()) ?? await AppPreferences.getCachedFcmToken();
      if (authToken == null || authToken.isEmpty || token == null || token.isEmpty) return;
      await ApiClient.delete(
        '/api/user/fcm-token',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
        preventDuplicate: false,
      );
    } catch (_) {}
    await AppPreferences.setCachedFcmToken(null);
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}
