import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/widgets/api_client_image.dart';
import 'package:flyem_app/widgets/user_profile_link.dart';

class ShipmentResultCard extends StatelessWidget {
  final String productName;
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
  /// زر أسفل الكارت (مثلاً «إرسال طلب»). يُخفى تلقائياً عند تفعيل القائمة أو عند [isOwner].
  final String? actionButtonText;
  final VoidCallback? onActionButtonTap;
  /// إن كانت شحنة المستخدم الحالي لا يُعرض زر الإجراء الأسفلي.
  final bool isOwner;
  /// قائمة ⋮ بجانب العنوان: تعديل / حذف (شاشة شحناتي — تبويب التفاصيل).
  final VoidCallback? onMenuEdit;
  final VoidCallback? onMenuDelete;
  /// صاحب الإعلان (للفتح عند الضغط على الاسم).
  final int? publisherUserId;
  /// رقم العرض في التطبيق (معرّف الشحنة).
  final int? appListingNumber;

  const ShipmentResultCard({
    super.key,
    required this.productName,
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
    this.actionButtonText,
    this.onActionButtonTap,
    this.isOwner = false,
    this.onMenuEdit,
    this.onMenuDelete,
    this.publisherUserId,
    this.appListingNumber,
  });

  static String? _sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final s = url.replaceAll(RegExp(r'\s'), '').trim();
    return s.isEmpty ? null : s;
  }

  bool get _hasCardMenu => onMenuEdit != null || onMenuDelete != null;

  bool get _showBottomButton {
    if (isOwner || _hasCardMenu) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final safeImageUrl = _sanitizeUrl(imageUrl);
    final safeUserPhotoUrl = _sanitizeUrl(userPhotoUrl);
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
                        child: safeImageUrl != null && safeImageUrl.isNotEmpty
                            ? Image.network(
                                safeImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.inventory_2, size: 28, color: Colors.grey[500]),
                              )
                            : Icon(Icons.inventory_2, size: 28, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_hasCardMenu)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == AppStrings.editShipment) {
                                  onMenuEdit?.call();
                                } else if (value == AppStrings.deleteShipment) {
                                  onMenuDelete?.call();
                                }
                              },
                              itemBuilder: (context) => [
                                if (onMenuEdit != null)
                                  PopupMenuItem(
                                    value: AppStrings.editShipment,
                                    child: Text(AppStrings.editShipment, style: const TextStyle(color: Colors.black87)),
                                  ),
                                if (onMenuDelete != null)
                                  PopupMenuItem(
                                    value: AppStrings.deleteShipment,
                                    child: Text(AppStrings.deleteShipment, style: const TextStyle(color: Colors.black87)),
                                  ),
                              ],
                              icon: Icon(Icons.more_vert, color: Colors.grey[700], size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (appListingNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            AppStrings.appShipmentNumber(appListingNumber!),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ),
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
                                    fromCode,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: AppColors.primaryYellow,
                              ),
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
                                    toCode,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          safeUserPhotoUrl != null && safeUserPhotoUrl.isNotEmpty
                              ? ClipOval(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: ApiClientImage(
                                      url: safeUserPhotoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.grey[400],
                                        child: Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey[400],
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TappableUserName(
                              userId: publisherUserId,
                              displayName: userName,
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
                      if (_showBottomButton) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onActionButtonTap ?? onTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(actionButtonText ?? AppStrings.sendRequest),
                          ),
                        ),
                      ],
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
