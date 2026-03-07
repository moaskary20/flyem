import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/screens/language_currency_screen.dart';
import 'package:flyem_app/screens/login_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _splashVideoAsset = 'assets/images/splash.mp4';
  static const Duration _maxSplashDuration = Duration(seconds: 5);
  static const Duration _webSplashDuration = Duration(milliseconds: 1500);

  VideoPlayerController? _controller;
  bool _videoError = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // على الويب: عدم استخدام الفيديو (قد يسبب شاشة بيضاء)، الانتقال بعد مدة قصيرة
      Future.delayed(_webSplashDuration, _goToNext);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initVideo();
      });
      Future.delayed(_maxSplashDuration, _goToNext);
    }
  }

  Future<void> _initVideo() async {
    try {
      final c = VideoPlayerController.asset(_splashVideoAsset);
      await c.initialize();
      if (!mounted) return;
      _attachController(c);
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  void _attachController(VideoPlayerController c) {
    c.addListener(_onVideoUpdate);
    c.setLooping(false);
    c.setVolume(0); // بدون صوت
    setState(() => _controller = c);
    c.play();
    setState(() {});
  }

  void _onVideoUpdate() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    if (dur.inMilliseconds > 0 && pos >= dur) _goToNext();
  }

  Future<void> _goToNext() async {
    if (_navigating || !mounted) return;
    _navigating = true;
    bool onboardingDone = false;
    bool loggedIn = false;
    try {
      onboardingDone = await AppPreferences.isOnboardingDone();
      loggedIn = await AuthService.isLoggedIn();
    } catch (e) {
      debugPrint('Splash _goToNext error: $e');
    }
    if (!mounted) return;
    Widget next;
    if (!onboardingDone) {
      next = const LanguageCurrencyScreen();
    } else if (!loggedIn) {
      next = const LoginScreen();
    } else {
      next = const HomeScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (kIsWeb) {
      return _buildWebSplash();
    }
    if (_videoError || _controller == null || !_controller!.value.isInitialized) {
      return _buildFallback();
    }
    final size = _controller!.value.size;
    final w = size.width > 0 ? size.width : 1920.0;
    final h = size.height > 0 ? size.height : 1080.0;
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: w,
            height: h,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }

  /// على الويب: شاشة بسيطة مع اسم التطبيق ثم الانتقال
  Widget _buildWebSplash() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF2C2C2E),
      child: const Center(
        child: Text(
          'فلاي إم',
          style: TextStyle(
            color: Color(0xFFFDB913),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// أثناء التحميل أو عند الخطأ: شاشة بيضاء فقط
  Widget _buildFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
    );
  }
}
