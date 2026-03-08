import 'dart:convert';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/api_config.dart';
import 'package:http/http.dart' as http;

/// يبني رابطاً كاملاً للصورة إذا كان المرتجع من الـ API نسبياً.
String _fullImageUrl(String? url) {
  final u = url?.trim() ?? '';
  if (u.isEmpty) return '';
  if (u.startsWith('http')) return u;
  final base = kApiBaseUrl.endsWith('/') ? kApiBaseUrl.substring(0, kApiBaseUrl.length - 1) : kApiBaseUrl;
  return base + (u.startsWith('/') ? '' : '/') + u;
}

class ContentService {
  /// البنرات الإعلانية (للسلايدر في شاشة البحث - من لوحة التحكم)
  static Future<List<BannerItem>> getBanners() async {
    final response = await ApiClient.get('/api/banners');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data
        .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  /// الأسئلة الشائعة (من لوحة التحكم - إدارة المحتوى > FAQs)
  static Future<List<FaqItem>> getFaqs() async {
    final response = await ApiClient.get('/api/faqs');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (map['data'] as List<dynamic>?) ?? [];
    return data
        .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// إعدادات التطبيق (من لوحة التحكم - الإعدادات)
  static Future<Map<String, dynamic>> getSettings() async {
    final response = await ApiClient.get('/api/settings');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }
}

class BannerItem {
  final int id;
  final String title;
  final String? imageUrl;
  final String? videoUrl;
  final String? link;
  final int sortOrder;

  BannerItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.videoUrl,
    this.link,
    this.sortOrder = 0,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image_url'] as String?;
    final rawVideo = json['video_url'] as String?;
    final imageUrl = rawImage != null && rawImage.isNotEmpty ? _fullImageUrl(rawImage) : null;
    final videoUrl = rawVideo != null && rawVideo.isNotEmpty ? _fullImageUrl(rawVideo) : null;
    return BannerItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      imageUrl: imageUrl?.isEmpty == true ? null : imageUrl,
      videoUrl: videoUrl?.isEmpty == true ? null : videoUrl,
      link: json['link'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class FaqItem {
  final int id;
  final String question;
  final String answer;
  final int sortOrder;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.sortOrder = 0,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id'] as int,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

