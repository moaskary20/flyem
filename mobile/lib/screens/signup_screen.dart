import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

/// شاشة الاشتراك: الاسم، البريد، رقم الهاتف الدولة الأم، رقم الهاتف دولة السفر، كلمة المرور.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _homePhoneController = TextEditingController();
  final _travelPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const String _titleAr = 'الاشتراك';
  static const String _titleEn = 'Sign up';
  static const String _firstNameAr = 'الاسم الأول';
  static const String _firstNameEn = 'First name';
  static const String _lastNameAr = 'الاسم الأخير';
  static const String _lastNameEn = 'Last name';
  static const String _emailAr = 'البريد الإلكتروني';
  static const String _emailEn = 'Email';
  static const String _homePhoneAr = 'رقم الهاتف الدولة الأم (إلزامي)';
  static const String _homePhoneEn = 'Phone (home country) - required';
  static const String _travelPhoneAr = 'رقم الهاتف دولة السفر (إلزامي)';
  static const String _travelPhoneEn = 'Phone (travel country) - required';
  static const String _passwordAr = 'كلمة المرور';
  static const String _passwordEn = 'Password';
  static const String _passwordConfirmAr = 'تأكيد كلمة المرور';
  static const String _passwordConfirmEn = 'Confirm password';
  static const String _submitAr = 'إنشاء الحساب';
  static const String _submitEn = 'Create account';

  bool get _isAr => AppStrings.isArabic;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _homePhoneController.dispose();
    _travelPhoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final homePhone = _homePhoneController.text.trim();
    final travelPhone = _travelPhoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _passwordConfirmController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || homePhone.isEmpty || travelPhone.isEmpty) {
      setState(() => _error = _isAr ? 'يرجى تعبئة جميع الحقول' : 'Please fill all fields');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = _isAr ? 'كلمة المرور 8 أحرف على الأقل' : 'Password must be at least 8 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _error = _isAr ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        homePhone: homePhone,
        travelPhone: travelPhone,
        password: password,
        passwordConfirmation: confirm,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 24),
                TextField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(_isAr ? _firstNameAr : _firstNameEn),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(_isAr ? _lastNameAr : _lastNameEn),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: _inputDecoration(_isAr ? _emailAr : _emailEn),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _homePhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(_isAr ? _homePhoneAr : _homePhoneEn),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _travelPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(_isAr ? _travelPhoneAr : _travelPhoneEn),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(_isAr ? _passwordAr : _passwordEn).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordConfirmController,
                  obscureText: _obscureConfirm,
                  decoration: _inputDecoration(_isAr ? _passwordConfirmAr : _passwordConfirmEn).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
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
                    onPressed: _loading ? null : _onSignUp,
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
                            _isAr ? _submitAr : _submitEn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
