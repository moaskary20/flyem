import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/screens/splash_screen.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/services/local_notification_service.dart';

Future<void> _initApp() async {
  await LocalNotificationService.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    await _initApp();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2C2C2E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
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
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    runApp(MyApp(localeCode: localeCode));
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
  const MyApp({super.key, this.localeCode = 'ar'});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فلاي إم',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: Locale(localeCode),
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
