import 'package:flutter/material.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/shipment_list_item.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/add_shipment_screen.dart';
import 'package:flyem_app/screens/my_shipment_tabs_screen.dart';
import 'package:flyem_app/screens/trip_details_screen.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/shipment_result_card.dart';
import 'package:flyem_app/widgets/trip_result_card.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<ShipmentsListResponse> _future;
  bool _loading = true;
  String? _error;
  List<ShipmentListItem>? _myShipmentsList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 1, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = await AuthService.getUserId();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _myShipmentsList = null;
      _future = ShipmentsService.getMyShipments(userId: userId);
    });
    _future.then((res) {
      if (mounted) setState(() {
        _loading = false;
        _myShipmentsList = res.data;
      });
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    });
  }

  Future<void> _openAddShipment() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddShipmentScreen()),
    );
    if (added == true && mounted) _load();
  }

  static const Color _appBarDark = Color(0xFF2C2C2E);
  static const Color _tabBarGrey = Color(0xFF383838);

  bool get _hasShipments =>
      _myShipmentsList != null && _myShipmentsList!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: _appBarDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: _openAddShipment,
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: AppStrings.addNewShipment,
          ),
          title: Text(
            AppStrings.navShipments,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: const [],
          bottom: _hasShipments
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: _tabBarGrey,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primaryYellow,
                      indicatorWeight: 3,
                      labelColor: AppColors.primaryYellow,
                      unselectedLabelColor: Colors.grey[400],
                      tabs: const [
                        Tab(text: AppStrings.tabSuitableTrips),
                        Tab(text: AppStrings.tabDetails),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError();
    }
    if (!_hasShipments) {
      return _buildEmptyState();
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _SuitableTripsTab(future: _future),
        _buildDetailsTab(),
      ],
    );
  }

  Widget _buildDetailsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError();
    }
    return FutureBuilder<ShipmentsListResponse>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final res = snapshot.data!;
        if (res.data.isEmpty) {
          return _buildEmptyState();
        }
        return _buildList(res);
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildBoxIllustration(),
            const SizedBox(height: 28),
            Text(
              AppStrings.noShipments,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.addNow,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _openAddShipment,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(AppStrings.addYourShipment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxIllustration() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryYellow.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navBarBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navBarBackground.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navBarBackground.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ShipmentsListResponse res) {
    final list = res.data;
    return RefreshIndicator(
      onRefresh: () async {
        _load();
        await _future;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return ShipmentResultCard(
            productName: item.title,
            fromCode: item.fromCode,
            toCode: item.toCode,
            date: item.deadlineFormatted ?? '',
            userName: item.user?.name ?? '',
            rewardAmount: '${item.currencySymbol}${item.priceMin}',
            rating: item.user?.rating ?? 0,
            imageUrl: item.imageUrl,
            userPhotoUrl: item.user?.profilePhoto,
            shipmentId: item.id,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MyShipmentTabsScreen(shipmentId: item.id),
                ),
              );
            },
            actionButtonText: AppStrings.edit,
            onActionButtonTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                final details = await ShipmentsService.getShipment(item.id);
                if (!context.mounted) return;
                Navigator.pop(context); // close dialog
                final added = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AddShipmentScreen(
                      shipmentToEdit: details,
                      isEditing: true,
                    ),
                  ),
                );
                if (added == true && context.mounted) {
                  _load();
                }
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل جلب التفاصيل')),
                );
              }
            },
          );
        },
      ),
    );
  }

}

class _SuitableTripsTab extends StatefulWidget {
  const _SuitableTripsTab({required this.future});

  final Future<ShipmentsListResponse> future;

  @override
  State<_SuitableTripsTab> createState() => _SuitableTripsTabState();
}

class _SuitableTripsTabState extends State<_SuitableTripsTab> {
  int? _selectedShipmentId;
  ShipmentDetails? _details;
  List<TripItem> _trips = [];
  bool _loadingTrips = false;
  String? _tripsError;

  Future<void> _fetchTripsForShipment(int shipmentId) async {
    setState(() {
      _loadingTrips = true;
      _tripsError = null;
      _details = null;
      _trips = [];
    });
    try {
      final details = await ShipmentsService.getShipment(shipmentId);
      if (!mounted) return;
      final fromId = details.fromCountryId;
      final toId = details.toCountryId;
      final fromCityId = details.fromCityId;
      final toCityId = details.toCityId;
      if (fromId == null || toId == null) {
        if (mounted) {
          setState(() {
            _details = details;
            _trips = [];
            _loadingTrips = false;
            _tripsError = 'الشحنة لا تحتوي على من/إلى';
          });
        }
        return;
      }
      if (mounted) setState(() => _details = details);
      final response = await TripsService.getTripsForSearch(
        fromCountryId: fromId,
        toCountryId: toId,
        fromCityId: fromCityId,
        toCityId: toCityId,
        perPage: 20,
      );
      if (mounted) {
        setState(() {
          _trips = response.data;
          _loadingTrips = false;
          _tripsError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tripsError = e.toString();
          _loadingTrips = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ShipmentsListResponse>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final res = snapshot.data!;
        final list = res.data;
        if (list.isEmpty) {
          return Center(
            child: Text(
              'لا توجد شحنات. أضف شحنة أولاً.',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
              textAlign: TextAlign.center,
            ),
          );
        }
        final singleShipment = list.length == 1;
        final selectedInList = _selectedShipmentId != null && list.any((s) => s.id == _selectedShipmentId);
        final effectiveId = selectedInList ? _selectedShipmentId! : list.first.id;
        if (list.isNotEmpty && (!selectedInList || _selectedShipmentId == null)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final id = list.first.id;
              setState(() => _selectedShipmentId = id);
              _fetchTripsForShipment(id);
            }
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!singleShipment) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: DropdownButtonFormField<int>(
                  value: effectiveId,
                  decoration: InputDecoration(
                    labelText: 'اختر الشحنة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: list.map((s) {
                    return DropdownMenuItem<int>(
                      value: s.id,
                      child: Text('${s.title.isNotEmpty ? s.title : 'شحنة'} من ${s.fromCode} إلى ${s.toCode}'),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null && id != _selectedShipmentId) {
                      setState(() => _selectedShipmentId = id);
                      _fetchTripsForShipment(id);
                    }
                  },
                ),
              ),
            ],
            if (_details != null && !_loadingTrips && _tripsError == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'رحلات مناسبة لشحنتك: من ${_details!.fromName.isNotEmpty ? _details!.fromName : _details!.fromCode} إلى ${_details!.toName.isNotEmpty ? _details!.toName : _details!.toCode}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: _buildTripsContent(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTripsContent() {
    if (_loadingTrips) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tripsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'حدث خطأ أثناء جلب الرحلات: $_tripsError',
                style: TextStyle(color: Colors.red[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _selectedShipmentId != null
                    ? () => _fetchTripsForShipment(_selectedShipmentId!)
                    : null,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (_trips.isEmpty && _details != null) {
      return Center(
        child: Text(
          'لا توجد رحلات مناسبة في الوقت الحالي',
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
      );
    }
    if (_trips.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return TripResultCard(
          item: trip,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripDetailsScreen(tripId: trip.id),
              ),
            );
          },
        );
      },
    );
  }
}
