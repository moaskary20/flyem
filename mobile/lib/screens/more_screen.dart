import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/personal_profile_screen.dart';
import 'package:flyem_app/screens/payment_details_screen.dart';
import 'package:flyem_app/screens/coupons_screen.dart';
import 'package:flyem_app/screens/settings_screen.dart';
import 'package:flyem_app/screens/technical_support_screen.dart';
import 'package:flyem_app/screens/faq_screen.dart';
import 'package:flyem_app/screens/privacy_terms_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  UserProfile? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final name = _loading ? '...' : (_user?.name.isNotEmpty == true ? _user!.name : 'المستخدم');
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PersonalProfileScreen(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(AppStrings.personalPage),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    final options = [
      (AppStrings.settings, Icons.settings),
      (AppStrings.paymentDetails, Icons.account_balance_outlined),
      (AppStrings.coupons, Icons.card_giftcard_outlined),
      (AppStrings.wishlist, Icons.star_border),
      (AppStrings.faq, Icons.chat_bubble_outline),
      (AppStrings.privacyAndTerms, Icons.description_outlined),
      (AppStrings.technicalSupport, Icons.help_outline),
      (AppStrings.shareApp, Icons.share_outlined),
      (AppStrings.aboutApp, Icons.info_outline),
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
              label: options[i].$1,
              icon: options[i].$2,
              onTap: () {
                if (options[i].$1 == AppStrings.paymentDetails) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaymentDetailsScreen(),
                    ),
                  );
                } else if (options[i].$1 == AppStrings.coupons) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CouponsScreen(),
                    ),
                  );
                } else if (options[i].$1 == AppStrings.settings) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                } else if (options[i].$1 == AppStrings.shareApp) {
                  Share.share(
                    'جرب تطبيق فلاي إم - منصة الشحن بين المسافرين 🧳✈️\n'
                    'https://play.google.com/store/apps/details?id=com.flyem.app',
                    subject: 'تطبيق فلاي إم',
                  );
                } else if (options[i].$1 == AppStrings.technicalSupport) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TechnicalSupportScreen(),
                    ),
                  );
                } else if (options[i].$1 == AppStrings.faq) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FaqScreen(),
                    ),
                  );
                } else if (options[i].$1 == AppStrings.privacyAndTerms) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyTermsScreen(),
                    ),
                  );
                }
              },
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
