import 'package:flutter/material.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/models/shipment_list_item.dart';
import 'package:flyem_app/screens/add_shipment_screen.dart';
import 'package:flyem_app/screens/my_shipment_tabs_screen.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/widgets/shipment_result_card.dart';
import 'package:flyem_app/widgets/shipment_detail_content.dart';
import 'package:flyem_app/widgets/filter_sheet.dart';

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
  ShipmentsFilterResult? _filter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 2, vsync: this);
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

  Future<void> _openFilter() async {
    await showShipmentsFilterSheet(
      context,
      initial: _filter,
      onApply: (result) {
        setState(() => _filter = result);
        _load();
      },
    );
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
          leading: (_hasShipments && _tabController.index == 2)
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: Colors.white,
                  onSelected: (value) async {
                    if (value == AppStrings.editShipment) {}
                    else if (value == AppStrings.deleteShipment) {
                      final firstId = _myShipmentsList?.isNotEmpty == true ? _myShipmentsList!.first.id : null;
                      if (firstId == null) return;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text(AppStrings.deleteShipment),
                          content: const Text(AppStrings.confirmDeleteShipment),
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
                      if (confirm != true || !mounted) return;
                      try {
                        await ShipmentsService.deleteShipment(firstId);
                        if (!mounted) return;
                        _load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حذف الشحنة')),
                        );
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('فشل حذف الشحنة'), backgroundColor: Colors.red),
                        );
                      }
                    }
                    else if (value == AppStrings.reportShipment) {}
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: AppStrings.editShipment,
                      child: Text(AppStrings.editShipment, style: const TextStyle(color: Colors.black87)),
                    ),
                    PopupMenuItem(
                      value: AppStrings.deleteShipment,
                      child: Text(AppStrings.deleteShipment, style: const TextStyle(color: Colors.black87)),
                    ),
                    PopupMenuItem(
                      value: AppStrings.reportShipment,
                      child: Text(AppStrings.reportShipment, style: const TextStyle(color: Colors.black87)),
                    ),
                  ],
                )
              : null,
          title: Text(
            AppStrings.navShipments,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            if (_hasShipments)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                child: Material(
                  color: _tabBarGrey,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: _openFilter,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list, size: 20, color: Colors.white),
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
                ),
              ),
          ],
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
                        Tab(text: AppStrings.tabDeals),
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
        _DealsTab(),
        _SuitableTripsTab(),
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
        final firstId = res.data.first.id;
        return FutureBuilder<ShipmentDetails>(
          future: ShipmentsService.getShipment(firstId),
          builder: (context, detailSnapshot) {
            if (detailSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (detailSnapshot.hasError || !detailSnapshot.hasData) {
              return Center(
                child: Text(
                  detailSnapshot.hasError ? detailSnapshot.error.toString() : 'لا توجد بيانات',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ShipmentDetailContent(shipment: detailSnapshot.data!);
          },
        );
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
          );
        },
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

class _SuitableTripsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'لا توجد رحلات مناسبة',
        style: TextStyle(color: Colors.grey[600], fontSize: 15),
      ),
    );
  }
}
