// lib/utils/api_headers.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiHeaders {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Header standar untuk semua request ke backend (via Ngrok).
  /// Menyertakan ngrok-skip-browser-warning agar tidak diblokir browser.
  static Future<Map<String, String>> get({bool withAuth = true}) async {
    String? token;
    if (withAuth) {
      token = await _storage.read(key: 'auth_token');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Khusus untuk multipart (tanpa Content-Type, karena boundary di-set otomatis).
  static Future<Map<String, String>> getMultipart({bool withAuth = true}) async {
    String? token;
    if (withAuth) {
      token = await _storage.read(key: 'auth_token');
    }

    return {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}