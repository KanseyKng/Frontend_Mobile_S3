// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../config/app_config.dart'; // ✅ Import config

class AuthProvider extends ChangeNotifier {
  // ✅ Hapus logika kIsWeb/Platform, gunakan AppConfig
  String get baseUrl => AppConfig.apiUrl;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isCheckingSession = true; 
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isCheckingSession => _isCheckingSession;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;

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
        return null;
      } else {
        return data['message'] ?? 'Registrasi gagal.';
      }
    } catch (e) {
      debugPrint('ERROR REGISTER API: $e');
      return 'Gagal terhubung ke server.';
    }
  }

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

        await _secureStorage.write(key: 'auth_token', value: token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_role', _userRole);

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

  Future<void> checkSession() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      if (token == null) {
        _isCheckingSession = false;
        notifyListeners();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _userRole = prefs.getString('user_role') ?? '';
      _isLoggedIn = true;
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        await logout();
      }
    } catch (e) {
      debugPrint('ERROR CHECK SESSION: $e');
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');

    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userRole = '';

    notifyListeners();
  }
}