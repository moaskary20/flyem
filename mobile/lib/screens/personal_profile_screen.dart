import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/api_http_client.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/city.dart';
import 'package:flyem_app/models/country.dart';
import 'package:flyem_app/screens/edit_profile_screen.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/services/shipments_service.dart';
/// شاشة الصفحة الشخصية: بيانات المستخدم من قاعدة البيانات (API).
/// [openedFromMarketplaceGate] يُضبط عند الفتح من حوار «الحساب غير جاهز» قبل إرسال طلب.
class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key, this.openedFromMarketplaceGate = false});

  final bool openedFromMarketplaceGate;

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  UserProfile? _user;
  bool _loading = true;
  String? _error;
  int _photoKey = 0;
  /// رابط الصورة بعد الحفظ مباشرة.
  String? _profilePhotoUrlOverride;
  /// بايتات الصورة بعد الحفظ (عرض فوري دون طلب شبكة).
  Uint8List? _profilePhotoBytesOverride;
  final Map<String, Future<Uint8List?>> _profileImageCache = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _openEditProfilePhoto() async {
    try {
      final result = await Navigator.of(context).push<Object>(
        MaterialPageRoute(
          builder: (_) => EditProfileScreen(
            currentPhotoUrl: _user?.profilePhoto,
          ),
        ),
      );
      if (!mounted) return;
      if (result is List && result.length >= 2 && result[0] is String && result[1] is Uint8List) {
        setState(() {
          _profilePhotoUrlOverride = result[0] as String;
          _profilePhotoBytesOverride = result[1] as Uint8List;
          _photoKey = DateTime.now().millisecondsSinceEpoch;
        });
      } else if (result is String) {
        setState(() {
          _profilePhotoUrlOverride = result;
          _profilePhotoBytesOverride = null;
          _photoKey = DateTime.now().millisecondsSinceEpoch;
        });
      }
      if (result != null) await _loadUser();
    } catch (_) {
      if (mounted) _loadUser();
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        if (user != null) {
          _user = user;
          _error = null;
        } else if (_user == null) {
          _error = 'فشل تحميل البيانات';
        }
        _loading = false;
        _photoKey = DateTime.now().millisecondsSinceEpoch;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          if (_user == null) {
            _error = 'فشل تحميل البيانات';
          }
        });
      }
    }
  }

  String _documentVerificationLabel(UserProfile u) {
    if (u.documentsVerified) {
      return AppStrings.documentsVerified;
    }
    switch (u.verificationStatus) {
      case 'rejected':
        return AppStrings.documentsRejectedShort;
      case 'pending':
        return AppStrings.pendingVerification;
      default:
        return AppStrings.documentsVerificationIncomplete;
    }
  }

  Widget _buildMarketplaceStatusCard() {
    final u = _user;
    if (u == null) {
      return const SizedBox.shrink();
    }
    final ok = u.canUseMarketplace;
    final banned = u.isBanned;
    Color borderColor;
    Color bg;
    IconData icon;
    if (ok) {
      borderColor = Colors.green.shade300;
      bg = Colors.green.shade50;
      icon = Icons.check_circle_outline;
    } else if (banned) {
      borderColor = Colors.red.shade300;
      bg = Colors.red.shade50;
      icon = Icons.block;
    } else {
      borderColor = Colors.orange.shade300;
      bg = Colors.orange.shade50;
      icon = Icons.info_outline;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.black87, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.accountAndVerificationSectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            banned
                ? AppStrings.accountStatusLabelBanned
                : u.accountActive
                    ? AppStrings.accountStatusLabelActive
                    : AppStrings.accountStatusLabelInactive,
            style: TextStyle(fontSize: 14, height: 1.35, color: Colors.grey[900]),
          ),
          const SizedBox(height: 8),
          Text(
            _documentVerificationLabel(u),
            style: TextStyle(fontSize: 14, height: 1.35, color: Colors.grey[800]),
          ),
          if (!ok) ...[
            const SizedBox(height: 10),
            Text(
              AppStrings.marketplaceBlockedCardBodyGeneric,
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey[700]),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.marketplaceReadyCardBody,
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey[800]),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
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
                            child: Text(AppStrings.retry),
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
                              const SizedBox(height: 16),
                              _buildMarketplaceStatusCard(),
                              const SizedBox(height: 24),
                              _buildBasicInfoSection(),
                              const SizedBox(height: 24),
                              _buildLocationSection(),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 8, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openEditProfilePhoto,
                        customBorder: const CircleBorder(),
                        child: _buildProfileAvatar(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      Icon(
                        _user?.documentsVerified == true ? Icons.verified_outlined : Icons.schedule,
                        size: 18,
                        color: _user?.documentsVerified == true ? Colors.grey[700] : Colors.grey[600],
                      ),
                      Text(
                        _user != null
                            ? _documentVerificationLabel(_user!)
                            : AppStrings.documentsVerificationIncomplete,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      Icon(
                        _user?.phoneVerified == true ? Icons.check_circle : Icons.schedule,
                        size: 18,
                        color: _user?.phoneVerified == true ? Colors.blue[700] : Colors.grey[600],
                      ),
                      Text(
                        _user?.phoneVerified == true
                            ? AppStrings.phoneVerified
                            : AppStrings.pendingPhoneVerification,
                        textAlign: TextAlign.center,
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
    );
  }

  Future<Uint8List?> _loadProfileImageBytes(String url) async {
    final cleanUrl = _sanitizePhotoUrl(url);
    if (cleanUrl.isEmpty) return null;
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null || !uri.hasScheme) return null;
    final client = getApiClient();
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  static String _sanitizePhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.replaceAll(RegExp(r'\s'), '').trim();
  }

  Widget _buildProfileAvatar() {
    if (_profilePhotoBytesOverride != null && _profilePhotoBytesOverride!.isNotEmpty) {
      return SizedBox(
        width: 80,
        height: 80,
        child: ClipOval(
          child: Image.memory(
            _profilePhotoBytesOverride!,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          ),
        ),
      );
    }
    final raw = _sanitizePhotoUrl(_profilePhotoUrlOverride ?? _user?.profilePhoto);
    final photoUrl = raw.isNotEmpty
        ? (raw.startsWith('http') ? raw : '${kApiBaseUrl.replaceAll(RegExp(r'/$'), '')}/${raw.startsWith('/') ? raw.substring(1) : raw}')
        : null;
    final urlWithCache = photoUrl != null && photoUrl.isNotEmpty
        ? '$photoUrl${photoUrl.contains('?') ? '&' : '?'}v=$_photoKey'
        : null;
    if (urlWithCache == null) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 48, color: Colors.grey[600]),
      );
    }
    final future = _profileImageCache.putIfAbsent(
      urlWithCache,
      () => _loadProfileImageBytes(urlWithCache).catchError((_, __) => null),
    );
    return SizedBox(
      width: 80,
      height: 80,
      child: FutureBuilder<Uint8List?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return ClipOval(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 48, color: Colors.grey[600]),
          );
        },
      ),
    );
  }

  Widget _buildLocationSection() {
    final homeText = _user != null && (_user!.homeCountryName != null || _user!.homeCityName != null)
        ? '${_user!.homeCountryName ?? ''} - ${_user!.homeCityName ?? ''}'.replaceAll(RegExp(r'^\s*-\s*|-\s*$'), '').trim()
        : null;
    final travelText = _user != null && (_user!.travelCountryName != null || _user!.travelCityName != null)
        ? '${_user!.travelCountryName ?? ''} - ${_user!.travelCityName ?? ''}'.replaceAll(RegExp(r'^\s*-\s*|-\s*$'), '').trim()
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الدولة والمدينة',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _LocationRow(
          label: 'الدولة - المدينة (الأم)',
          value: homeText ?? 'غير محدد',
          onEdit: () => _showLocationPicker(isHome: true),
        ),
        const SizedBox(height: 12),
        _LocationRow(
          label: 'الدولة - المدينة (السفر)',
          value: travelText ?? 'غير محدد',
          onEdit: () => _showLocationPicker(isHome: false),
        ),
      ],
    );
  }

  Future<void> _showLocationPicker({required bool isHome}) async {
    List<Country>? countries;
    try {
      countries = await ShipmentsService.getCountries();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تحميل الدول')));
      return;
    }
    if (!mounted || countries.isEmpty) return;
    final currentCountryId = isHome ? _user?.homeCountryId : _user?.travelCountryId;
    final currentCityId = isHome ? _user?.homeCityId : _user?.travelCityId;
    Country? selectedCountry;
    if (currentCountryId != null) {
      try {
        selectedCountry = countries.firstWhere((c) => c.id == currentCountryId);
      } catch (_) {}
    }
    List<City> cities = [];
    City? selectedCity;
    if (selectedCountry != null) {
      try {
        cities = await ShipmentsService.getCities(selectedCountry.id);
        if (currentCityId != null) {
          try {
            selectedCity = cities.firstWhere((c) => c.id == currentCityId);
          } catch (_) {}
        }
        if (selectedCity == null && cities.isNotEmpty) selectedCity = cities.first;
      } catch (_) {}
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Directionality(
            textDirection: AppLocale.textDirection,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).padding.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isHome ? 'الدولة - المدينة (الأم)' : 'الدولة - المدينة (السفر)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Country>(
                    value: selectedCountry,
                    decoration: InputDecoration(
                      labelText: 'الدولة',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    items: (countries ?? <Country>[])
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                        .toList(),
                    onChanged: (c) async {
                      setModalState(() {
                        selectedCountry = c;
                        selectedCity = null;
                        cities = [];
                      });
                      if (c != null) {
                        final list = await ShipmentsService.getCities(c.id);
                        if (ctx.mounted) setModalState(() => cities = list);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedCountry != null)
                    DropdownButtonFormField<City>(
                      value: selectedCity,
                      decoration: InputDecoration(
                        labelText: 'المدينة',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      items: cities
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                          .toList(),
                      onChanged: (c) => setModalState(() => selectedCity = c),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: selectedCountry != null && selectedCity != null
                              ? () async {
                                  Navigator.of(ctx).pop();
                                  try {
                                    if (isHome) {
                                      await AuthService.updateProfile(
                                        homeCountryId: selectedCountry!.id,
                                        homeCityId: selectedCity!.id,
                                        travelCountryId: _user?.travelCountryId,
                                        travelCityId: _user?.travelCityId,
                                      );
                                    } else {
                                      await AuthService.updateProfile(
                                        homeCountryId: _user?.homeCountryId,
                                        homeCityId: _user?.homeCityId,
                                        travelCountryId: selectedCountry!.id,
                                        travelCityId: selectedCity!.id,
                                      );
                                    }
                                    if (mounted) {
                                      _loadUser();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppStrings.profileDataSaved)),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e')));
                                    }
                                  }
                                }
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('حفظ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showPhoneEditor({required bool isHome}) async {
    if (_user == null) return;
    final initial = isHome ? (_user!.homePhone ?? '') : (_user!.travelPhone ?? '');
    final controller = TextEditingController(text: initial);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: AppLocale.textDirection,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isHome ? AppStrings.phoneForHomeland : AppStrings.phoneForTravel,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppStrings.phoneLabel,
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(AppStrings.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final v = controller.text.trim();
                            Navigator.of(ctx).pop();
                            try {
                              if (isHome) {
                                await AuthService.updateProfile(homePhone: v);
                              } else {
                                await AuthService.updateProfile(travelPhone: v);
                              }
                              if (mounted) {
                                await _loadUser();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppStrings.profileDataSaved)),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$e')),
                                );
                              }
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black87,
                          ),
                          child: Text(AppStrings.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();
  }

  Widget _buildBasicInfoSection() {
    final email = _user?.email ?? '';
    final homePhone = _user?.homePhone ?? '';
    final travelPhone = _user?.travelPhone ?? '';

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
        _PhoneEditRow(
          label: AppStrings.phoneForHomeland,
          value: homePhone.isNotEmpty ? homePhone : AppStrings.unspecified,
          verified: homePhone.isNotEmpty,
          onEdit: () => _showPhoneEditor(isHome: true),
        ),
        const SizedBox(height: 10),
        _PhoneEditRow(
          label: AppStrings.phoneForTravel,
          value: travelPhone.isNotEmpty ? travelPhone : AppStrings.unspecified,
          verified: travelPhone.isNotEmpty,
          onEdit: () => _showPhoneEditor(isHome: false),
        ),
      ],
    );
  }

  Widget _buildRatingsSection() {
    final rating = _user?.rating;
    final count = _user?.ratingsCount ?? 0;
    final avg = rating != null && rating > 0 ? rating : 0.0;
    final fullStars = avg.floor();
    final hasHalf = (avg - fullStars) >= 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${AppStrings.ratingsSection}${count > 0 ? ' ($count)' : ''}',
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
              AppStrings.myRatingLabel,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (i) {
              if (i < fullStars) {
                return Icon(Icons.star, size: 20, color: Colors.amber[700]);
              }
              if (i == fullStars && hasHalf) {
                return Icon(Icons.star_half, size: 20, color: Colors.amber[700]);
              }
              return Icon(Icons.star_border, size: 20, color: Colors.grey[400]);
            }),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
        if (count == 0) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppStrings.noRatings,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
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

class _PhoneEditRow extends StatelessWidget {
  const _PhoneEditRow({
    required this.label,
    required this.value,
    required this.verified,
    required this.onEdit,
  });

  final String label;
  final String value;
  final bool verified;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (verified)
                    Icon(Icons.check_circle, size: 18, color: Colors.green[700]),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: Text(
            AppStrings.edit,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        TextButton(
          onPressed: onEdit,
          child: Text(
            AppStrings.edit,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
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
