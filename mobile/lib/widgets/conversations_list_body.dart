import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/screens/chat_screen.dart';
import 'package:flyem_app/services/conversations_service.dart';

/// قائمة المحادثات من الـ API (تُستخدم في مركز الطلبات).
class ConversationsListBody extends StatefulWidget {
  const ConversationsListBody({super.key});

  @override
  State<ConversationsListBody> createState() => _ConversationsListBodyState();
}

class _ConversationsListBodyState extends State<ConversationsListBody> {
  List<ConversationListItem> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> reload() => _load();

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
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppStrings.loadFailedConversations;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: _buildInner(),
    );
  }

  Widget _buildInner() {
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
            return _ConversationRow(
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

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
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
