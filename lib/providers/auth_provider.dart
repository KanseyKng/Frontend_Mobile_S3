// lib/providers/auth_provider.dart
import 'dart:convert';
import 'dart:typed_data'; // ✅ Tambahan untuk Web
import 'package:flutter/foundation.dart'; // ✅ Tambahan untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  String get baseUrl => AppConfig.apiUrl;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isCheckingSession = true; 
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userRole = '';
  String _userPhotoUrl = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isCheckingSession => _isCheckingSession;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userRole => _userRole;
  String get userPhotoUrl => _userPhotoUrl;

  Future<String?> register({required String name, required String email, required String phone, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'phone': phone, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) return null;
      return data['message'] ?? 'Registrasi gagal.';
    } catch (e) {
      debugPrint('ERROR REGISTER API: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<String?> login({required String identifier, required String password}) async {
    try {
      final isEmail = identifier.contains('@');
      final body = {if (isEmail) 'email': identifier else 'phone': identifier, 'password': password};

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
        _userPhone = user['phone'] ?? '';
        _userRole = user['role'];
        _userPhotoUrl = user['photoUrl'] ?? '';

        await _secureStorage.write(key: 'auth_token', value: token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_phone', _userPhone);
        await prefs.setString('user_role', _userRole);
        await prefs.setString('user_photo_url', _userPhotoUrl);

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
      if (token == null) { _isCheckingSession = false; notifyListeners(); return; }

      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _userPhone = prefs.getString('user_phone') ?? '';
      _userRole = prefs.getString('user_role') ?? '';
      _userPhotoUrl = prefs.getString('user_photo_url') ?? '';
      _isLoggedIn = true;
      
      final response = await http.get(Uri.parse('$baseUrl/auth/me'), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode != 200) await logout();
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
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('user_photo_url');

    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _userRole = '';
    _userPhotoUrl = '';

    notifyListeners();
  }

  Future<String?> updateProfile({required String name, required String email, required String phone}) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'email': email, 'phone': phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = data['data'];
        _userName = updatedUser['name'];
        _userEmail = updatedUser['email'];
        _userPhone = updatedUser['phone'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_phone', _userPhone);

        notifyListeners();
        return null;
      } else {
        return data['message'] ?? 'Gagal memperbarui profil.';
      }
    } catch (e) {
      debugPrint('ERROR UPDATE PROFILE: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  // ==========================================
  // ✅ UPLOAD AVATAR (Support Web & Mobile)
  // ==========================================
  Future<String?> uploadAvatar(Uint8List bytes, String filename) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/upload-avatar'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      
      // ✅ Gunakan fromBytes agar support Web
      request.files.add(http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: filename,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _userPhotoUrl = data['data']['photoUrl'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_url', _userPhotoUrl);
        notifyListeners();
        return null;
      } else {
        return data['message'] ?? 'Gagal mengunggah foto profil.';
      }
    } catch (e) {
      debugPrint('ERROR UPLOAD AVATAR: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<String?> deleteAvatar() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete-avatar'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _userPhotoUrl = '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_photo_url');
        notifyListeners();
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Gagal menghapus foto profil.';
      }
    } catch (e) {
      debugPrint('ERROR DELETE AVATAR: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<String?> changePassword({required String currentPassword, required String newPassword, required String confirmPassword}) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword, 'confirmPassword': confirmPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return null;
      } else {
        return data['message'] ?? 'Gagal mengubah password.';
      }
    } catch (e) {
      debugPrint('ERROR CHANGE PASSWORD: $e');
      return 'Gagal terhubung ke server.';
    }
  }
}