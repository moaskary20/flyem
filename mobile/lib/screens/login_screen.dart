import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/screens/signup_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

/// شاشة تسجيل الدخول: البريد الإلكتروني + كلمة المرور.
/// إذا لم تكن مسجلاً: رابط للانتقال إلى شاشة الاشتراك.
///
/// [popOnSuccess] عند true: بعد نجاح الدخول يُغلق المسار ويعيد `true` (مثل طلب تسجيل دخول قبل إضافة شحنة/رحلة).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.popOnSuccess = false});

  final bool popOnSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  static const String _titleAr = 'تسجيل الدخول';
  static const String _titleEn = 'Login';
  static const String _emailAr = 'البريد الإلكتروني';
  static const String _emailEn = 'Email';
  static const String _passwordAr = 'كلمة المرور';
  static const String _passwordEn = 'Password';
  static const String _loginAr = 'تسجيل الدخول';
  static const String _loginEn = 'Login';
  static const String _noAccountAr = 'إذا لم تكن مسجلاً عليك بالاشتراك';
  static const String _noAccountEn = "If you don't have an account, sign up";

  bool get _isAr => AppStrings.isArabic;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = _isAr ? 'أدخل البريد الإلكتروني وكلمة المرور' : 'Enter email and password');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await AuthService.login(email, password);
      if (!mounted) return;
      if (widget.popOnSuccess) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error = _isAr ? 'حدث خطأ. تحقق من الاتصال.' : 'An error occurred. Check your connection.';
        _loading = false;
      });
    }
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    64,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                if (widget.popOnSuccess)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isAr ? _titleAr : _titleEn,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: _isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: _isAr ? _emailAr : _emailEn,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _isAr ? _passwordAr : _passwordEn,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: _isAr ? TextAlign.right : TextAlign.left,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _onLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isAr ? _loginAr : _loginEn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _goToSignUp,
                  child: Text(
                    _isAr ? _noAccountAr : _noAccountEn,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.buttonDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
