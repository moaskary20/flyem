import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/screens/chat_screen.dart';
import 'package:flyem_app/screens/shipment_payment_screen.dart';
import 'package:flyem_app/screens/trip_payment_screen.dart';
import 'package:flyem_app/services/requests_service.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/conversations_list_body.dart';
import 'package:flyem_app/widgets/user_profile_link.dart';
import 'package:url_launcher/url_launcher.dart';

/// مركز الطلبات: وارد، صادر، قيد الدفع، مدفوع، محادثات.
class RequestsHubScreen extends StatefulWidget {
  const RequestsHubScreen({super.key});

  @override
  State<RequestsHubScreen> createState() => _RequestsHubScreenState();
}

class _RequestsHubScreenState extends State<RequestsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color _headerDark = Color(0xFF2C2C2E);

  List<RequestListItem> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RequestsService.getRequests();
      if (mounted) {
        setState(() {
          _list = res.data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  List<RequestListItem> _incoming() =>
      _list.where((r) => r.status == 'pending' && !r.isRequester).toList();

  List<RequestListItem> _outgoing() =>
      _list.where((r) => r.status == 'pending' && r.isRequester).toList();

  List<RequestListItem> _pendingPay() =>
      _list.where((r) => r.status == 'accepted' && !r.hasPaid).toList();

  List<RequestListItem> _paid() => _list
      .where(
        (r) =>
            r.hasPaid &&
            (r.status == 'in_progress' || r.status == 'delivered'),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppStrings.navRequests,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryYellow,
                indicatorWeight: 3,
                labelColor: AppColors.primaryYellow,
                unselectedLabelColor: Colors.grey[600],
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: AppStrings.tabIncomingRequests),
                  Tab(text: AppStrings.tabOutgoingRequests),
                  Tab(text: AppStrings.tabPendingPayment),
                  Tab(text: AppStrings.tabPaidRequests),
                  Tab(icon: const Icon(Icons.chat_bubble_outline, size: 20), text: AppStrings.tabConversations),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _RequestsListPane(
              loading: _loading,
              error: _error,
              items: _incoming(),
              mode: _RequestListMode.incoming,
              onRefresh: _load,
              onChanged: _load,
            ),
            _RequestsListPane(
              loading: _loading,
              error: _error,
              items: _outgoing(),
              mode: _RequestListMode.outgoing,
              onRefresh: _load,
              onChanged: _load,
            ),
            _RequestsListPane(
              loading: _loading,
              error: _error,
              items: _pendingPay(),
              mode: _RequestListMode.pendingPay,
              onRefresh: _load,
              onChanged: _load,
            ),
            _RequestsListPane(
              loading: _loading,
              error: _error,
              items: _paid(),
              mode: _RequestListMode.paid,
              onRefresh: _load,
              onChanged: _load,
            ),
            const ConversationsListBody(),
          ],
        ),
      ),
    );
  }
}

enum _RequestListMode { incoming, outgoing, pendingPay, paid }

class _RequestsListPane extends StatelessWidget {
  const _RequestsListPane({
    required this.loading,
    required this.error,
    required this.items,
    required this.mode,
    required this.onRefresh,
    required this.onChanged,
  });

  final bool loading;
  final String? error;
  final List<RequestListItem> items;
  final _RequestListMode mode;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => onRefresh(), child: Text(AppStrings.retry)),
            ],
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return Container(
        color: const Color(0xFFF8F7F4),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppStrings.noRequests,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
            ),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFFF8F7F4),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _RequestHubCard(
              item: item,
              mode: mode,
              onChanged: onChanged,
            );
          },
        ),
      ),
    );
  }
}

class _RequestHubCard extends StatelessWidget {
  const _RequestHubCard({
    required this.item,
    required this.mode,
    required this.onChanged,
  });

