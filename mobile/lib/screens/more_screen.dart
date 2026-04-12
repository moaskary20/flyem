import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/auth_guard.dart';
import 'package:flyem_app/screens/personal_profile_screen.dart';
import 'package:flyem_app/screens/wallet_screen.dart';
import 'package:flyem_app/screens/suggest_feedback_screen.dart';
import 'package:flyem_app/screens/technical_support_screen.dart';
import 'package:flyem_app/screens/faq_screen.dart';
import 'package:flyem_app/screens/privacy_terms_screen.dart';
import 'package:flyem_app/screens/home_screen.dart';
import 'package:flyem_app/screens/login_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

enum _MoreAction {
  suggest,
  language,
  wallet,
  faq,
  privacy,
  support,
  share,
  about,
}

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  UserProfile? _user;
  bool _loading = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final signedIn = await AuthService.isLoggedIn();
    final user = signedIn ? await AuthService.getCurrentUser() : null;
    if (mounted) {
      setState(() {
        _signedIn = signedIn;
        _user = user;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 24),
                _buildOptionsCard(context),
                const SizedBox(height: 20),
                _buildLogoutSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final name = _loading
        ? '...'
        : (!_signedIn
            ? AppStrings.guestUserLabel
            : (_user?.name.isNotEmpty == true ? _user!.name : 'المستخدم'));
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 36, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              if (!_signedIn) {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                );
                if (context.mounted) await _loadUser();
                return;
              }
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const PersonalProfileScreen(),
                ),
              );
              if (context.mounted) await _loadUser();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_signedIn ? AppStrings.personalPage : AppStrings.signInTitle),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    final options = <(_MoreAction, String, IconData)>[
      (_MoreAction.suggest, AppStrings.suggestToUs, Icons.lightbulb_outline),
      (_MoreAction.language, AppStrings.language, Icons.language_outlined),
      (_MoreAction.wallet, AppStrings.walletProfileTitle, Icons.account_balance_wallet_outlined),
      (_MoreAction.faq, AppStrings.faq, Icons.chat_bubble_outline),
      (_MoreAction.privacy, AppStrings.privacyAndTerms, Icons.description_outlined),
      (_MoreAction.support, AppStrings.technicalSupport, Icons.help_outline),
      (_MoreAction.share, AppStrings.shareApp, Icons.share_outlined),
      (_MoreAction.about, AppStrings.aboutApp, Icons.info_outline),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            _OptionTile(
              label: options[i].$2,
              icon: options[i].$3,
              onTap: () => _onMoreAction(context, options[i].$1),
            ),
            if (i < options.length - 1)
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: Colors.grey[300],
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _onMoreAction(BuildContext context, _MoreAction action) async {
    switch (action) {
      case _MoreAction.suggest:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SuggestFeedbackScreen()),
        );
      case _MoreAction.language:
        _showLanguagePicker();
      case _MoreAction.wallet:
        if (!await ensureLoggedIn(context) || !context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );
      case _MoreAction.faq:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FaqScreen()),
        );
      case _MoreAction.privacy:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PrivacyTermsScreen()),
        );
      case _MoreAction.support:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TechnicalSupportScreen()),
        );
      case _MoreAction.share:
        Share.share(
          'جرب تطبيق فلاي إم - منصة الشحن بين المسافرين 🧳✈️\n'
          'https://play.google.com/store/apps/details?id=com.flyem.app',
          subject: 'تطبيق فلاي إم',
        );
      case _MoreAction.about:
        break;
    }
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

  Widget _buildLogoutSection(BuildContext context) {
    if (!_signedIn) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () async {
          await AuthService.logout();
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.logoutSuccess)),
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
        child: Text(
          AppStrings.logout,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryYellow,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
