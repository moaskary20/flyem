import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/services/auth_service.dart';

/// ملف عام لمستخدم آخر: الاسم الأول، تقييم، دولتان؛ صورة واسم العائلة مشوشان ولا يُعرض رقم.
class PublicUserProfileScreen extends StatefulWidget {
  const PublicUserProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  State<PublicUserProfileScreen> createState() => _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {
  PublicUserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final p = await AuthService.getPublicUserProfile(widget.userId);
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
      _error = p == null ? 'تعذّر تحميل الملف' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.navBarBackground,
          foregroundColor: Colors.white,
          title: Text(AppStrings.publicProfileTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                        ],
                      ),
                    ),
                  )
                : _profile == null
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                child: ClipOval(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[400],
                                    alignment: Alignment.center,
                                    child: Icon(Icons.person, size: 52, color: Colors.grey[100]),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _profile!.firstName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (_profile!.hasLastName) ...[
                                  const SizedBox(width: 10),
                                  ImageFiltered(
                                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Text(
                                      '████',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (_profile!.hasLastName)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  AppStrings.lastNameHidden,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...List.generate(5, (i) {
                                  final r = _profile!.rating;
                                  final filled = i < r.floor() || (i == r.floor() && r % 1 >= 0.5);
                                  return Icon(
                                    filled ? Icons.star : Icons.star_border,
                                    size: 26,
                                    color: filled ? AppColors.primaryYellow : Colors.grey[400],
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  _profile!.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _countryCard(
                              AppStrings.homeCountryLabel,
                              _profile!.homeCountryName.isNotEmpty ? _profile!.homeCountryName : '—',
                            ),
                            const SizedBox(height: 12),
                            _countryCard(
                              AppStrings.travelCountryLabel,
                              _profile!.travelCountryName.isNotEmpty ? _profile!.travelCountryName : '—',
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _countryCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
