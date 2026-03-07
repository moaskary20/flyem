import 'dart:io';

import 'package:flyem_app/core/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// على الموبايل: إن كان السيرفر يستخدم شهادة لا يثق بها الجهاز، نستخدم عميلاً يتجاوز التحقق.
http.Client getApiClient() {
  if (!kAllowInsecureSSL) return http.Client();
  final client = HttpClient();
  client.badCertificateCallback = (_, __, ___) => true;
  return IOClient(client);
}
