import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/widgets/shipment_detail_content.dart';

/// شاشة شحنتي بعد النشر: ثلاثة تبويبات (الصفقات - الرحلات المناسبة - التفاصيل).
class MyShipmentTabsScreen extends StatelessWidget {
  const MyShipmentTabsScreen({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
            shipment.title.isEmpty ? 'الشحنة' : shipment.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: Colors.white,
              iconColor: Colors.white,
              onSelected: (value) async {
                if (value == AppStrings.editShipment) {}
                else if (value == AppStrings.deleteShipment) {
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
                  if (confirm != true || !context.mounted) return;
                  try {
                    await ShipmentsService.deleteShipment(shipment.id);
                    if (!context.mounted) return;
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
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: _tabBarGrey,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(AppStrings.editShipment, style: const TextStyle(color: Colors.black87)),
                                onTap: () => Navigator.pop(ctx),
                              ),
                              ListTile(
                                title: Text(AppStrings.deleteShipment, style: const TextStyle(color: Colors.black87)),
                                onTap: () => Navigator.pop(ctx),
                              ),
                              ListTile(
                                title: Text(AppStrings.reportShipment, style: const TextStyle(color: Colors.black87)),
                                onTap: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TabBar(
                      indicatorColor: AppColors.primaryYellow,
                      indicatorWeight: 3,
                      labelColor: AppColors.primaryYellow,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        Tab(text: AppStrings.tabDeals),
                        Tab(text: AppStrings.tabSuitableTrips),
                        Tab(text: AppStrings.tabDetails),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _DealsTab(),
            _SuitableTripsTab(),
            ShipmentDetailContent(shipment: shipment),
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
