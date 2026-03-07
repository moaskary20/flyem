import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:http/http.dart' as http;

class PaymentMethodItem {
  final int id;
  final String nameAr;
  final String nameEn;
  final String code;

  PaymentMethodItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.code,
  });

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) {
    return PaymentMethodItem(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class PaymentMethodsService {
  static Future<List<PaymentMethodItem>> getPaymentMethods() async {
    final response = await ApiClient.get('/api/payment-methods');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data
        .map((e) => PaymentMethodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
