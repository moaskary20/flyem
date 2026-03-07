import 'package:http/http.dart' as http;

/// Default client (e.g. on web where dart:io is not available).
http.Client getApiClient() => http.Client();
