import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/api_http_client.dart';
import 'package:http/http.dart' as http;

/// يحمّل الصورة من الرابط باستخدام عميل الـ API (يتجاوز SSL) ويعرضها.
/// استخدمه بدل NetworkImage/Image.network لتجنب statusCode: 0.
class ApiClientImage extends StatelessWidget {
  const ApiClientImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  static String _sanitize(String? u) {
    if (u == null || u.isEmpty) return '';
    return u.replaceAll(RegExp(r'\s'), '').trim();
  }

  static final Map<String, Future<Uint8List?>> _cache = {};

  static Future<Uint8List?> _fetch(String cleanUrl) async {
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null || !uri.hasScheme) return null;
    final client = getApiClient();
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = _sanitize(url);
    if (cleanUrl.isEmpty) {
      return _placeholder(context);
    }
    final future = _cache.putIfAbsent(
      cleanUrl,
      () => _fetch(cleanUrl).catchError((_, __) => null),
    );
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        }
        return _placeholder(context);
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    return SizedBox(
      width: width,
      height: height,
      child: Icon(Icons.person, size: width != null && height != null ? (width! < height! ? width : height)! * 0.5 : 48, color: Colors.grey),
    );
  }
}
