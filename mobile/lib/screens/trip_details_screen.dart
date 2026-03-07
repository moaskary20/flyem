import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/trip_payment_screen.dart';
import 'package:flyem_app/services/trips_service.dart';

/// شاشة تفاصيل الرحلة — تصميم موحد مع شاشة تفاصيل الشحنة.
class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final int tripId;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  TripDetails? _trip;
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
      final t = await TripsService.getTrip(widget.tripId);
      if (mounted) setState(() {
        _trip = t;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = 'فشل تحميل تفاصيل الرحلة';
      });
    }
  }

  void _onSendRequest() {
    if (_trip == null) return;
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
      textDirection: TextDirection.rtl,
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
                          FilledButton(onPressed: _load, child: const Text('إعادة المحاولة')),
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
                                  title: Text(
                                    _trip!.fromDisplay,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  actions: [
                                    Icon(Icons.flight, color: AppColors.primaryYellow, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      _trip!.toDisplay,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildOriginDestination(),
                                        const SizedBox(height: 20),
                                        _buildInfoCard(
                                          title: 'وسيلة السفر',
                                          children: [
                                            _buildDetailRow(
                                              label: 'نوع الرحلة',
                                              value: _trip!.travelMethodLabel,
                                              icon: Icons.directions_transit,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoCard(
                                          title: 'الوزن والتسعير',
                                          children: [
                                            _buildDetailRow(
                                              label: 'الوزن المتاح',
                                              value: '${_trip!.availableWeight} ${_trip!.weightUnit}',
                                              icon: Icons.luggage,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: 'الوزن الكلي',
                                              value: '${_trip!.availableWeight} ${_trip!.weightUnit}',
                                              icon: Icons.scale,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: 'سعر الكيلو',
                                              value: '${_trip!.currencySymbol}${_trip!.pricePerKg.toStringAsFixed(1)}',
                                              icon: Icons.paid,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoCard(
                                          title: 'التواريخ',
                                          children: [
                                            _buildDetailRow(
                                              label: 'تاريخ المغادرة',
                                              value: _formatDateTime(_trip!.departureDate),
                                              icon: Icons.calendar_today,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: 'تاريخ الوصول',
                                              value: _formatDateTime(_trip!.returnDate),
                                              icon: Icons.event,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: 'الفترة المتاحة لتسليم الشحنة',
                                              value: _trip!.departureDate != null || _trip!.returnDate != null
                                                  ? '${_formatDateTime(_trip!.departureDate)} — ${_formatDateTime(_trip!.returnDate)}'
                                                  : 'غير محدد',
                                              icon: Icons.schedule,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoCard(
                                          title: 'مناطق تسلم الشحنة',
                                          children: [
                                            _buildDetailRow(
                                              label: 'من',
                                              value: _trip!.fromDisplay,
                                              icon: Icons.location_on,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              label: 'إلى',
                                              value: _trip!.toDisplay,
                                              icon: Icons.place,
                                            ),
                                          ],
                                        ),
                                        if (_trip!.notes != null && _trip!.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          _buildInfoCard(
                                            title: 'ملاحظات',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _trip!.fromCity.isNotEmpty ? _trip!.fromCity : _trip!.fromCountry,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _trip!.fromCountry,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 3, width: 40, color: AppColors.primaryYellow),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.flight, color: AppColors.primaryYellow, size: 28),
              ),
              Container(height: 3, width: 40, color: AppColors.primaryYellow),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _trip!.toCity.isNotEmpty ? _trip!.toCity : _trip!.toCountry,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _trip!.toCountry,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
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
        Text(
          _trip!.userName ?? '—',
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
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _onSendRequest,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('إرسال طلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سعر الكيلو',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${_trip!.currencySymbol}${_trip!.pricePerKg.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