  final RequestListItem item;
  final _RequestListMode mode;
  final Future<void> Function() onChanged;

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return AppStrings.requestStatusPending;
      case 'accepted':
        return AppStrings.requestStatusAccepted;
      case 'rejected':
        return AppStrings.requestStatusRejected;
      case 'in_progress':
        return AppStrings.statusInProgress;
      case 'delivered':
        return AppStrings.statusDelivered;
      case 'cancelled':
        return AppStrings.statusCancelled;
      default:
        return status;
    }
  }

  Future<void> _confirmAnd(
    BuildContext context, {
    required String title,
    required Future<void> Function() action,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.back)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.confirmAction)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.done)),
        );
        await onChanged();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _openPay(BuildContext context) async {
    try {
      if (item.listingType == 'trip' && item.tripId != null) {
        final trip = await TripsService.getTrip(item.tripId!);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TripPaymentScreen(
              tripId: item.tripId!,
              trip: trip,
              requestId: item.id,
            ),
          ),
        );
      } else if (item.shipmentId != null) {
        final shipment = await ShipmentsService.getShipment(item.shipmentId!);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShipmentPaymentScreen(
              shipmentId: item.shipmentId!,
              shipment: shipment,
              requestId: item.id,
            ),
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.loadFailedGeneric)),
          );
        }
        return;
      }
      if (context.mounted) await onChanged();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _openChat(BuildContext context) async {
    final id = item.conversationId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.messagesEmptyState)),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: id,
          otherUserName: item.otherUserName,
          otherUserId: item.otherUserId,
        ),
      ),
    );
    await onChanged();
  }

  Future<void> _showCounterparty(BuildContext context) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: FutureBuilder<RequestCounterparty?>(
            future: RequestsService.getCounterparty(item.id),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
              }
              final c = snap.data;
              if (c == null) {
                return SizedBox(
                  height: 120,
                  child: Center(child: Text(AppStrings.loadFailedGeneric)),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.counterpartyDetails,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryYellow,
                        backgroundImage: c.profilePhotoUrl != null && c.profilePhotoUrl!.isNotEmpty
                            ? NetworkImage(c.profilePhotoUrl!)
                            : null,
                        child: c.profilePhotoUrl == null || c.profilePhotoUrl!.isEmpty
                            ? Text(
                                c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : '?',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            if (c.phone != null && c.phone!.isNotEmpty)
                              Text(c.phone!, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      openPublicUserProfile(context, c.id);
                    },
                    icon: const Icon(Icons.person_outline),
                    label: Text(AppStrings.publicProfileTitle),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final p = c.phone;
                      if (p == null || p.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(AppStrings.noPhoneForWhatsapp)),
                        );
                        return;
                      }
                      final digits = p.replaceAll(RegExp(r'\D'), '');
                      if (digits.isEmpty) return;
                      final uri = Uri.parse('https://wa.me/$digits');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.chat),
                    label: Text(AppStrings.openWhatsapp),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showRateDialog(BuildContext context) {
    int selectedRating = 0;
    final commentController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppStrings.rateUserTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.otherUserName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          item.otherUserName,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return IconButton(
                          onPressed: () => setState(() => selectedRating = star),
                          icon: Icon(
                            star <= selectedRating ? Icons.star : Icons.star_border,
                            size: 36,
                            color: Colors.amber[700],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: AppStrings.rateCommentHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppStrings.back),
                ),
                FilledButton(
                  onPressed: selectedRating < 1
                      ? null
                      : () async {
                          try {
                            await RequestsService.rateRequest(
                              item.id,
                              selectedRating,
                              comment: commentController.text.trim().isEmpty
                                  ? null
                                  : commentController.text.trim(),
                            );
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(AppStrings.ratingSent)),
                              );
                              await onChanged();
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                                ),
                              );
                            }
                          }
                        },
                  child: Text(AppStrings.submitRating),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(item.status);
    final typeLabel =
        item.listingType == 'trip' ? AppStrings.listingTypeTrip : AppStrings.listingTypeShipment;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.displayTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(typeLabel, style: TextStyle(fontSize: 11, color: Colors.blue.shade800)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: TappableUserName(
                    userId: item.otherUserId,
                    displayName: item.otherUserName.isNotEmpty ? item.otherUserName : '—',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                if (mode == _RequestListMode.incoming ||
                    mode == _RequestListMode.outgoing ||
                    mode == _RequestListMode.paid)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                    onSelected: (v) async {
                      switch (v) {
                        case 'accept':
                          try {
                            await RequestsService.acceptRequest(item.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppStrings.requestAccepted)),
                              );
                              await onChanged();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                              );
                            }
                          }
                          break;
                        case 'reject':
                          try {
                            await RequestsService.rejectRequest(item.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppStrings.requestRejected)),
                              );
                              await onChanged();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                              );
                            }
                          }
                          break;
                        case 'delete':
                          await _confirmAnd(
                            context,
                            title: AppStrings.confirmDeleteRequestTitle,
                            action: () => RequestsService.deleteRequest(item.id),
                          );
                          break;
                        case 'cancel':
                          await _confirmAnd(
                            context,
                            title: AppStrings.confirmCancelRequestTitle,
                            action: () => RequestsService.cancelRequest(item.id),
                          );
                          break;
                        case 'chat':
                          await _openChat(context);
                          break;
                        case 'counterparty':
                          await _showCounterparty(context);
                          break;
                        case 'rate':
                          _showRateDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (ctx) {
                      if (mode == _RequestListMode.incoming) {
                        return [
                          PopupMenuItem(value: 'accept', child: Text(AppStrings.accept)),
                          PopupMenuItem(value: 'reject', child: Text(AppStrings.reject)),
                          PopupMenuItem(value: 'delete', child: Text(AppStrings.menuDeleteRequest)),
                        ];
                      }
                      if (mode == _RequestListMode.outgoing) {
                        return [
                          PopupMenuItem(value: 'cancel', child: Text(AppStrings.menuCancelRequest)),
                          PopupMenuItem(value: 'delete', child: Text(AppStrings.menuDeleteRequest)),
                        ];
                      }
                      if (mode == _RequestListMode.paid) {
                        return [
                          PopupMenuItem(value: 'chat', child: Text(AppStrings.openChat)),
                          PopupMenuItem(value: 'counterparty', child: Text(AppStrings.counterpartyDetails)),
                          PopupMenuItem(value: 'cancel', child: Text(AppStrings.menuCancelRequest)),
                          if (item.canRate && !item.alreadyRated)
                            PopupMenuItem(value: 'rate', child: Text(AppStrings.rateUser)),
                        ];
                      }
                      return [];
                    },
                  ),
              ],
            ),
            if (mode == _RequestListMode.paid) ...[
              const SizedBox(height: 8),
              Text(
                '${AppStrings.requestPartyTraveler}: ${item.travelerDisplayName.isNotEmpty ? item.travelerDisplayName : '—'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
              Text(
                '${AppStrings.requestPartySender}: ${item.senderDisplayName.isNotEmpty ? item.senderDisplayName : '—'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${item.currencySymbol}${item.price.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFDB913),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.status == 'pending'
                        ? Colors.orange.shade100
                        : (item.status == 'accepted' ||
                                item.status == 'in_progress' ||
                                item.status == 'delivered')
                            ? Colors.green.shade100
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: (item.status == 'accepted' ||
                              item.status == 'in_progress' ||
                              item.status == 'delivered')
                          ? Colors.green.shade800
                          : item.status == 'pending'
                              ? Colors.orange.shade800
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (mode == _RequestListMode.pendingPay) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item.isRequester)
                    FilledButton(
                      onPressed: () => _openPay(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: Colors.black87,
                      ),
                      child: Text(AppStrings.payNow),
                    ),
                  if (item.isRequester) const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _confirmAnd(
                      context,
                      title: AppStrings.confirmCancelRequestTitle,
                      action: () => RequestsService.cancelRequest(item.id),
                    ),
                    child: Text(AppStrings.menuCancelRequest),
                  ),
                ],
              ),
            ],
            if (mode == _RequestListMode.paid && item.status == 'in_progress') ...[
              const SizedBox(height: 12),
              if (item.viewerIsTraveler && item.custodyConfirmedAt == null) ...[
                Text(AppStrings.custodyConfirmPrompt),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: () => _confirmAnd(
                      context,
                      title: AppStrings.custodyConfirmPrompt,
                      action: () => RequestsService.confirmCustody(item.id),
                    ),
                    child: Text(AppStrings.confirmYes),
                  ),
                ),
              ],
              if (item.viewerIsSender && item.deliveryConfirmedAt == null) ...[
                Text(AppStrings.deliveryConfirmPrompt),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: () => _confirmAnd(
                      context,
                      title: AppStrings.deliveryConfirmPrompt,
                      action: () => RequestsService.confirmDelivery(item.id),
                    ),
                    child: Text(AppStrings.confirmYes),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
