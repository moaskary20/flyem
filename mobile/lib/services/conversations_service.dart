import 'dart:convert';

import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:http/http.dart' as http;

class ConversationsService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AppPreferences.getAuthToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// قائمة محادثات المستخدم الحالي
  static Future<ConversationsListResponse> getConversations({int page = 1, int perPage = 20}) async {
    final uri = Uri.parse('$kApiBaseUrl/api/conversations').replace(
      queryParameters: {'page': '$page', 'per_page': '$perPage'},
    );
    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 401) throw ConversationsException('يجب تسجيل الدخول');
    if (response.statusCode != 200) throw ConversationsException('فشل تحميل المحادثات');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    final list = data.map((e) => ConversationListItem.fromJson(e as Map<String, dynamic>)).toList();
    return ConversationsListResponse(
      data: list,
      total: (map['total'] as num?)?.toInt() ?? 0,
      currentPage: (map['current_page'] as num?)?.toInt() ?? 1,
      perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
    );
  }

  /// رسائل محادثة واحدة (صفحة)
  static Future<ConversationDetailResponse> getConversation(int conversationId, {int page = 1, int perPage = 50}) async {
    final uri = Uri.parse('$kApiBaseUrl/api/conversations/$conversationId').replace(
      queryParameters: {'page': '$page', 'per_page': '$perPage'},
    );
    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 401) throw ConversationsException('يجب تسجيل الدخول');
    if (response.statusCode == 403) throw ConversationsException('غير مسموح');
    if (response.statusCode != 200) throw ConversationsException('فشل تحميل المحادثة');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? {};
    final messagesList = (data['messages'] as List<dynamic>?) ?? [];
    final messages = messagesList.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    final otherUser = data['other_user'] as Map<String, dynamic>? ?? {};
    return ConversationDetailResponse(
      id: (data['id'] as num?)?.toInt() ?? 0,
      otherUserName: otherUser['name'] as String? ?? '',
      otherUserId: (otherUser['id'] as num?)?.toInt(),
      messages: messages,
      messagesTotal: (data['messages_total'] as num?)?.toInt() ?? 0,
      currentPage: (data['current_page'] as num?)?.toInt() ?? 1,
      perPage: (data['per_page'] as num?)?.toInt() ?? perPage,
    );
  }

  /// إرسال رسالة نصية
  static Future<ChatMessage> sendMessage(int conversationId, String text) async {
    final uri = Uri.parse('$kApiBaseUrl/api/conversations/$conversationId/messages');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode({'message': text, 'type': 'text'}),
    );
    if (response.statusCode == 401) throw ConversationsException('يجب تسجيل الدخول');
    if (response.statusCode == 403) throw ConversationsException('غير مسموح');
    if (response.statusCode != 201 && response.statusCode != 200) throw ConversationsException('فشل إرسال الرسالة');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? {};
    return ChatMessage.fromJson(data);
  }

  /// إنشاء محادثة جديدة مع مستخدم
  static Future<ConversationListItem> createConversation(int receiverId) async {
    final uri = Uri.parse('$kApiBaseUrl/api/conversations');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode({'receiver_id': receiverId}),
    );
    if (response.statusCode == 401) throw ConversationsException('يجب تسجيل الدخول');
    if (response.statusCode != 201 && response.statusCode != 200) throw ConversationsException('فشل إنشاء المحادثة');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? {};
    return ConversationListItem.fromJson(data);
  }
}

class ConversationsException implements Exception {
  final String message;
  ConversationsException(this.message);
  @override
  String toString() => message;
}

class ConversationListItem {
  final int id;
  final int? otherUserId;
  final String otherUserName;
  final ChatMessage? lastMessage;
  final String? lastMessageAt;
  final int messagesCount;
  final int unreadCount;

  ConversationListItem({
    required this.id,
    this.otherUserId,
    required this.otherUserName,
    this.lastMessage,
    this.lastMessageAt,
    this.messagesCount = 0,
    this.unreadCount = 0,
  });

  factory ConversationListItem.fromJson(Map<String, dynamic> json) {
    final last = json['last_message'] as Map<String, dynamic>?;
    return ConversationListItem(
      id: json['id'] as int,
      otherUserId: (json['other_user']?['id'] as num?)?.toInt(),
      otherUserName: json['other_user']?['name'] as String? ?? '',
      lastMessage: last != null ? ChatMessage.fromJson(last) : null,
      lastMessageAt: json['last_message_at'] as String?,
      messagesCount: (json['messages_count'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final String message;
  final String type;
  final int? senderId;
  final String senderName;
  final bool isMine;
  final bool isRead;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.message,
    this.type = 'text',
    this.senderId,
    this.senderName = '',
    required this.isMine,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      senderId: (json['sender_id'] as num?)?.toInt(),
      senderName: json['sender_name'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? false,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class ConversationsListResponse {
  final List<ConversationListItem> data;
  final int total;
  final int currentPage;
  final int perPage;
  ConversationsListResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.perPage,
  });
}

class ConversationDetailResponse {
  final int id;
  final String otherUserName;
  final int? otherUserId;
  final List<ChatMessage> messages;
  final int messagesTotal;
  final int currentPage;
  final int perPage;
  ConversationDetailResponse({
    required this.id,
    required this.otherUserName,
    this.otherUserId,
    required this.messages,
    required this.messagesTotal,
    required this.currentPage,
    required this.perPage,
  });
}
