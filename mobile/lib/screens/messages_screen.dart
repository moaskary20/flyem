import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/chat_screen.dart';
import 'package:flyem_app/services/conversations_service.dart';

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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            AppStrings.navMessages,
            style: TextStyle(
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
                tabs: const [
                  Tab(icon: Icon(Icons.article_outlined, size: 22), text: AppStrings.tabNews),
                  Tab(icon: Icon(Icons.check_circle_outline, size: 22), text: AppStrings.tabMatches),
                  Tab(icon: Icon(Icons.handshake_outlined, size: 22), text: AppStrings.tabAgreements),
                  Tab(icon: Icon(Icons.chat_bubble_outline, size: 22), text: AppStrings.tabConversations),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _EmptyTabContent(),
            _EmptyTabContent(),
            _EmptyTabContent(),
            _ConversationsTabContent(),
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
        _error = 'فشل تحميل المحادثات';
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
              FilledButton(onPressed: _load, child: const Text('إعادة المحاولة')),
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
                      otherUserName.isNotEmpty ? otherUserName : 'مستخدم',
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
