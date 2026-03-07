import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/login_screen.dart';
import 'package:flyem_app/services/auth_service.dart';
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _contentBg,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            AppStrings.settings,
            style: TextStyle(
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
                _buildLanguageSection(),
                const SizedBox(height: 32),
                _buildLogoutButton(),
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
            onChanged: (v) => setState(() => _shippingNotifications = v),
            activeColor: AppColors.primaryYellow,
          ),
        ),
        const SizedBox(height: 12),
        _SettingsRow(
          label: AppStrings.chatNotifications,
          trailing: Switch(
            value: _chatNotifications,
            onChanged: (v) => setState(() => _chatNotifications = v),
            activeColor: AppColors.primaryYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(AppStrings.chooseLanguage),
        InkWell(
          onTap: () {},
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
                  AppStrings.languageArabic,
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () async {
          await AuthService.logout();
          if (!context.mounted) return;
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تسجيل الخروج')),
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          AppStrings.logout,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
        children: [
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
        ],
      ),
    );
  }
}
