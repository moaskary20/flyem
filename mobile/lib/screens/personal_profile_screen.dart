import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/services/auth_service.dart';

/// شاشة الصفحة الشخصية: بيانات المستخدم من قاعدة البيانات (API).
class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  UserProfile? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (mounted) setState(() {
        _user = user;
        _loading = false;
        _error = user == null ? 'فشل تحميل البيانات' : null;
      });
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = 'فشل تحميل البيانات';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _user == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _loadUser,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildYellowHeader(context)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              _buildBasicInfoSection(),
                              const SizedBox(height: 24),
                              _buildRatingsSection(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildYellowHeader(BuildContext context) {
    final name = _user?.name.isNotEmpty == true ? _user!.name : 'المستخدم';
    final shipmentsCount = _user?.shipmentsCount ?? 0;
    final tripsCount = _user?.tripsCount ?? 0;

    return Container(
      width: double.infinity,
      color: AppColors.primaryYellow,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      AppStrings.edit,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 48, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_outlined, size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.documentsVerified,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 18, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.phoneVerified,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatChip(icon: Icons.handshake_outlined, count: 0, label: AppStrings.dealsCount),
                            _StatChip(icon: Icons.inventory_2_outlined, count: shipmentsCount, label: AppStrings.shipmentsCount),
                            _StatChip(icon: Icons.luggage_outlined, count: tripsCount, label: AppStrings.tripsCount),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final email = _user?.email ?? '';
    final phone = _user?.phone ?? '';
    final hasPhone = phone.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.basicInfo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _InfoRow(
          label: AppStrings.emailLabel,
          value: email.isNotEmpty ? email : '—',
          verified: true,
        ),
        const SizedBox(height: 14),
        Text(
          AppStrings.phoneNumbersLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _InfoRow(
          label: AppStrings.phoneForHomeland,
          value: hasPhone ? phone : AppStrings.noPhoneEntered,
          verified: hasPhone,
        ),
        const SizedBox(height: 10),
        _InfoRow(
          label: AppStrings.phoneForTravel,
          value: hasPhone ? phone : AppStrings.noPhoneEntered,
          verified: hasPhone,
        ),
      ],
    );
  }

  Widget _buildRatingsSection() {
    const ratingCount = 0; // يمكن إضافته من الـ API لاحقاً

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$ratingCount ${AppStrings.ratingsSection}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              AppStrings.travelerRating,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (_) => Icon(Icons.star_border, size: 20, color: Colors.grey[400])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              AppStrings.shipperRating,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (_) => Icon(Icons.star_border, size: 20, color: Colors.grey[400])),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            AppStrings.noRatings,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(height: 4),
        Text(
          '$count $label',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.verified,
  });

  final String label;
  final String value;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (verified)
          Icon(Icons.check_circle, size: 22, color: Colors.blue[700]),
      ],
    );
  }
}
