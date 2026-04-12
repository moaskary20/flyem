import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/firebase_background.dart';
import 'package:flyem_app/screens/splash_screen.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:flyem_app/services/push_messaging_service.dart';

/// مفتاح التنقل لاستخدامه من إشعارات FCM/المحلية لفتح تبويب الطلبات.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> _initApp() async {
  await LocalNotificationService.initialize();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await PushMessagingService.initialize(appNavigatorKey);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runZonedGuarded(() async {
    String localeCode = 'ar';
    try {
      localeCode = await AppPreferences.getAppLocale().timeout(
        const Duration(seconds: 3),
        onTimeout: () => 'ar',
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AppPreferences.getAppLocale error: $e');
        debugPrintStack(stackTrace: st);
      }
    }
    AppStrings.setLanguageCode(localeCode);
    AppLocale.notifier.value = Locale(localeCode);
    await _initApp();
    if (!kIsWeb && Platform.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2C2C2E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    runApp(
      ListenableBuilder(
        listenable: AppLocale.notifier,
        builder: (_, __) => const MyApp(),
      ),
    );
  }, (error, stack) {
    final msg = error.toString();
    if (kDebugMode) {
      if (msg.contains('HTTP') || msg.contains('SocketException') || msg.contains('statusCode')) {
        debugPrint('Network/HTTP error (handled silently): $msg');
      } else {
        debugPrint('Uncaught async error: $error');
        debugPrintStack(stackTrace: stack);
      }
    }
  });

  FlutterError.onError = (details) {
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exception}');
      debugPrint('${details.stack}');
    }
    FlutterError.presentError(details);
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: AppLocale.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
      builder: (context, child) {
        return Container(
          color: AppColors.navBarBackground,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
