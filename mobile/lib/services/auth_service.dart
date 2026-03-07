import 'dart:convert';

import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<AuthResult> login(String email, String password) async {
    final uri = Uri.parse('$kApiBaseUrl/api/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    if (response.statusCode != 200) {
      final msg = map?['message'] as String? ?? map?['errors']?.toString() ?? 'Login failed';
      throw AuthException(msg);
    }
    final user = map!['user'] as Map<String, dynamic>;
    final token = map['token'] as String? ?? '';
    final userId = user['id'] as int?;
    if (userId != null && token.isNotEmpty) {
      await AppPreferences.setAuth(userId, token);
    }
    return AuthResult(userId: userId, token: token);
  }

  static Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/api/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    if (response.statusCode != 201 && response.statusCode != 200) {
      final errors = map?['errors'] as Map<String, dynamic>?;
      final msg = errors != null
          ? (errors.values.first is List
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString())
          : (map?['message'] as String? ?? 'Registration failed');
      throw AuthException(msg);
    }
    final user = map!['user'] as Map<String, dynamic>;
    final token = map['token'] as String? ?? '';
    final userId = user['id'] as int?;
    if (userId != null && token.isNotEmpty) {
      await AppPreferences.setAuth(userId, token);
    }
    return AuthResult(userId: userId, token: token);
  }

  static Future<void> logout() async {
    final token = await AppPreferences.getAuthToken();
    if (token != null && token.isNotEmpty) {
      try {
        final uri = Uri.parse('$kApiBaseUrl/api/logout');
        await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {}
    }
    await AppPreferences.setAuth(null, null);
  }

  static Future<bool> isLoggedIn() => AppPreferences.isLoggedIn();
  static Future<String?> getToken() => AppPreferences.getAuthToken();
  static Future<int?> getUserId() => AppPreferences.getUserId();

  /// جلب بيانات المستخدم الحالي من الـ API (يتطلب تسجيل الدخول).
  static Future<UserProfile?> getCurrentUser() async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) return null;
    final uri = Uri.parse('$kApiBaseUrl/api/user');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) return null;
    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    final data = map?['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profilePhoto;
  final String verificationStatus;
  final double? rating;
  final int shipmentsCount;
  final int tripsCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePhoto,
    this.verificationStatus = 'unverified',
    this.rating,
    this.shipmentsCount = 0,
    this.tripsCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePhoto: json['profile_photo'] as String?,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      rating: (json['rating'] as num?)?.toDouble(),
      shipmentsCount: (json['shipments_count'] as num?)?.toInt() ?? 0,
      tripsCount: (json['trips_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class AuthResult {
  final int? userId;
  final String token;
  AuthResult({this.userId, required this.token});
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
