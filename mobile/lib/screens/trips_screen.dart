import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/edit_trip_screen.dart';
import 'package:flyem_app/screens/trip_details_screen.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:flyem_app/widgets/add_trip_passport_sheet.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<TripItem> _trips = [];
  bool _loading = true;
  String? _error;

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
    try {
      final userId = await AuthService.getUserId();
      final res = await TripsService.getMyTrips(userId: userId);
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

  @override
  Widget build(BuildContext context) {
    final hasTrips = _trips.isNotEmpty;
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          centerTitle: true,
          title: const SizedBox.shrink(),
          leading: null,
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
                  Material(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 0,
                    child: InkWell(
                      onTap: () => showAddTripPassportThenTripForm(context, onTripAdded: _onTripAdded),
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
                child: _TripCard(item: t, onDeleted: _loadTrips, onUpdated: _loadTrips),
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
                onPressed: () => showAddTripPassportThenTripForm(context, onTripAdded: _onTripAdded),
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
  const _TripCard({required this.item, this.onDeleted, this.onUpdated});

  final TripItem item;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  Future<void> _confirmDeleteTrip(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteTrip),
        content: Text(AppStrings.confirmDeleteTrip),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await TripsService.deleteTrip(item.id);
      if (context.mounted) {
        await LocalNotificationService.showNotification(
          id: LocalNotificationService.idForEvent('trip_deleted'),
          title: AppStrings.notificationTripDeleted,
          body: AppStrings.notificationTripDeleted,
        );
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
              builder: (_) => TripDetailsScreen(
                tripId: item.id,
                openedFromMyTrips: true,
              ),
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
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppStrings.routeLabelFrom,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              item.fromDisplay,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12, left: 6, right: 6),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 22,
                                          color: AppColors.primaryYellow,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              AppStrings.routeLabelTo,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              item.toDisplay,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 20, color: Colors.grey[800]),
                                            const SizedBox(width: 8),
                                            const Text('تعديل الرحلة'),
                                          ],
                                        ),
                                      ),
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
                                    if (value == 'edit') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditTripScreen(
                                            tripId: item.id,
                                            onUpdated: onUpdated,
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _confirmDeleteTrip(context);
                                    }
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
