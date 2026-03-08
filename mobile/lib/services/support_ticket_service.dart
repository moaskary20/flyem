import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/app_preferences.dart';

class SupportTicketService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw Exception('يجب تسجيل الدخول أولاً');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// إرسال تذكرة دعم فني (تظهر في لوحة التحكم).
  static Future<void> sendTicket({required String subject, required String message}) async {
    final response = await ApiClient.post(
      '/api/support-tickets',
      headers: await _authHeaders(),
      body: jsonEncode({'subject': subject, 'message': message}),
    );
    if (response.statusCode == 401) throw Exception('يجب تسجيل الدخول');
    if (response.statusCode != 201) {
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(map?['message'] as String? ?? 'فشل إرسال الرسالة');
    }
  }
}
