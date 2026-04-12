import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// يجب أن تبقى دالة الخلفية في ملف منفصل ويُسجَّل استدعاؤها قبل [Firebase.initializeApp] في `main`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
