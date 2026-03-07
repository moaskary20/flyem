import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/models/place.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  /// بحث أماكن (مدينة + بلد أو بلد فقط) للاقتراح في من/إلى
  static Future<List<Place>> getPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final response = await ApiClient.get('/api/places', queryParams: {'q': q});
    if (response.statusCode != 200) throw Exception('API error: ${response.statusCode}');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
  }
}
