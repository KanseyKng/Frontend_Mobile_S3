// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 

class AuthProvider extends ChangeNotifier {
  // ✅ 1. URL DINAMIS (Otomatis deteksi Web atau Emulator)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';       // Untuk Chrome/Web
    } else {
      return 'http://10.0.2.2:5000/api';        // Untuk Emulator Android
      // Catatan: Jika pakai HP fisik, ganti 10.0.2.2 dengan IP WiFi laptopmu (misal: 192.168.1.xx)
    }
  }

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
  // ✅ 2. FUNGSI REGISTER (BARU DITAMBAHKAN)
  // ==========================================
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return null; // ✅ Sukses, akun tersimpan di database!
      } else {
        return data['message'] ?? 'Registrasi gagal.'; // ❌ Gagal (misal email sudah ada)
      }
    } catch (e) {
      debugPrint('ERROR REGISTER API: $e');
      return 'Gagal terhubung ke server.';
    }
  }

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

        // Simpan token ke Secure Storage
        await _secureStorage.write(key: 'auth_token', value: token);
        
        notifyListeners();
        return null; 
      } else {
        return data['message'] ?? 'Email/Password salah';
      }
    } catch (e) {
      debugPrint('ERROR LOGIN API: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  // ==========================================
  // CEK SESSION (Auto-Login)
  // ==========================================
  Future<bool> checkSession() async {
    try {
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
    await _secureStorage.delete(key: 'auth_token');

    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userRole = '';

    notifyListeners();
  }
}