import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/app_preferences.dart';

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

  static Future<void> cancelRequest(int requestId) async {
    final response = await ApiClient.patch(
      '/api/requests/$requestId/cancel',
      headers: await _authHeaders(),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 200) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل إلغاء الطلب');
    }
  }

  static Future<void> deleteRequest(int requestId) async {
    final response = await ApiClient.delete(
      '/api/requests/$requestId',
      headers: await _authHeaders(),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 200) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل حذف الطلب');
    }
  }

  static Future<void> confirmCustody(int requestId) async {
    final response = await ApiClient.post(
      '/api/requests/$requestId/confirm-custody',
      headers: await _authHeaders(),
      body: '{}',
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 200) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل التأكيد');
    }
  }

  static Future<void> confirmDelivery(int requestId) async {
    final response = await ApiClient.post(
      '/api/requests/$requestId/confirm-delivery',
      headers: await _authHeaders(),
      body: '{}',
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 200) {
      final m = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(m?['message'] as String? ?? 'فشل التأكيد');
    }
  }

  static Future<RequestCounterparty?> getCounterparty(int requestId) async {
    final response = await ApiClient.get(
      '/api/requests/$requestId/counterparty',
      headers: await _authHeaders(),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 200) return null;
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return RequestCounterparty.fromJson(data);
  }

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

class RequestCounterparty {
  final int id;
  final String name;
  final String? phone;
  final String? profilePhotoUrl;

  RequestCounterparty({
    required this.id,
    required this.name,
    this.phone,
    this.profilePhotoUrl,
  });

  factory RequestCounterparty.fromJson(Map<String, dynamic> json) {
    return RequestCounterparty(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );
  }
}

class RequestListItem {
  final int id;
  final String listingType;
  final int? shipmentId;
  final int? tripId;
  final String listingTitle;
  final String shipmentTitle;
  final String status;
  final double price;
  final String currencySymbol;
  final String createdAt;
  final bool isRequester;
  final String otherUserName;
  final int? otherUserId;
  final bool hasPaid;
  final int? conversationId;
  final bool viewerIsTraveler;
  final bool viewerIsSender;
  final String? custodyConfirmedAt;
  final String? deliveryConfirmedAt;
  final Map<String, dynamic>? requesterJson;
  final Map<String, dynamic>? ownerJson;
  final Map<String, dynamic>? travelerJson;
  final Map<String, dynamic>? senderJson;
  final bool canRate;
  final bool alreadyRated;

  RequestListItem({
    required this.id,
    required this.listingType,
    this.shipmentId,
    this.tripId,
    required this.listingTitle,
    required this.shipmentTitle,
    required this.status,
    required this.price,
    required this.currencySymbol,
    required this.createdAt,
    required this.isRequester,
    required this.otherUserName,
    this.otherUserId,
    this.hasPaid = false,
    this.conversationId,
    this.viewerIsTraveler = false,
    this.viewerIsSender = false,
    this.custodyConfirmedAt,
    this.deliveryConfirmedAt,
    this.requesterJson,
    this.ownerJson,
    this.travelerJson,
    this.senderJson,
    this.canRate = false,
    this.alreadyRated = false,
  });

  String get displayTitle {
    if (listingTitle.isNotEmpty) return listingTitle;
    if (shipmentTitle.isNotEmpty) return shipmentTitle;
    return listingType == 'trip' ? 'رحلة' : 'شحنة';
  }

  factory RequestListItem.fromJson(Map<String, dynamic> json) {
    return RequestListItem(
      id: (json['id'] as num).toInt(),
      listingType: json['listing_type'] as String? ?? 'shipment',
      shipmentId: (json['shipment_id'] as num?)?.toInt(),
      tripId: (json['trip_id'] as num?)?.toInt(),
      listingTitle: json['listing_title'] as String? ?? '',
      shipmentTitle: json['shipment_title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      createdAt: json['created_at'] as String? ?? '',
      isRequester: json['is_requester'] as bool? ?? false,
      otherUserName: json['other_user_name'] as String? ?? '',
      otherUserId: (json['other_user_id'] as num?)?.toInt(),
      hasPaid: json['has_paid'] as bool? ?? false,
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      viewerIsTraveler: json['viewer_is_traveler'] as bool? ?? false,
      viewerIsSender: json['viewer_is_sender'] as bool? ?? false,
      custodyConfirmedAt: json['custody_confirmed_at'] as String?,
      deliveryConfirmedAt: json['delivery_confirmed_at'] as String?,
      requesterJson: json['requester'] as Map<String, dynamic>?,
      ownerJson: json['owner'] as Map<String, dynamic>?,
      travelerJson: json['traveler'] as Map<String, dynamic>?,
      senderJson: json['sender'] as Map<String, dynamic>?,
      canRate: json['can_rate'] as bool? ?? false,
      alreadyRated: json['already_rated'] as bool? ?? false,
    );
  }

  String? _nameFrom(Map<String, dynamic>? m) => m?['name'] as String?;

  String get requesterDisplayName => _nameFrom(requesterJson) ?? '';
  String get ownerDisplayName => _nameFrom(ownerJson) ?? '';
  String get travelerDisplayName => _nameFrom(travelerJson) ?? '';
  String get senderDisplayName => _nameFrom(senderJson) ?? '';
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

class SendRequestResult {
  final int requestId;
  final int conversationId;
  final String otherUserName;

  SendRequestResult({
    required this.requestId,
    required this.conversationId,
    required this.otherUserName,
  });
}
