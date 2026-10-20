// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ PAKAI INI

class AuthProvider extends ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Sesuaikan jika pakai localhost

  // ✅ IMPLEMENTASI FLUTTER SECURE STORAGE
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;

  // ==========================================
  // FUNGSI LOGIN
  // ==========================================
  Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final isEmail = identifier.contains('@');
      final body = {
        if (isEmail) 'email': identifier else 'phone': identifier,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data']['user'];
        final token = data['data']['token'];

        _isLoggedIn = true;
        _userName = user['name']; 
        _userEmail = user['email'] ?? '';
        _userRole = user['role'];

        // ✅ SIMPAN TOKEN KE SECURE STORAGE (Aman)
        await _secureStorage.write(key: 'auth_token', value: token);
        
        // Simpan data user biasa ke SharedPreferences (Opsional)
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('auth_user', jsonEncode(user));

        notifyListeners();
        return null; 
      } else {
        return data['message'] ?? 'Email/Password salah';
      }
    } catch (e) {
      return 'Gagal terhubung ke server.';
    }
  }

  // ==========================================
  // CEK SESSION (Auto-Login)
  // ==========================================
  Future<bool> checkSession() async {
    try {
      // ✅ BACA TOKEN DARI SECURE STORAGE
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['data'];

        _isLoggedIn = true;
        _userName = user['name'];
        _userEmail = user['email'] ?? '';
        _userRole = user['role'];

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================
  Future<void> logout() async {
    // ✅ HAPUS TOKEN DARI SECURE STORAGE
    await _secureStorage.delete(key: 'auth_token');

    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userRole = '';

    notifyListeners();
  }
}