import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/add_trip_passport_sheet.dart';
import 'package:flyem_app/widgets/user_profile_link.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  const ShipmentDetailsScreen({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  int _reloadKey = 0;

  Future<List<dynamic>> _loadPayload() async {
    final shipment = await ShipmentsService.getShipment(widget.shipmentId);
    final currentUserId = await AuthService.getUserId();
    final isOwner = currentUserId != null &&
        shipment.user?.id != null &&
        shipment.user!.id == currentUserId;
    var travelerHasTrip = true;
    if (currentUserId != null && !isOwner) {
      travelerHasTrip = await TripsService.currentUserHasAtLeastOneTrip();
    }
    return [shipment, currentUserId, travelerHasTrip];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<dynamic>>(
          key: ValueKey(_reloadKey),
          future: _loadPayload(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.hasError ? snapshot.error.toString() : AppStrings.noData,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppStrings.goBack),
                    ),
                  ],
                ),
              );
            }
            final data = snapshot.data!;
            final shipment = data[0] as ShipmentDetails;
            final currentUserId = data[1] as int?;
            final travelerHasTrip = data[2] as bool;
            return _DetailsContent(
              shipment: shipment,
              currentUserId: currentUserId,
              travelerHasTrip: travelerHasTrip,
              onTripRegistered: () => setState(() => _reloadKey++),
            );
          },
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.shipment,
    required this.travelerHasTrip,
    this.currentUserId,
    this.onTripRegistered,
  });

  final ShipmentDetails shipment;
  final int? currentUserId;
  final bool travelerHasTrip;
  final VoidCallback? onTripRegistered;

  bool get _isOwner =>
      currentUserId != null &&
      shipment.user?.id != null &&
      shipment.user!.id == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  shipment.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
                    SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.appShipmentNumber(shipment.id),
                        style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _buildOriginDestination(),
                      const SizedBox(height: 20),
                      _buildTimelineRow(
                        icon: Icons.calendar_today,
                        text: '${AppStrings.expectedOn} ${shipment.deadlineFormatted ?? ''}',
                      ),
                      const SizedBox(height: 12),
                      _buildTimelineRow(
                        icon: Icons.local_shipping_outlined,
                        text: AppStrings.allowShippingCompanies,
                      ),
                      const SizedBox(height: 16),
                      _buildPublisherRow(),
                      if (shipment.description != null && shipment.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          shipment.description!.trim(),
                          style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[800]),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildOriginDestination() {
    final caption = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.routeLabelFrom, style: caption),
                Text(
                  shipment.fromCode,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  shipment.fromName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 2, color: AppColors.primaryYellow),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(Icons.arrow_forward, color: AppColors.primaryYellow, size: 26),
                ),
                Container(width: 12, height: 2, color: AppColors.primaryYellow),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(AppStrings.routeLabelTo, style: caption),
                Text(
                  shipment.toCode,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  shipment.toName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
        Icon(icon, color: AppColors.primaryYellow, size: 22),
      ],
    );
  }

  Widget _buildPublisherRow() {
    return Row(
      children: [
        Text(
          AppStrings.postedBy,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.person_outline, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 6),
        TappableUserName(
          userId: shipment.user?.id,
          displayName: shipment.user?.name ?? '',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (_isOwner) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.cannotRequestOwnListing,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.35),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.travelerProfit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${shipment.currencySymbol}${shipment.priceMin}',
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
          ),
        ),
      );
    }
    if (!travelerHasTrip) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.tripRequiredToRequestShipment,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.35),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  showAddTripPassportThenTripForm(
                    context,
                    useFullScreenForm: true,
                    onTripCreated: (added) {
                      if (added) {
                        onTripRegistered?.call();
                      }
                    },
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.tripRequiredAddTripAction,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.travelerProfit,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${shipment.currencySymbol}${shipment.priceMin}',
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
          ),
        ),
      );
    }
    final alreadyRequested = shipment.userHasRequested;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: alreadyRequested
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(content: Text(AppStrings.sendingRequest)),
                        );
                        try {
                          await ShipmentsService.createShipmentRequest(shipment.id);
                          if (!context.mounted) {
                            return;
                          }
                          await LocalNotificationService.showNotification(
                            id: LocalNotificationService.uniqueNotificationId(),
                            title: AppStrings.notificationRequestSent,
                            body: AppStrings.notificationRequestSent,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          messenger.showSnackBar(
                            SnackBar(content: Text(AppStrings.requestSentMatches)),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: alreadyRequested ? Colors.grey : AppColors.primaryYellow,
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(alreadyRequested ? AppStrings.requestAlreadySent : AppStrings.sendRequest),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.travelerProfit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${shipment.currencySymbol}${shipment.priceMin}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
