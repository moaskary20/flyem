import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/services/currencies_service.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/screens/login_screen.dart';

/// شاشة اختيار اللغة والعملة — تظهر مرة واحدة فقط عند أول تشغيل للتطبيق بعد التثبيت.
/// بعد الضغط على «متابعة» لا تُعرض مرة أخرى إلا بحذف بيانات التطبيق أو إعادة التثبيت.
class LanguageCurrencyScreen extends StatefulWidget {
  const LanguageCurrencyScreen({super.key});

  @override
  State<LanguageCurrencyScreen> createState() => _LanguageCurrencyScreenState();
}

class _LanguageCurrencyScreenState extends State<LanguageCurrencyScreen> {
  String _locale = 'ar';
  List<CurrencyItem> _currencies = [];
  int? _selectedCurrencyId;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  static const String _titleAr = 'اختر اللغة والعملة';
  static const String _titleEn = 'Choose language and currency';
  static const String _languageAr = 'اختر اللغة';
  static const String _languageEn = 'Language';
  static const String _currencyAr = 'اختر العملة';
  static const String _currencyEn = 'Currency';
  static const String _continueAr = 'متابعة';
  static const String _continueEn = 'Continue';
  static const String _langArabic = 'العربية';
  static const String _langEnglish = 'English';

  bool get _isAr => _locale == 'ar';

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final list = await CurrenciesService.getCurrencies();
      if (mounted) {
        setState(() {
          _currencies = list;
          _loading = false;
          _errorMessage = null;
          if (list.isNotEmpty && _selectedCurrencyId == null) {
            _selectedCurrencyId = list.first.id;
          }
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
        });
      }
      debugPrint('Currencies load error: $e');
      debugPrint('$st');
    }
  }

  Future<void> _onContinue() async {
    if (_currencies.isEmpty || _selectedCurrencyId == null) return;
    setState(() => _saving = true);
    await AppPreferences.setAppLocale(_locale);
    await CurrenciesService.setSelectedCurrencyId(_selectedCurrencyId);
    await AppPreferences.setOnboardingDone(true);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _locale == 'ar';
    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isAr ? _titleAr : _titleEn,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 32),
                Text(
                  _isAr ? _languageAr : _languageEn,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LangChip(
                        label: _langArabic,
                        isSelected: _locale == 'ar',
                        onTap: () => setState(() => _locale = 'ar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LangChip(
                        label: _langEnglish,
                        isSelected: _locale == 'en',
                        onTap: () => setState(() => _locale = 'en'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _isAr ? _currencyAr : _currencyEn,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isAr ? 'فشل تحميل العملات' : 'Failed to load currencies',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _loadCurrencies,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: Text(_isAr ? 'إعادة المحاولة' : 'Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_currencies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _isAr ? 'لا توجد عملات متاحة' : 'No currencies available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currencies.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (_, i) {
                        final c = _currencies[i];
                        final selected = _selectedCurrencyId == c.id;
                        return ListTile(
                          title: Text('${c.name} (${c.symbol})'),
                          trailing: selected
                              ? Icon(Icons.check, color: AppColors.primaryYellow, size: 22)
                              : null,
                          onTap: () => setState(() => _selectedCurrencyId = c.id),
                        );
                      },
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_loading || _currencies.isEmpty || _saving) ? null : _onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isAr ? _continueAr : _continueEn,
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
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.buttonDark : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryYellow : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
