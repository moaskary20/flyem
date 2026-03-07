import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';

class ShipmentResultCard extends StatelessWidget {
  final String productName;
  final String weight;
  final String fromCode;
  final String toCode;
  final String date;
  final String userName;
  final String rewardAmount;
  final double rating;
  final String? imageUrl;
  final String? userPhotoUrl;
  final int? shipmentId;
  final VoidCallback? onTap;

  const ShipmentResultCard({
    super.key,
    required this.productName,
    required this.weight,
    required this.fromCode,
    required this.toCode,
    required this.date,
    required this.userName,
    required this.rewardAmount,
    this.rating = 0,
    this.imageUrl,
    this.userPhotoUrl,
    this.shipmentId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    Widget card = Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey[300],
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.inventory_2, size: 28, color: Colors.grey[500]),
                              )
                            : Icon(Icons.inventory_2, size: 28, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$weight ${AppStrings.kg}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.flight, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '$fromCode → $toCode',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.deliveryBefore} $date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey[400],
                            backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                                ? NetworkImage(userPhotoUrl!)
                                : null,
                            child: userPhotoUrl == null || userPhotoUrl!.isEmpty
                                ? Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              final filled = i < rating.floor() || (i == rating.floor() && rating % 1 >= 0.5);
                              return Icon(
                                filled ? Icons.star : Icons.star_border,
                                size: 14,
                                color: filled ? AppColors.primaryYellow : Colors.grey[400],
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(AppStrings.sendRequest),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.rewardBarBg,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              '${AppStrings.reward} $rewardAmount',
              style: const TextStyle(
                color: AppColors.primaryYellow,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return Padding(
        padding: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: card,
        ),
      );
    }
    return Padding(padding: margin, child: card);
  }
}
