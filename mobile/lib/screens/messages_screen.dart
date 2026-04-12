import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/chat_screen.dart';
import 'package:flyem_app/screens/shipment_payment_screen.dart';
import 'package:flyem_app/services/conversations_service.dart';
import 'package:flyem_app/services/requests_service.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/widgets/user_profile_link.dart';

/// شاشة الرسائل: أربعة تبويبات (الاخبار - تطابقات - اتفاقات - المحادثات).
/// تبويب المحادثات مربوط بالـ API ولوحة التحكم (Conversations / Messages).
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _headerDark = Color(0xFF2C2C2E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, initialIndex: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            AppStrings.navMessages,
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
                indicatorColor: AppColors.primaryYellow,
                indicatorWeight: 3,
                labelColor: AppColors.primaryYellow,
                unselectedLabelColor: Colors.grey[600],
                tabs: [
                  Tab(icon: const Icon(Icons.article_outlined, size: 22), text: AppStrings.tabNews),
                  Tab(icon: const Icon(Icons.check_circle_outline, size: 22), text: AppStrings.tabMatches),
                  Tab(icon: const Icon(Icons.handshake_outlined, size: 22), text: AppStrings.tabAgreements),
                  Tab(icon: const Icon(Icons.chat_bubble_outline, size: 22), text: AppStrings.tabConversations),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _EmptyTabContent(),
            _MatchesTabContent(),
            _EmptyTabContent(),
            _ConversationsTabContent(),
          ],
        ),
      ),
    );
  }
}

void _showRateDialog(
  BuildContext context,
  int requestId,
  String otherUserName,
  VoidCallback onSuccess,
) {
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
                  if (otherUserName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        otherUserName,
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
                      border: OutlineInputBorder(),
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
                            requestId,
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
                            onSuccess();
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

/// تبويب تطابقات: قائمة الطلبات (مرسلة/واردة) مع قبول/رفض أو ادفع الآن.
class _MatchesTabContent extends StatefulWidget {
  @override
  State<_MatchesTabContent> createState() => _MatchesTabContentState();
}

class _MatchesTabContentState extends State<_MatchesTabContent> {
  List<RequestListItem> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
      if (mounted) setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

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
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: Text(AppStrings.retry)),
            ],
          ),
        ),
      );
    }
    if (_list.isEmpty) {
      return Container(
        color: const Color(0xFFF8F7F4),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  AppStrings.noRequests,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFFF8F7F4),
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: _list.length,
          itemBuilder: (context, index) {
            final item = _list[index];
            return _RequestTile(
              item: item,
              statusLabel: _statusLabel(item.status),
              onAccept: item.status == 'pending' && !item.isRequester
                  ? () async {
                      try {
                        await RequestsService.acceptRequest(item.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppStrings.requestAccepted)),
                          );
                          _load();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      }
                    }
                  : null,
              onReject: item.status == 'pending' && !item.isRequester
                  ? () async {
                      try {
                        await RequestsService.rejectRequest(item.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppStrings.requestRejected)),
                          );
                          _load();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      }
                    }
                  : null,
              onPayNow: item.status == 'accepted' && item.isRequester
                  ? () async {
                      try {
                        final shipment = await ShipmentsService.getShipment(item.shipmentId);
                        if (!mounted) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShipmentPaymentScreen(
                              shipmentId: item.shipmentId,
                              shipment: shipment,
                              requestId: item.id,
                            ),
                          ),
                        );
                        if (mounted) _load();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      }
                    }
                  : null,
              onRate: item.canRate && !item.alreadyRated
                  ? () => _showRateDialog(context, item.id, item.otherUserName, _load)
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.item,
    required this.statusLabel,
    this.onAccept,
    this.onReject,
    this.onPayNow,
    this.onRate,
  });

  final RequestListItem item;
  final String statusLabel;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onPayNow;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.shipmentTitle.isNotEmpty ? item.shipmentTitle : AppStrings.shipmentGeneric,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
              ],
            ),
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
            if (onAccept != null || onReject != null || onPayNow != null || onRate != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onRate != null)
                    TextButton.icon(
                      onPressed: onRate,
                      icon: const Icon(Icons.star_border, size: 18),
                      label: Text(AppStrings.rateUser),
                    ),
                  if (onAccept != null)
                    TextButton(
                      onPressed: onAccept,
                      child: Text(AppStrings.accept, style: TextStyle(color: Colors.green.shade700)),
                    ),
                  if (onReject != null)
                    TextButton(
                      onPressed: onReject,
                      child: Text(AppStrings.reject, style: TextStyle(color: Colors.red.shade700)),
                    ),
                  if (onPayNow != null)
                    FilledButton(
                      onPressed: onPayNow,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: Colors.black87,
                      ),
                      child: Text(AppStrings.payNow),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// تبويب المحادثات: قائمة من الـ API، والضغط يفتح شاشة المحادثة.
class _ConversationsTabContent extends StatefulWidget {
  @override
  State<_ConversationsTabContent> createState() => _ConversationsTabContentState();
}

class _ConversationsTabContentState extends State<_ConversationsTabContent> {
  List<ConversationListItem> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ConversationsService.getConversations();
      if (mounted) {
        setState(() {
          _list = res.data;
          _loading = false;
        });
      }
    } on ConversationsException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error = AppStrings.loadFailedConversations;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: Text(AppStrings.retry)),
            ],
          ),
        ),
      );
    }
    if (_list.isEmpty) {
      return Container(
        color: const Color(0xFFF8F7F4),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  AppStrings.messagesEmptyState,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFFF8F7F4),
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _list.length,
          itemBuilder: (context, index) {
            final c = _list[index];
            return _ConversationTile(
              otherUserName: c.otherUserName,
              lastMessage: c.lastMessage?.message,
              lastMessageAt: c.lastMessageAt,
              unreadCount: c.unreadCount,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: c.id,
                      otherUserName: c.otherUserName,
                      otherUserId: c.otherUserId,
                    ),
                  ),
                );
                _load();
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.onTap,
  });

  final String otherUserName;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryYellow,
                child: Text(
                  otherUserName.isNotEmpty ? otherUserName.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName.isNotEmpty ? otherUserName : AppStrings.userGeneric,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (lastMessage != null && lastMessage!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_left, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F4),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.messagesEmptyState,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
