import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/api_http_client.dart';
import 'package:http/http.dart' as http;

class DuplicateRequestException implements Exception {
  final String message;
  DuplicateRequestException([this.message = 'تم إرسال نفس الطلب بالفعل، برجاء الانتظار.']);
  @override
  String toString() => message;
}

/// عميل مركزي لطلبات الـ API: يستخدم SSL الآمن على الموبايل ويجرّب الرابط البديل عند فشل تحليل النطاق.
class ApiClient {
  static final Map<String, Future<http.Response>> _inFlight = {};

  static bool _isHostLookupFailure(Object e) {
    final msg = e.toString();
    return msg.contains('Failed host lookup') ||
        msg.contains('SocketException') ||
        msg.contains('address associated with hostname');
  }

  static String _path(String path) =>
      path.startsWith('/') ? path : '/$path';

  static String _dedupeKey(
    String method,
    String path, {
    String? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) {
    final qp = (queryParams == null || queryParams.isEmpty)
        ? ''
        : (() {
            final clean = Map<String, String>.from(queryParams)..removeWhere((k, _) => k.isEmpty);
            final entries = clean.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
            return entries.map((e) => '${e.key}=${e.value}').join('&');
          })();
    final auth = headers?['Authorization'] ?? '';
    return '${method.toUpperCase()}|${_path(path)}|$qp|$auth|${body ?? ''}';
  }

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
        case 'PATCH':
          return await client.patch(uri, headers: headers, body: body);
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
    bool preventDuplicate = true,
  }) async {
    final upper = method.toUpperCase();
    final shouldDedupe = preventDuplicate && upper != 'GET';
    final key = shouldDedupe ? _dedupeKey(method, path, body: body, queryParams: queryParams, headers: headers) : null;
    if (key != null && _inFlight.containsKey(key)) {
      throw DuplicateRequestException();
    }

    Future<http.Response> run() async {
      try {
        return await _do(method, path, headers: headers, body: body, queryParams: queryParams);
      } catch (e) {
        if (_isHostLookupFailure(e) &&
            kApiBaseUrlFallback != null &&
            kApiBaseUrlFallback!.isNotEmpty) {
          final fallbackUri = _uri(kApiBaseUrlFallback!, path, queryParams);
          final client = getApiClient();
          try {
            switch (upper) {
              case 'GET':
                return await client.get(fallbackUri, headers: headers);
              case 'POST':
                return await client.post(fallbackUri, headers: headers, body: body);
              case 'PUT':
                return await client.put(fallbackUri, headers: headers, body: body);
              case 'DELETE':
                return await client.delete(fallbackUri, headers: headers);
              case 'PATCH':
                return await client.patch(fallbackUri, headers: headers, body: body);
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

    final fut = run();
    if (key != null) {
      _inFlight[key] = fut;
      fut.whenComplete(() => _inFlight.remove(key));
    }
    return await fut;
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

  static Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? queryParams,
  }) =>
      request('PATCH', path, headers: headers, body: body, queryParams: queryParams);
}
