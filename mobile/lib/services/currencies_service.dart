import 'dart:convert';

import 'package:flyem_app/core/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyItem {
  final int id;
  final String name;
  final String symbol;
  final String code;

  CurrencyItem({
    required this.id,
    required this.name,
    required this.symbol,
    required this.code,
  });

  factory CurrencyItem.fromJson(Map<String, dynamic> json) {
    return CurrencyItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class CurrenciesService {
  static const String _keySelectedCurrencyId = 'selected_currency_id';

  static Future<List<CurrencyItem>> getCurrencies() async {
    final uri = Uri.parse('$kApiBaseUrl/api/currencies');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data
        .map((e) => CurrencyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// معرف العملة المختارة في الإعدادات (null = عرض الكل).
  static Future<int?> getSelectedCurrencyId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keySelectedCurrencyId);
    return id;
  }

  static Future<void> setSelectedCurrencyId(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_keySelectedCurrencyId);
    } else {
      await prefs.setInt(_keySelectedCurrencyId, id);
    }
  }
}
