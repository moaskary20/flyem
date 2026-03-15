import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/screens/add_shipment_screen.dart' as flyem_app_add_shipment;

/// محتوى تفاصيل الشحنة (المسار، تعديل، إقرار، وصف المنتج، مكسب المسافر) — يُستخدم في شاشة التفاصيل وتبويب التفاصيل.
class ShipmentDetailContent extends StatelessWidget {
  const ShipmentDetailContent({super.key, required this.shipment, this.onEdited, this.onDelete});

  final ShipmentDetails shipment;
  final VoidCallback? onEdited;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final fromCity = shipment.fromCityName ?? shipment.fromName;
    final toCity = shipment.toCityName ?? shipment.toName;
    final productText = shipment.description?.isNotEmpty == true
        ? shipment.description!
        : shipment.title;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRouteWithEdit(context, fromCity, toCity),
            const SizedBox(height: 16),
            _buildCostAndDisclaimerBox(),
            const SizedBox(height: 16),
            if (productText.isNotEmpty) _buildProductSection(productText, shipment.priceMin),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(String productText, double rewardAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          productText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.travelerProfit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${shipment.currencySymbol}${rewardAmount.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteWithEdit(BuildContext context, String fromCity, String toCity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fromCity,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shipment.fromCode,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.flight,
                      color: AppColors.primaryYellow,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  toCity,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shipment.toCode,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == AppStrings.editShipment) {
                  final added = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => flyem_app_add_shipment.AddShipmentScreen(
                        shipmentToEdit: shipment,
                        isEditing: true,
                      ),
                    ),
                  );
                  if (added == true && onEdited != null) {
                    onEdited!();
                  }
                } else if (value == AppStrings.deleteShipment && onDelete != null) {
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
                  if (confirm == true) onDelete!();
                }
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
              ],
              icon: Icon(Icons.more_vert, color: Colors.grey[700], size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primaryYellow, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.expectedOn} ${shipment.deadlineFormatted ?? ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.primaryYellow, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      AppStrings.allowShippingCompanies,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Icon(Icons.drag_handle, color: Colors.grey[500], size: 22),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostAndDisclaimerBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.insuranceDisclaimer,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryYellow, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
