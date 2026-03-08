import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/models/city.dart';
import 'package:flyem_app/models/country.dart';
import 'package:flyem_app/models/shipment_details.dart';
import 'package:flyem_app/models/shipment_list_item.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:http/http.dart' as http;

class ShipmentsService {
  static Future<ShipmentsListResponse> getShipments({
    int page = 1,
    int perPage = 20,
    int? userId,
    int? fromCountryId,
    int? toCountryId,
    int? fromCityId,
    int? toCityId,
    String? deadlineAfter,
    int? currencyId,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (userId != null) 'user_id': '$userId',
      if (fromCountryId != null) 'from_country_id': '$fromCountryId',
      if (toCountryId != null) 'to_country_id': '$toCountryId',
      if (fromCityId != null) 'from_city_id': '$fromCityId',
      if (toCityId != null) 'to_city_id': '$toCityId',
      if (deadlineAfter != null) 'deadline_after': deadlineAfter,
      if (currencyId != null) 'currency_id': '$currencyId',
    };
    final response = await ApiClient.get('/api/shipments', queryParams: queryParams);
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    final total = (map['total'] as num?)?.toInt() ?? 0;
    final list = data
        .map((e) => ShipmentListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return ShipmentsListResponse(
      data: list,
      total: total,
      currentPage: (map['current_page'] as num?)?.toInt() ?? 1,
      perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
    );
  }

  static Future<ShipmentDetails> getShipment(int id) async {
    final response = await ApiClient.get('/api/shipments/$id');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ShipmentDetails.fromJson(map);
  }

  /// شحنات المستخدم الحالي (شاشة الشحنات) مع فلتر اختياري.
  static Future<ShipmentsListResponse> getMyShipments({
    int? userId,
    int? fromCountryId,
    int? toCountryId,
    int? fromCityId,
    int? toCityId,
    String? deadlineAfter,
    int? currencyId,
  }) async {
    final id = userId ?? kCurrentUserId;
    return getShipments(
      perPage: 50,
      userId: id,
      fromCountryId: fromCountryId,
      toCountryId: toCountryId,
      fromCityId: fromCityId,
      toCityId: toCityId,
      deadlineAfter: deadlineAfter,
      currencyId: currencyId,
    );
  }

  /// إنشاء طلب على شحنة فقط (بدون دفع). يظهر في تطابقات حتى يقبل صاحب الشحنة.
  static Future<CreateRequestResult> createShipmentRequest(int shipmentId, {String? message}) async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw Exception('يجب تسجيل الدخول أولاً');
    final bodyMap = <String, dynamic>{};
    if (message != null && message.isNotEmpty) bodyMap['message'] = message;
    final response = await ApiClient.post(
      '/api/shipments/$shipmentId/request',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyMap.isNotEmpty ? bodyMap : {}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      final msg = map?['message'] as String? ?? response.body;
      throw Exception(msg);
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? map;
    return CreateRequestResult(
      requestId: (data['request_id'] as num).toInt(),
      message: data['message'] as String? ?? 'تم إرسال الطلب.',
    );
  }

  /// إرسال طلب على شحنة (دفع): ينشئ الطلب والدفعة والمحادثة ويرجع conversationId و otherUserName.
  static Future<SendRequestResult> sendRequest({
    required int shipmentId,
    required int paymentMethodId,
    String? message,
  }) async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw Exception('يجب تسجيل الدخول أولاً');
    final bodyMap = <String, dynamic>{'payment_method_id': paymentMethodId};
    if (message != null && message.isNotEmpty) bodyMap['message'] = message;
    final response = await ApiClient.post(
      '/api/shipments/$shipmentId/send-request',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyMap),
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

  static Future<void> deleteShipment(int id) async {
    final response = await ApiClient.delete('/api/shipments/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('API error: ${response.statusCode}');
    }
  }

  static Future<int> createShipment({
    required int userId,
    required String title,
    String? description,
    required int fromCountryId,
    required int fromCityId,
    required int toCountryId,
    required int toCityId,
    String? deadlineDate,
    int? quantity,
    String? productLink,
    String? type,
    double? priceMin,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'from_country_id': fromCountryId,
      'from_city_id': fromCityId,
      'to_country_id': toCountryId,
      'to_city_id': toCityId,
    };
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (deadlineDate != null && deadlineDate.isNotEmpty) body['deadline_date'] = deadlineDate;
    if (quantity != null) body['quantity'] = quantity;
    if (productLink != null && productLink.isNotEmpty) body['product_link'] = productLink;
    if (type != null && type.isNotEmpty) body['type'] = type;
    if (priceMin != null) body['price_min'] = priceMin;
    final response = await ApiClient.post(
      '/api/shipments',
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      final msg = response.body;
      throw Exception('API error: ${response.statusCode} $msg');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return (map['id'] as num).toInt();
  }

  static Future<List<Country>> getCountries({String? search}) async {
    final response = await ApiClient.get(
      '/api/countries',
      queryParams: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<City>> getCities(int countryId, {String? search}) async {
    final params = <String, String>{'country_id': '$countryId'};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await ApiClient.get('/api/cities', queryParams: params);
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class ShipmentsListResponse {
  final List<ShipmentListItem> data;
  final int total;
  final int currentPage;
  final int perPage;

  ShipmentsListResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.perPage,
  });
}

class CreateRequestResult {
  final int requestId;
  final String message;

  CreateRequestResult({required this.requestId, required this.message});
}
