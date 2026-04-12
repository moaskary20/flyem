import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/app_preferences.dart';

class PayoutAccountItem {
  PayoutAccountItem({
    required this.id,
    this.iban,
    this.bankName,
    this.accountHolder,
    this.nickname,
    required this.isPrimary,
  });

  final int id;
  final String? iban;
  final String? bankName;
  final String? accountHolder;
  final String? nickname;
  final bool isPrimary;

  factory PayoutAccountItem.fromJson(Map<String, dynamic> json) {
    return PayoutAccountItem(
      id: json['id'] as int,
      iban: json['iban'] as String?,
      bankName: json['bank_name'] as String?,
      accountHolder: json['account_holder'] as String?,
      nickname: json['nickname'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class PayoutAccountsService {
  static Future<Map<String, String>> _headers() async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<PayoutAccountItem>> list() async {
    final response = await ApiClient.get(
      '/api/user/payout-accounts',
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data.map((e) => PayoutAccountItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<PayoutAccountItem> create({
    String? iban,
    String? bankName,
    String? accountHolder,
    String? nickname,
    bool isPrimary = false,
  }) async {
    final body = jsonEncode({
      if (iban != null) 'iban': iban,
      if (bankName != null) 'bank_name': bankName,
      if (accountHolder != null) 'account_holder': accountHolder,
      if (nickname != null) 'nickname': nickname,
      'is_primary': isPrimary,
    });
    final response = await ApiClient.post(
      '/api/user/payout-accounts',
      headers: await _headers(),
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response.body));
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return PayoutAccountItem.fromJson(map['data'] as Map<String, dynamic>);
  }

  static Future<PayoutAccountItem> update(
    int id, {
    String? iban,
    String? bankName,
    String? accountHolder,
    String? nickname,
    bool? isPrimary,
  }) async {
    final map = <String, dynamic>{};
    if (iban != null) map['iban'] = iban;
    if (bankName != null) map['bank_name'] = bankName;
    if (accountHolder != null) map['account_holder'] = accountHolder;
    if (nickname != null) map['nickname'] = nickname;
    if (isPrimary != null) map['is_primary'] = isPrimary;
    final response = await ApiClient.put(
      '/api/user/payout-accounts/$id',
      headers: await _headers(),
      body: jsonEncode(map),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response.body));
    }
    final res = jsonDecode(response.body) as Map<String, dynamic>;
    return PayoutAccountItem.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<void> delete(int id) async {
    final response = await ApiClient.delete(
      '/api/user/payout-accounts/$id',
      headers: await _headers(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_parseError(response.body));
    }
  }

  static Future<void> setPrimary(int id) async {
    final response = await ApiClient.post(
      '/api/user/payout-accounts/$id/primary',
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response.body));
    }
  }

  static String _parseError(String body) {
    try {
      final m = jsonDecode(body) as Map<String, dynamic>?;
      return m?['message'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}
