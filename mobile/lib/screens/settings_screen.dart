import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/screens/suggest_feedback_screen.dart';
import 'package:flyem_app/services/currencies_service.dart';

/// شاشة الإعدادات: العملة، التنبيهات، اللغة، تسجيل الخروج.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _shippingNotifications = false;
  bool _chatNotifications = true;
  List<CurrencyItem> _currencies = [];
  int? _selectedCurrencyId;
  bool _currenciesLoading = true;

  static const Color _headerDark = Color(0xFF2C2C2E);
  static const Color _contentBg = Color(0xFFF5F0E6);

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    CurrenciesService.getSelectedCurrencyId().then((id) {
      if (mounted) setState(() => _selectedCurrencyId = id);
    });
    AppPreferences.getNotifyShippingTrips().then((v) {
      if (mounted) setState(() => _shippingNotifications = v);
    });
    AppPreferences.getNotifyChat().then((v) {
      if (mounted) setState(() => _chatNotifications = v);
    });
  }

  Future<void> _loadCurrencies() async {
    setState(() => _currenciesLoading = true);
    try {
      final list = await CurrenciesService.getCurrencies();
      if (mounted) setState(() {
        _currencies = list;
        _currenciesLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _currenciesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: _contentBg,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppStrings.settings,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCurrencySection(),
                const SizedBox(height: 28),
                _buildNotificationsSection(),
                const SizedBox(height: 28),
                _buildSuggestSection(),
                const SizedBox(height: 28),
                _buildLanguageSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(AppStrings.appCurrency),
        if (_currenciesLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    AppStrings.allCurrencies,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  trailing: _selectedCurrencyId == null
                      ? Icon(Icons.check, color: AppColors.primaryYellow, size: 22)
                      : null,
                  onTap: () async {
                    await CurrenciesService.setSelectedCurrencyId(null);
                    if (mounted) setState(() => _selectedCurrencyId = null);
                  },
                ),
                ..._currencies.map((c) => ListTile(
                      title: Text(
                        '${c.name} (${c.symbol})',
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      trailing: _selectedCurrencyId == c.id
                          ? Icon(Icons.check, color: AppColors.primaryYellow, size: 22)
                          : null,
                      onTap: () async {
                        await CurrenciesService.setSelectedCurrencyId(c.id);
                        if (mounted) setState(() => _selectedCurrencyId = c.id);
                      },
                    )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(AppStrings.notifications),
        _SettingsRow(
          label: AppStrings.shippingOrTripNotifications,
          trailing: Switch(
            value: _shippingNotifications,
            onChanged: (v) async {
              setState(() => _shippingNotifications = v);
              await AppPreferences.setNotifyShippingTrips(v);
            },
            activeThumbColor: AppColors.primaryYellow,
          ),
        ),
        const SizedBox(height: 12),
        _SettingsRow(
          label: AppStrings.chatNotifications,
          trailing: Switch(
            value: _chatNotifications,
            onChanged: (v) async {
              setState(() => _chatNotifications = v);
              await AppPreferences.setNotifyChat(v);
            },
            activeThumbColor: AppColors.primaryYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(AppStrings.suggestToUs),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SuggestFeedbackScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primaryYellow, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.suggestToUs,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
                  Icon(
                    AppStrings.isArabic ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    final currentLabel =
        AppStrings.isArabic ? AppStrings.languageOptionArabic : AppStrings.languageOptionEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(AppStrings.chooseLanguage),
        InkWell(
          onTap: () => _showLanguagePicker(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  AppStrings.language,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLanguagePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(AppStrings.languageOptionArabic),
                trailing: AppStrings.isArabic ? Icon(Icons.check, color: AppColors.primaryYellow) : null,
                onTap: () async {
                  await AppPreferences.setAppLocale('ar');
                  AppLocale.setLocale(const Locale('ar'));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text(AppStrings.languageOptionEnglish),
                trailing: AppStrings.isEnglish ? Icon(Icons.check, color: AppColors.primaryYellow) : null,
                onTap: () async {
                  await AppPreferences.setAppLocale('en');
                  AppLocale.setLocale(const Locale('en'));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.trailing,
  });

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: AppStrings.isArabic
            ? [
                trailing,
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ]
            : [
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                trailing,
              ],
      ),
    );
  }
}
