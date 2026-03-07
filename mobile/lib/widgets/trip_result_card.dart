import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/trip_item.dart';

/// بطاقة رحلة في نتائج البحث (تبويب رحلات).
class TripResultCard extends StatelessWidget {
  const TripResultCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final TripItem item;
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
              Row(
                children: [
                  Text(
                    item.fromDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.flight, size: 18, color: Colors.grey[600]),
                  ),
                  Text(
                    item.toDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
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
                    Text(
                      item.userName!,
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
                  Text(
                    '${item.profitDisplay} ${AppStrings.profit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
