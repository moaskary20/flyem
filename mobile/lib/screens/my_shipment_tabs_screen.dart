import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/widgets/shipment_detail_content.dart';
import 'package:flyem_app/core/auth_guard.dart';
import 'package:flyem_app/screens/add_shipment_screen.dart' as flyem_app_add_shipment;
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/widgets/trip_result_card.dart';
import 'package:flyem_app/screens/trip_details_screen.dart';

/// شاشة شحنتي بعد النشر: ثلاثة تبويبات (الصفقات - الرحلات المناسبة - التفاصيل).
class MyShipmentTabsScreen extends StatelessWidget {
  const MyShipmentTabsScreen({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: FutureBuilder<ShipmentDetails>(
        future: ShipmentsService.getShipment(shipmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              appBar: AppBar(
                backgroundColor: AppColors.navBarBackground,
                foregroundColor: Colors.white,
                title: const Text(''),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.navBarBackground,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.hasError ? snapshot.error.toString() : 'لا توجد بيانات',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('رجوع'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _TabsContent(shipment: snapshot.data!);
        },
      ),
    );
  }
}

class _TabsContent extends StatelessWidget {
  const _TabsContent({required this.shipment});

  final ShipmentDetails shipment;

  static const Color _headerDark = Color(0xFF2C2C2E);
  static const Color _tabBarGrey = Color(0xFF383838);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            shipment.title.isEmpty ? AppStrings.shipmentGeneric : shipment.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton.icon(
              onPressed: () async {
                if (!await ensureLoggedIn(context) || !context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const flyem_app_add_shipment.AddShipmentScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 22, color: Colors.white),
              label: Text(
                AppStrings.addNewShipment,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: _tabBarGrey,
              child: TabBar(
                      indicatorColor: AppColors.primaryYellow,
                      indicatorWeight: 3,
                      labelColor: AppColors.primaryYellow,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
                        Tab(text: AppStrings.tabDeals),
                        Tab(text: AppStrings.tabSuitableTrips),
                        Tab(text: AppStrings.tabDetails),
                      ],
                    ),
                  ),
                ),
          ),
        body: TabBarView(
          children: [
            _DealsTab(),
            _SuitableTripsTab(shipment: shipment),
            ShipmentDetailContent(
              shipment: shipment,
              onEdited: () => Navigator.of(context).pop(true),
              onDelete: () async {
                try {
                  await ShipmentsService.deleteShipment(shipment.id);
                  if (!context.mounted) return;
                  await LocalNotificationService.showNotification(
                    id: LocalNotificationService.idForEvent('shipment_deleted'),
                    title: AppStrings.notificationShipmentDeleted,
                    body: AppStrings.notificationShipmentDeleted,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الشحنة')),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('فشل حذف الشحنة'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DealsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'لا توجد صفقات',
        style: TextStyle(color: Colors.grey[600], fontSize: 15),
      ),
    );
  }
}

class _SuitableTripsTab extends StatefulWidget {
  final ShipmentDetails shipment;
  const _SuitableTripsTab({required this.shipment});

  @override
  State<_SuitableTripsTab> createState() => _SuitableTripsTabState();
}

class _SuitableTripsTabState extends State<_SuitableTripsTab> {
  bool _isLoading = true;
  String? _error;
  List<TripItem> _trips = [];

  @override
  void initState() {
    super.initState();
    _fetchSuitableTrips();
  }

  Future<void> _fetchSuitableTrips() async {
    try {
      final response = await TripsService.getTripsForSearch(
        fromCountryId: widget.shipment.fromCountryId,
        toCountryId: widget.shipment.toCountryId,
        fromCityId: widget.shipment.fromCityId,
        toCityId: widget.shipment.toCityId,
        // Uncomment the deadline matching if the API supports filtering by deadline
        // departureAfter: widget.shipment.deadlineFormatted, 
        perPage: 20,
      );
      if (mounted) {
        setState(() {
          _trips = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'حدث خطأ أثناء جلب الرحلات: $_error',
          style: TextStyle(color: Colors.red[600], fontSize: 15),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_trips.isEmpty) {
      return Center(
        child: Text(
          'لا توجد رحلات مناسبة في الوقت الحالي',
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TripResultCard(
          item: _trips[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripDetailsScreen(tripId: _trips[index].id),
              ),
            );
          },
        );
      },
    );
  }
}
