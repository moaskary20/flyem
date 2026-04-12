import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flyem_app/core/app_strings.dart';

/// خدمة الإشعارات المحلية — عرض إشعارات في شريط إشعارات أندرويد عند الأحداث داخل التطبيق.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService _instance = LocalNotificationService._();
  static LocalNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'flyem_events';

  bool _initialized = false;

  /// تهيئة الإشعارات وقناة أندرويد. يُستدعى مرة واحدة من main.
  static Future<void> initialize() async {
    if (_instance._initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: android, iOS: ios);
      await _instance._plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
      if (Platform.isAndroid) {
        final channel = AndroidNotificationChannel(
          _channelId,
          AppStrings.notificationChannelName,
          description: AppStrings.notificationChannelDescription,
          importance: Importance.high,
        );
        await _instance._plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
        // صلاحية POST_NOTIFICATIONS على أندرويد 13+ — يمكن طلبها لاحقاً عبر permission_handler أو إعدادات النظام
      }
      _instance._initialized = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('LocalNotificationService.initialize error: $e');
        debugPrintStack(stackTrace: st);
      }
    }
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    // يمكن لاحقاً استخدام payload للتوجيه (مثلاً screen=shipments&id=1)
    if (kDebugMode) debugPrint('LocalNotificationService payload: $payload');
  }

  /// عرض إشعار فوري. [id] فريد لتجنب استبدال إشعار بآخر.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    if (!_instance._initialized) {
      await initialize();
    }
    if (!_instance._initialized) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        AppStrings.notificationChannelName,
        channelDescription: AppStrings.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      String? payloadStr;
      if (payload != null && payload.isNotEmpty) {
        payloadStr = payload.entries.map((e) => '${e.key}=${e.value}').join('&');
      }
      await _instance._plugin.show(id, title, body, details, payload: payloadStr);
    } catch (e) {
      if (kDebugMode) debugPrint('LocalNotificationService.showNotification: $e');
    }
  }

  /// توليد id فريد بسيط من الوقت ونوع الحدث لتجنب تكرار الاستبدال.
  static int idForEvent(String eventType) {
    final t = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
    final h = eventType.hashCode & 0x7FF;
    return t + h;
  }

  /// معرّف فريد لكل إشعار حتى لا يُستبدل إشعارٌ بآخر عند إرسال طلبات متعددة.
  static int uniqueNotificationId() => DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
}
