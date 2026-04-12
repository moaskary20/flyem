import 'package:flutter/material.dart';
import 'package:flyem_app/core/auth_guard.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/trip_payment_screen.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/widgets/user_profile_link.dart';

/// شاشة تفاصيل الرحلة — تصميم موحد مع شاشة تفاصيل الشحنة.
class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.tripId,
    /// عند الفتح من «رحلاتي»: لا يُعرض زر إرسال الطلب (رحلتك الخاصة).
    this.openedFromMyTrips = false,
  });

  final int tripId;
  final bool openedFromMyTrips;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  TripDetails? _trip;
  int? _myUserId;
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
    try {
      final results = await Future.wait<dynamic>([
        TripsService.getTrip(widget.tripId),
        AuthService.getUserId(),
      ]);
      if (mounted) {
        setState(() {
          _trip = results[0] as TripDetails;
          _myUserId = results[1] as int?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = AppStrings.loadFailedTrip;
      });
    }
  }

  Future<void> _onSendRequest() async {
    if (_trip == null) return;
    if (!await ensureAccountActiveForMarketplace(context)) {
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripPaymentScreen(tripId: widget.tripId, trip: _trip!),
      ),
    );
  }

  String _formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final parts = iso.split(' ');
      if (parts.length >= 1) {
        final d = parts[0].split('-');
        if (d.length == 3) return '${d[2]}/${d[1]}/${d[0]}${parts.length > 1 ? ' ${parts[1].substring(0, 5)}' : ''}';
      }
    } catch (_) {}
    return iso;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                          FilledButton(onPressed: _load, child: Text(AppStrings.retry)),
                        ],
                      ),
                    ),
                  )
                : _trip == null
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              slivers: [
                                SliverAppBar(
                                  expandedHeight: 0,
                                  pinned: true,
                                  backgroundColor: AppColors.navBarBackground,
                                  foregroundColor: Colors.white,
                                  leading: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  title: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '${_trip!.fromDisplay} → ${_trip!.toDisplay}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildOriginDestination(),
                                        const SizedBox(height: 12),
                                        Text(
                                          AppStrings.appTripNumber(_trip!.id),
                                          style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 20),
                                        _buildInfoCard(
                                          title: AppStrings.detailTravelMethod,
                                          children: [
                                            _buildDetailRow(
                                              label: AppStrings.detailTripType,
                                              value: _trip!.travelMethodLabel,
                                              icon: Icons.directions_transit,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoCard(
                                          title: AppStrings.detailDates,
                                          children: [
                                            _buildDetailRow(
                                              label: AppStrings.detailDepartureDate,
                                              value: _formatDateTime(_trip!.departureDate),
                                              icon: Icons.calendar_today,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: AppStrings.detailArrivalDate,
                                              value: _formatDateTime(_trip!.returnDate),
                                              icon: Icons.event,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: AppStrings.detailDeliveryWindow,
                                              value: _trip!.departureDate != null || _trip!.returnDate != null
                                                  ? '${_formatDateTime(_trip!.departureDate)} — ${_formatDateTime(_trip!.returnDate)}'
                                                  : AppStrings.unspecified,
                                              icon: Icons.schedule,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoCard(
                                          title: AppStrings.detailPickupAreas,
                                          children: [
                                            _buildDetailRow(
                                              label: AppStrings.labelFrom,
                                              value: _trip!.fromDisplay,
                                              icon: Icons.location_on,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: AppStrings.labelTo,
                                              value: _trip!.toDisplay,
                                              icon: Icons.place,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoCard(
                                          title: AppStrings.pickupDeliveryOptionsTitle,
                                          children: [
                                            _buildDetailRow(
                                              label: AppStrings.canPickupInCurrentCountry,
                                              value: _trip!.canPickupInCurrentCountry ? AppStrings.yes : AppStrings.no,
                                              icon: Icons.inventory_2_outlined,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: AppStrings.canDeliverInOtherCountry,
                                              value: _trip!.canDeliverInOtherCountry ? AppStrings.yes : AppStrings.no,
                                              icon: Icons.local_shipping_outlined,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: AppStrings.canReturnOnCancel,
                                              value: _trip!.canReturnOnCancel
                                                  ? (_trip!.returnBeforeDays != null
                                                      ? AppStrings.returnBeforeDaysLabel(_trip!.returnBeforeDays!)
                                                      : AppStrings.yes)
                                                  : AppStrings.no,
                                              icon: Icons.reply_outlined,
                                            ),
                                          ],
                                        ),
                                        if (_trip!.notes != null && _trip!.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          _buildInfoCard(
                                            title: AppStrings.detailNotes,
                                            children: [
                                              Text(
                                                _trip!.notes!,
                                                style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        _buildPublisherRow(),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildBottomBar(),
                        ],
                      ),
      ),
    );
  }

  Widget _buildOriginDestination() {
    final fromMain = _trip!.fromCity.isNotEmpty ? _trip!.fromCity : _trip!.fromCountry;
    final toMain = _trip!.toCity.isNotEmpty ? _trip!.toCity : _trip!.toCountry;
    final caption = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.routeLabelFrom, style: caption),
                Text(
                  fromMain,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _trip!.fromCountry,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 2, color: AppColors.primaryYellow),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(Icons.arrow_forward, color: AppColors.primaryYellow, size: 26),
                ),
                Container(width: 12, height: 2, color: AppColors.primaryYellow),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(AppStrings.routeLabelTo, style: caption),
                Text(
                  toMain,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
                Text(
                  _trip!.toCountry,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        if (icon != null) Icon(icon, color: AppColors.primaryYellow, size: 20),
        if (icon != null) const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPublisherRow() {
    return Row(
      children: [
        Text(
          AppStrings.postedBy,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Icon(Icons.person_outline, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 6),
        TappableUserName(
          userId: _trip!.userId,
          displayName: _trip!.userName ?? '—',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final trip = _trip;
    if (trip == null) return const SizedBox.shrink();

    if (widget.openedFromMyTrips) {
      return const SizedBox.shrink();
    }

    final isOwner =
        _myUserId != null && trip.userId != null && trip.userId == _myUserId;
    if (isOwner) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Text(
            AppStrings.cannotRequestOwnListing,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.35),
          ),
        ),
      );
    }

    final alreadyRequested = trip.userHasRequested;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton(
          onPressed: alreadyRequested ? null : _onSendRequest,
          style: FilledButton.styleFrom(
            backgroundColor: alreadyRequested ? Colors.grey : AppColors.primaryYellow,
            foregroundColor: Colors.black87,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            alreadyRequested ? AppStrings.requestAlreadySent : AppStrings.sendRequest,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
