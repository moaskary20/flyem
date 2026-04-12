import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/widgets/user_profile_link.dart';

/// بطاقة رحلة في نتائج البحث (تبويب رحلات).
/// يعرض الحد الأدنى لسعر الرحلة (من لوحة التحكم) إن وُجد، وإلا سعر الرحلة.
class TripResultCard extends StatelessWidget {
  const TripResultCard({
    super.key,
    required this.item,
    this.minTripPrice,
    this.onTap,
  });

  final TripItem item;
  /// الحد الأدنى لسعر الرحلة من لوحة التحكم — يُعرض على الكارت ويُطبّق عند الدفع.
  final double? minTripPrice;
  final VoidCallback? onTap;



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.appTripNumber(item.id),
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Directionality(
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
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.fromCountry.isNotEmpty &&
                              item.fromCity.isNotEmpty &&
                              item.fromDisplay != item.fromCountry)
                            Text(
                              item.fromCountry,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
                      child: Icon(Icons.arrow_forward, size: 20, color: AppColors.primaryYellow),
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
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                          if (item.toCountry.isNotEmpty &&
                              item.toCity.isNotEmpty &&
                              item.toDisplay != item.toCountry)
                            Text(
                              item.toCountry,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (item.departureFormatted != null || item.departureDate != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.departsOn} ${item.departureFormatted ?? item.departureDate ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.userName != null && item.userName!.isNotEmpty)
                    TappableUserName(
                      userId: item.userId,
                      displayName: item.userName!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.confirmedDeals} ${AppStrings.confirmedDeals}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (item.canPickupInCurrentCountry || item.canDeliverInOtherCountry || item.canReturnOnCancel) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.canPickupInCurrentCountry)
                      _optionChip(AppStrings.canPickupInCurrentCountry),
                    if (item.canDeliverInOtherCountry)
                      _optionChip(AppStrings.canDeliverInOtherCountry),
                    if (item.canReturnOnCancel)
                      _optionChip(item.returnBeforeDays != null
                          ? AppStrings.returnBeforeDaysLabel(item.returnBeforeDays!)
                          : AppStrings.canReturnOnCancel),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _optionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
