import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:http/http.dart' as http;

class TripsService {
  /// كل الرحلات النشطة (شاشة البحث - تبويب رحلات) مع فلتر اختياري
  static Future<TripsListResponse> getTripsForSearch({
    int? fromCountryId,
    int? toCountryId,
    int? fromCityId,
    int? toCityId,
    String? departureAfter,
    int? currencyId,
    int perPage = 20,
  }) async {
    final params = <String, String>{'per_page': '$perPage'};
    if (fromCountryId != null) params['from_country_id'] = '$fromCountryId';
    if (toCountryId != null) params['to_country_id'] = '$toCountryId';
    if (fromCityId != null) params['from_city_id'] = '$fromCityId';
    if (toCityId != null) params['to_city_id'] = '$toCityId';
    if (departureAfter != null && departureAfter.isNotEmpty) params['departure_after'] = departureAfter;
    if (currencyId != null) params['currency_id'] = '$currencyId';
    final response = await ApiClient.get('/api/trips', queryParams: params);
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    final list = data
        .map((e) => TripItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return TripsListResponse(
      data: list,
      total: (map['total'] as num?)?.toInt() ?? 0,
      currentPage: (map['current_page'] as num?)?.toInt() ?? 1,
      perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
    );
  }

  /// رحلات المستخدم الحالي (شاشة الرحلات) مع فلتر اختياري
  static Future<TripsListResponse> getMyTrips({
    int? userId,
    int perPage = 50,
    int? fromCountryId,
    int? toCountryId,
    int? fromCityId,
    int? toCityId,
    String? departureAfter,
    int? currencyId,
  }) async {
    final id = userId ?? kCurrentUserId;
    final params = <String, String>{
      'user_id': '$id',
      'per_page': '$perPage',
    };
    if (fromCountryId != null) params['from_country_id'] = '$fromCountryId';
    if (toCountryId != null) params['to_country_id'] = '$toCountryId';
    if (fromCityId != null) params['from_city_id'] = '$fromCityId';
    if (toCityId != null) params['to_city_id'] = '$toCityId';
    if (departureAfter != null && departureAfter.isNotEmpty) params['departure_after'] = departureAfter;
    if (currencyId != null) params['currency_id'] = '$currencyId';
    final response = await ApiClient.get('/api/trips', queryParams: params);
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    final list = data
        .map((e) => TripItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return TripsListResponse(
      data: list,
      total: (map['total'] as num?)?.toInt() ?? 0,
      currentPage: (map['current_page'] as num?)?.toInt() ?? 1,
      perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
    );
  }

  /// تفاصيل رحلة واحدة (شاشة تفاصيل الرحلة)
  static Future<TripDetails> getTrip(int tripId) async {
    final response = await ApiClient.get('/api/trips/$tripId');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return TripDetails.fromJson(map);
  }

  static Future<void> deleteTrip(int id) async {
    final response = await ApiClient.delete('/api/trips/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('API error: ${response.statusCode}');
    }
  }

  /// إرسال طلب على رحلة (دفع): ينشئ الطلب والدفعة والمحادثة ويرجع conversationId و otherUserName.
  static Future<SendRequestResult> sendRequest({
    required int tripId,
    required int paymentMethodId,
    String? message,
  }) async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw Exception('يجب تسجيل الدخول أولاً');
    final bodyMap = <String, dynamic>{'payment_method_id': paymentMethodId};
    if (message != null && message.isNotEmpty) bodyMap['message'] = message;
    final response = await ApiClient.post(
      '/api/trips/$tripId/send-request',
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
    return SendRequestResult(
      requestId: (map['request_id'] as num).toInt(),
      conversationId: (map['conversation_id'] as num).toInt(),
      otherUserName: map['other_user_name'] as String? ?? '',
    );
  }

  /// إنشاء رحلة جديدة من نموذج أضف رحلتك
  static Future<int> createTrip({
    required int userId,
    required String travelMethod,
    required int fromCountryId,
    required int fromCityId,
    required int toCountryId,
    required int toCityId,
    required String departureDate,
    String? returnDate,
    double? pricePerKg,
    int? currencyId,
    String? notes,
    bool canPickupInCurrentCountry = false,
    bool canDeliverInOtherCountry = false,
    bool canReturnOnCancel = false,
    int? returnBeforeDays,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'travel_method': travelMethod,
      'from_country_id': fromCountryId,
      'from_city_id': fromCityId,
      'to_country_id': toCountryId,
      'to_city_id': toCityId,
      'departure_date': departureDate,
      'can_pickup_in_current_country': canPickupInCurrentCountry,
      'can_deliver_in_other_country': canDeliverInOtherCountry,
      'can_return_on_cancel': canReturnOnCancel,
    };
    if (returnDate != null && returnDate.isNotEmpty) body['return_date'] = returnDate;
    if (pricePerKg != null) body['price_per_kg'] = pricePerKg;
    if (currencyId != null) body['currency_id'] = currencyId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (returnBeforeDays != null && returnBeforeDays >= 1) body['return_before_days'] = returnBeforeDays;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await AppPreferences.getAuthToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await ApiClient.post(
      '/api/trips',
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      final msg = response.body;
      throw Exception('API error: ${response.statusCode} $msg');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return (map['id'] as num).toInt();
  }

  /// تحديث رحلة موجودة
  static Future<void> updateTrip({
    required int tripId,
    required String travelMethod,
    required int fromCountryId,
    required int fromCityId,
    required int toCountryId,
    required int toCityId,
    required String departureDate,
    String? returnDate,
    double? availableWeight,
    String? weightUnit,
    double? pricePerKg,
    int? currencyId,
    String? notes,
    bool canPickupInCurrentCountry = false,
    bool canDeliverInOtherCountry = false,
    bool canReturnOnCancel = false,
    int? returnBeforeDays,
  }) async {
    final body = <String, dynamic>{
      'travel_method': travelMethod,
      'from_country_id': fromCountryId,
      'from_city_id': fromCityId,
      'to_country_id': toCountryId,
      'to_city_id': toCityId,
      'departure_date': departureDate,
      'can_pickup_in_current_country': canPickupInCurrentCountry,
      'can_deliver_in_other_country': canDeliverInOtherCountry,
      'can_return_on_cancel': canReturnOnCancel,
    };
    if (returnDate != null && returnDate.isNotEmpty) body['return_date'] = returnDate;
    if (availableWeight != null) body['available_weight'] = availableWeight;
    if (weightUnit != null && weightUnit.isNotEmpty) body['weight_unit'] = weightUnit;
    if (pricePerKg != null) body['price_per_kg'] = pricePerKg;
    if (currencyId != null) body['currency_id'] = currencyId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (returnBeforeDays != null && returnBeforeDays >= 1) body['return_before_days'] = returnBeforeDays;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await AppPreferences.getAuthToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await ApiClient.put(
      '/api/trips/$tripId',
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      final msg = response.body;
      throw Exception('API error: ${response.statusCode} $msg');
    }
  }
}

class TripsListResponse {
  final List<TripItem> data;
  final int total;
  final int currentPage;
  final int perPage;

  TripsListResponse({
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
