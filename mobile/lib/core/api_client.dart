import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/api_http_client.dart';
import 'package:http/http.dart' as http;

/// عميل مركزي لطلبات الـ API: يستخدم SSL الآمن على الموبايل ويجرّب الرابط البديل عند فشل تحليل النطاق.
class ApiClient {
  static bool _isHostLookupFailure(Object e) {
    final msg = e.toString();
    return msg.contains('Failed host lookup') ||
        msg.contains('SocketException') ||
        msg.contains('address associated with hostname');
  }

  static String _path(String path) =>
      path.startsWith('/') ? path : '/$path';

  static Uri _uri(String baseUrl, String path, [Map<String, String>? queryParams]) {
    final fullPath = _path(path);
    final u = Uri.parse('$baseUrl$fullPath');
    if (queryParams != null && queryParams.isNotEmpty) {
      return u.replace(queryParameters: queryParams);
    }
    return u;
  }

  static Future<http.Response> _do(
    String method,
    String path, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = _uri(kApiBaseUrl, path, queryParams);
    final client = getApiClient();
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await client.get(uri, headers: headers);
        case 'POST':
          return await client.post(uri, headers: headers, body: body);
        case 'PUT':
          return await client.put(uri, headers: headers, body: body);
        case 'DELETE':
          return await client.delete(uri, headers: headers);
        default:
          return await client.get(uri, headers: headers);
      }
    } finally {
      client.close();
    }
  }

  static Future<http.Response> request(
    String method,
    String path, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      return await _do(method, path, headers: headers, body: body, queryParams: queryParams);
    } catch (e) {
      if (_isHostLookupFailure(e) &&
          kApiBaseUrlFallback != null &&
          kApiBaseUrlFallback!.isNotEmpty) {
        final fallbackUri = _uri(kApiBaseUrlFallback!, path, queryParams);
        final client = getApiClient();
        try {
          switch (method.toUpperCase()) {
            case 'GET':
              return await client.get(fallbackUri, headers: headers);
            case 'POST':
              return await client.post(fallbackUri, headers: headers, body: body);
            case 'PUT':
              return await client.put(fallbackUri, headers: headers, body: body);
            case 'DELETE':
              return await client.delete(fallbackUri, headers: headers);
            default:
              return await client.get(fallbackUri, headers: headers);
          }
        } finally {
          client.close();
        }
      }
      rethrow;
    }
  }

  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) =>
      request('GET', path, headers: headers, queryParams: queryParams);

  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? queryParams,
  }) =>
      request('POST', path, headers: headers, body: body, queryParams: queryParams);

  static Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? queryParams,
  }) =>
      request('PUT', path, headers: headers, body: body, queryParams: queryParams);

  static Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) =>
      request('DELETE', path, headers: headers, queryParams: queryParams);
}
