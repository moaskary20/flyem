import 'dart:convert';
import 'dart:typed_data';

import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/api_http_client.dart';
import 'package:flyem_app/core/app_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<AuthResult> login(String email, String password) async {
    final response = await ApiClient.post(
      '/api/login',
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
    required String homePhone,
    required String travelPhone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final body = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'home_phone': homePhone.trim(),
      'travel_phone': travelPhone.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    final response = await ApiClient.post(
      '/api/register',
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
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
        await ApiClient.post(
          '/api/logout',
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
    final response = await ApiClient.get(
      '/api/user',
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

  /// تحديث الملف الشخصي (الدولة/المدينة و/أو بيانات السحاب البنكي).
  static Future<void> updateProfile({
    int? homeCountryId,
    int? homeCityId,
    int? travelCountryId,
    int? travelCityId,
    String? bankIban,
    String? bankName,
    String? bankAccountHolder,
    String? homePhone,
    String? travelPhone,
  }) async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw AuthException('يجب تسجيل الدخول');
    final body = <String, dynamic>{};
    if (homeCountryId != null) body['home_country_id'] = homeCountryId;
    if (homeCityId != null) body['home_city_id'] = homeCityId;
    if (travelCountryId != null) body['travel_country_id'] = travelCountryId;
    if (travelCityId != null) body['travel_city_id'] = travelCityId;
    if (bankIban != null) body['bank_iban'] = bankIban;
    if (bankName != null) body['bank_name'] = bankName;
    if (bankAccountHolder != null) body['bank_account_holder'] = bankAccountHolder;
    if (homePhone != null) body['home_phone'] = homePhone;
    if (travelPhone != null) body['travel_phone'] = travelPhone;
    final response = await ApiClient.put(
      '/api/user',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      throw AuthException(map?['message'] as String? ?? 'فشل التحديث');
    }
  }

  /// رفع صورة الملف الشخصي (بايتات الصورة + اسم الملف لتفادي مشاكل المسار على أندرويد).
  static Future<String> uploadProfilePhoto(
    Uint8List imageBytes, {
    String filename = 'photo.jpg',
  }) async {
    final token = await AppPreferences.getAuthToken();
    if (token == null || token.isEmpty) throw AuthException('يجب تسجيل الدخول');
    final uri = Uri.parse('$kApiBaseUrl/api/user/profile-photo');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(http.MultipartFile.fromBytes(
      'profile_photo',
      imageBytes,
      filename: filename,
    ));
    final client = getApiClient();
    try {
      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final map = jsonDecode(response.body) as Map<String, dynamic>?;
        final msg = map?['message'] as String? ?? map?['errors']?.toString() ?? 'فشل رفع الصورة';
        throw AuthException(msg.toString());
      }
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      final data = map?['data'] as Map<String, dynamic>?;
      final url = (data?['profile_photo'] as String?)?.replaceAll(RegExp(r'\s'), '').trim();
      if (url == null || url.isEmpty) throw AuthException('لم يُرجع السيرفر رابط الصورة');
      return url;
    } finally {
      client.close();
    }
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profilePhoto;
  final String verificationStatus;
  final bool documentsVerified;
  final bool phoneVerified;
  final double? rating;
  final int ratingsCount;
  final int shipmentsCount;
  final int tripsCount;
  final int? homeCountryId;
  final int? homeCityId;
  final String? homeCountryName;
  final String? homeCityName;
  final int? travelCountryId;
  final int? travelCityId;
  final String? travelCountryName;
  final String? travelCityName;
  final String? bankIban;
  final String? bankName;
  final String? bankAccountHolder;
  final String? homePhone;
  final String? travelPhone;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePhoto,
    this.verificationStatus = 'unverified',
    this.documentsVerified = false,
    this.phoneVerified = false,
    this.rating,
    this.ratingsCount = 0,
    this.shipmentsCount = 0,
    this.tripsCount = 0,
    this.homeCountryId,
    this.homeCityId,
    this.homeCountryName,
    this.homeCityName,
    this.travelCountryId,
    this.travelCityId,
    this.travelCountryName,
    this.travelCityName,
    this.bankIban,
    this.bankName,
    this.bankAccountHolder,
    this.homePhone,
    this.travelPhone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePhoto: (json['profile_photo'] as String?)?.replaceAll(RegExp(r'\s'), '').trim(),
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      documentsVerified: json['documents_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
      shipmentsCount: (json['shipments_count'] as num?)?.toInt() ?? 0,
      tripsCount: (json['trips_count'] as num?)?.toInt() ?? 0,
      homeCountryId: (json['home_country_id'] as num?)?.toInt(),
      homeCityId: (json['home_city_id'] as num?)?.toInt(),
      homeCountryName: json['home_country_name'] as String?,
      homeCityName: json['home_city_name'] as String?,
      travelCountryId: (json['travel_country_id'] as num?)?.toInt(),
      travelCityId: (json['travel_city_id'] as num?)?.toInt(),
      travelCountryName: json['travel_country_name'] as String?,
      travelCityName: json['travel_city_name'] as String?,
      bankIban: json['bank_iban'] as String?,
      bankName: json['bank_name'] as String?,
      bankAccountHolder: json['bank_account_holder'] as String?,
      homePhone: json['home_phone'] as String?,
      travelPhone: json['travel_phone'] as String?,
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
