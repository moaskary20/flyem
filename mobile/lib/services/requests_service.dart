import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';

class RequestsService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw Exception('يجب تسجيل الدخول أولاً');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// قائمة الطلبات (تطابقات): طلباتي المرسلة + الواردة على شحناتي.
  static Future<RequestsListResponse> getRequests({int page = 1, int perPage = 20}) async {
    final response = await ApiClient.get(
      '/api/requests',
      headers: await _authHeaders(),
      queryParams: {'page': '$page', 'per_page': '$perPage'},
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 200) throw Exception('فشل تحميل الطلبات');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    final list = data
        .map((e) => RequestListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return RequestsListResponse(
      data: list,
      total: (map['total'] as num?)?.toInt() ?? 0,
      currentPage: (map['current_page'] as num?)?.toInt() ?? 1,
      perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
    );
  }

  /// قبول طلب (صاحب الشحنة فقط).
  static Future<void> acceptRequest(int requestId) async {
    final response = await ApiClient.patch(
      '/api/requests/$requestId/accept',
      headers: await _authHeaders(),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode == 403) throw Exception('غير مصرح بقبول هذا الطلب');
    if (response.statusCode != 200) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل قبول الطلب');
    }
  }

  /// رفض طلب (صاحب الشحنة فقط).
  static Future<void> rejectRequest(int requestId) async {
    final response = await ApiClient.patch(
      '/api/requests/$requestId/reject',
      headers: await _authHeaders(),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode == 403) throw Exception('غير مصرح برفض هذا الطلب');
    if (response.statusCode != 200) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل رفض الطلب');
    }
  }

  /// تقييم الطرف الآخر بعد إتمام الاتفاق.
  static Future<void> rateRequest(int requestId, int rating, {String? comment}) async {
    final response = await ApiClient.post(
      '/api/requests/$requestId/rate',
      headers: await _authHeaders(),
      body: jsonEncode({
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      }),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode == 403) throw Exception('غير مصرح بالتقييم');
    if (response.statusCode != 200 && response.statusCode != 201) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل إرسال التقييم');
    }
  }

  /// دفع لطلب مقبول (المرسل فقط). يرجع conversationId و otherUserName لفتح الشات.
  static Future<SendRequestResult> payRequest(int requestId, int paymentMethodId) async {
    final response = await ApiClient.post(
      '/api/requests/$requestId/pay',
      headers: await _authHeaders(),
      body: jsonEncode({'payment_method_id': paymentMethodId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      final msg = map?['message'] as String? ?? response.body;
      throw Exception(msg);
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? map;
    return SendRequestResult(
      requestId: (data['request_id'] as num).toInt(),
      conversationId: (data['conversation_id'] as num).toInt(),
      otherUserName: data['other_user_name'] as String? ?? '',
    );
  }
}

class RequestListItem {
  final int id;
  final int shipmentId;
  final String shipmentTitle;
  final String status;
  final double price;
  final String currencySymbol;
  final String createdAt;
  final bool isRequester;
  final String otherUserName;
  final bool canRate;
  final bool alreadyRated;

  RequestListItem({
    required this.id,
    required this.shipmentId,
    required this.shipmentTitle,
    required this.status,
    required this.price,
    required this.currencySymbol,
    required this.createdAt,
    required this.isRequester,
    required this.otherUserName,
    this.canRate = false,
    this.alreadyRated = false,
  });

  factory RequestListItem.fromJson(Map<String, dynamic> json) {
    return RequestListItem(
      id: (json['id'] as num).toInt(),
      shipmentId: (json['shipment_id'] as num?)?.toInt() ?? 0,
      shipmentTitle: json['shipment_title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      createdAt: json['created_at'] as String? ?? '',
      isRequester: json['is_requester'] as bool? ?? false,
      otherUserName: json['other_user_name'] as String? ?? '',
      canRate: json['can_rate'] as bool? ?? false,
      alreadyRated: json['already_rated'] as bool? ?? false,
    );
  }
}

class RequestsListResponse {
  final List<RequestListItem> data;
  final int total;
  final int currentPage;
  final int perPage;

  RequestsListResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.perPage,
  });
}
