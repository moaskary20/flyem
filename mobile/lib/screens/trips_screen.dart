import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/add_trip_form_screen.dart';
import 'package:flyem_app/screens/trip_details_screen.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/filter_sheet.dart';
import 'package:image_picker/image_picker.dart';

void _showAddTripPassportSheet(BuildContext context, {VoidCallback? onTripAdded}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddTripPassportSheet(
      hostContext: context,
      onTripAdded: onTripAdded,
    ),
  );
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<TripItem> _trips = [];
  bool _loading = true;
  String? _error;
  TripsFilterResult? _filter;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final dep = _filter?.departureAfterStr;
    try {
      final userId = await AuthService.getUserId();
      final res = await TripsService.getMyTrips(
        userId: userId,
        fromCountryId: _filter?.fromPlace?.countryId,
        toCountryId: _filter?.toPlace?.countryId,
        fromCityId: _filter?.fromPlace?.cityId,
        toCityId: _filter?.toPlace?.cityId,
        departureAfter: dep,
      );
      if (mounted) {
        setState(() {
          _trips = res.data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _onTripAdded() {
    _loadTrips();
  }

  Future<void> _openFilter() async {
    await showTripsFilterSheet(
      context,
      initial: _filter,
      onApply: (result) {
        setState(() => _filter = result);
        _loadTrips();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTrips = _trips.isNotEmpty;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          centerTitle: true,
          title: const SizedBox.shrink(),
          leading: hasTrips ? null : _buildSortButton(iconOnly: true),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorContent()
                  : hasTrips
                      ? _buildWithTripsContent()
                      : _buildEmptyContent(),
        ),
      ),
    );
  }

  /// iconOnly: true في الـ AppBar (leading) لتجنب overflow؛ false في المحتوى لعرض النص كاملاً.
  Widget _buildSortButton({bool iconOnly = false}) {
    if (iconOnly) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          onPressed: _openFilter,
          icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.buttonDark,
            padding: const EdgeInsets.all(10),
          ),
        ),
      );
    }
    return Material(
      color: AppColors.buttonDark,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _openFilter,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                AppStrings.sort,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithTripsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رحلاتي',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_trips.length} ${_trips.length == 1 ? 'رحلة' : 'رحلات'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildSortButton(),
                  const SizedBox(width: 10),
                  Material(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 0,
                    child: InkWell(
                      onTap: () => _showAddTripPassportSheet(context, onTripAdded: _onTripAdded),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.black87, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.addNewTrip,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._trips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TripCard(item: t, onDeleted: _loadTrips),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadTrips,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _AirplaneIllustration(),
            const SizedBox(height: 24),
            Text(
              AppStrings.tripsEmptyLine1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.tripsEmptyLine2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAddTripPassportSheet(context, onTripAdded: _onTripAdded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppStrings.addYourTrip,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {},
              child: Text(
                AppStrings.notBookedYet,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة رحلة واحدة (من - إلى، تاريخ المغادرة، الوزن، المكسب، الصفقات)
class _TripCard extends StatelessWidget {
  const _TripCard({required this.item, this.onDeleted});

  final TripItem item;
  final VoidCallback? onDeleted;

  Future<void> _confirmDeleteTrip(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteTrip),
        content: const Text(AppStrings.confirmDeleteTrip),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await TripsService.deleteTrip(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الرحلة')),
        );
        onDeleted?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الرحلة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TripDetailsScreen(tripId: item.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.primaryYellow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.fromDisplay,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryYellow.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.flight_rounded, size: 18, color: AppColors.primaryYellow),
                                      ),
                                    ),
                                    Text(
                                      item.toDisplay,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (details) {
                                  showMenu<String>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      details.globalPosition.dx,
                                      details.globalPosition.dy,
                                      details.globalPosition.dx + 1,
                                      details.globalPosition.dy + 1,
                                    ),
                                    items: [
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, size: 20, color: Colors.red[700]),
                                            const SizedBox(width: 8),
                                            Text(AppStrings.deleteTrip, style: TextStyle(color: Colors.red[700])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ).then((value) {
                                    if (value == 'delete') _confirmDeleteTrip(context);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.more_vert, size: 22, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                item.departureFormatted ?? item.departureDate ?? '',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.luggage_rounded, size: 16, color: AppColors.primaryYellow),
                              const SizedBox(width: 4),
                              Text(
                                '${item.availableWeight} ${item.weightUnit}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.handshake_rounded, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${item.confirmedDeals} ${AppStrings.confirmedDeals}',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.profitDisplay,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

/// رسمة طائرة صفراء ورمادية (أعلى أصفر، ذيل وأسفل أجنحة رمادي)
class _AirplaneIllustration extends StatelessWidget {
  const _AirplaneIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(4, 4),
            child: Icon(
              Icons.flight,
              size: 110,
              color: Colors.grey[700],
            ),
          ),
          Icon(
            Icons.flight,
            size: 110,
            color: AppColors.primaryYellow,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet لرفع جواز السفر قبل إضافة رحلة
class _AddTripPassportSheet extends StatefulWidget {
  const _AddTripPassportSheet({
    required this.hostContext,
    this.onTripAdded,
  });

  final BuildContext hostContext;
  final VoidCallback? onTripAdded;

  @override
  State<_AddTripPassportSheet> createState() => _AddTripPassportSheetState();
}

class _AddTripPassportSheetState extends State<_AddTripPassportSheet> {
  Uint8List? _passportImageBytes; // bytes يعمل على الويب والموبايل (Image.file غير مدعوم على الويب)
  bool _isPicking = false;

  Future<void> _openCamera() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        setState(() => _passportImageBytes = bytes);
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _onContinue() {
    Navigator.of(context).pop();
    showAddTripFormFromBottom(
      widget.hostContext,
      onTripAdded: widget.onTripAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 28,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.passportSheetLine1,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Text(
              AppStrings.passportSheetLine2,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.passportSheetLine3,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Text(
              AppStrings.passportSheetLine4,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isPicking ? null : _openCamera,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: _passportImageBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_passportImageBytes!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Text(
                              'اضغط لتغيير الصورة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isPicking)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.badge_outlined,
                              size: 48,
                              color: Colors.grey[500],
                            ),
                          if (!_isPicking) ...[
                            const SizedBox(height: 8),
                            Text(
                              'صورة جواز السفر',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppStrings.continueBtn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
