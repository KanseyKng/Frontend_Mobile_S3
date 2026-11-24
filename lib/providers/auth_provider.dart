// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../utils/api_headers.dart';
import 'cart_provider.dart';
import 'order_provider.dart';
import 'notification_provider.dart';
import 'address_provider.dart';
import 'wishlist_provider.dart';

class AuthProvider extends ChangeNotifier {
  String get baseUrl => AppConfig.apiUrl;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final WishlistProvider? wishlistProvider;
  final CartProvider? cartProvider;
  final OrderProvider? orderProvider;
  final NotificationProvider? notificationProvider;
  final AddressProvider? addressProvider;

  AuthProvider({
    this.wishlistProvider,
    this.cartProvider,
    this.orderProvider,
    this.notificationProvider,
    this.addressProvider,
  });

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

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Format response server tidak valid.');
    } on FormatException {
      throw Exception('Response server bukan JSON yang valid.');
    }
  }

  String _getMessage(
    Map<String, dynamic> data, {
    String fallback = 'Permintaan gagal.',
  }) {
    return data['message']?.toString() ?? fallback;
  }

  void _clearAllUserData() {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _userRole = '';
    _userPhotoUrl = '';

    cartProvider?.clear();
    wishlistProvider?.clearWishlist();
    orderProvider?.clear();
    notificationProvider?.clear();
    addressProvider?.clear();
  }

  Future<void> _clearSession() async {
    await _secureStorage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('user_photo_url');

    _clearAllUserData();
  }

  Future<void> _saveUserData(Map<String, dynamic> user) async {
    _userName = user['name']?.toString() ?? '';
    _userEmail = user['email']?.toString() ?? '';
    _userPhone = user['phone']?.toString() ?? '';
    _userRole = user['role']?.toString() ?? '';
    _userPhotoUrl = user['photoUrl']?.toString() ?? '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('user_phone', _userPhone);
    await prefs.setString('user_role', _userRole);
    await prefs.setString('user_photo_url', _userPhotoUrl);
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final headers = await ApiHeaders.get(withAuth: false);
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
      final data = _decodeResponse(response);
      if (response.statusCode == 201 && data['success'] == true) return null;
      return _getMessage(data, fallback: 'Registrasi gagal.');
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
      _clearAllUserData();

      final isEmail = identifier.contains('@');
      final body = {
        if (isEmail) 'email': identifier else 'phone': identifier,
        'password': password,
      };

      final headers = await ApiHeaders.get(withAuth: false);
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data']['user'];
        final token = data['data']['token'];

        if (user == null || token == null) {
          return 'Data login dari server tidak lengkap.';
        }

        await _secureStorage.write(
          key: 'auth_token',
          value: token.toString(),
        );
        await _saveUserData(Map<String, dynamic>.from(user));

        _isLoggedIn = true;
        _isCheckingSession = false;
        notifyListeners();
        return null;
      }
      return _getMessage(data,
          fallback: 'Email, nomor telepon, atau password salah.');
    } catch (e) {
      debugPrint('ERROR LOGIN API: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<void> checkSession() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        _clearAllUserData();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _userPhone = prefs.getString('user_phone') ?? '';
      _userRole = prefs.getString('user_role') ?? '';
      _userPhotoUrl = prefs.getString('user_photo_url') ?? '';

      final headers = await ApiHeaders.get();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        _isLoggedIn = true;
      } else {
        await _clearSession();
      }
    } catch (e) {
      debugPrint('ERROR CHECK SESSION: $e');
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearSession();
    _isCheckingSession = false;
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final headers = await ApiHeaders.get();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
        body: jsonEncode({'name': name, 'email': email, 'phone': phone}),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = Map<String, dynamic>.from(data['data']);
        _userName = updatedUser['name']?.toString() ?? '';
        _userEmail = updatedUser['email']?.toString() ?? '';
        _userPhone = updatedUser['phone']?.toString() ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_phone', _userPhone);

        notifyListeners();
        return null;
      }
      return _getMessage(data, fallback: 'Gagal memperbarui profil.');
    } catch (e) {
      debugPrint('ERROR UPDATE PROFILE: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<String?> uploadAvatar(Uint8List bytes, String filename) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final headers = await ApiHeaders.getMultipart();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/upload-avatar'),
      );
      request.headers.addAll(headers);
      request.files.add(
        http.MultipartFile.fromBytes('avatar', bytes, filename: filename),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        _userPhotoUrl = data['data']['photoUrl']?.toString() ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_url', _userPhotoUrl);
        notifyListeners();
        return null;
      }
      return _getMessage(data, fallback: 'Gagal mengunggah foto profil.');
    } catch (e) {
      debugPrint('ERROR UPLOAD AVATAR: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<String?> deleteAvatar() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final headers = await ApiHeaders.get();
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete-avatar'),
        headers: headers,
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        _userPhotoUrl = '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_photo_url');
        notifyListeners();
        return null;
      }
      return _getMessage(data, fallback: 'Gagal menghapus foto profil.');
    } catch (e) {
      debugPrint('ERROR DELETE AVATAR: $e');
      return 'Gagal terhubung ke server.';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return 'Sesi berakhir, silakan login ulang.';

      final headers = await ApiHeaders.get();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = _decodeResponse(response);
      if (response.statusCode == 200 && data['success'] == true) return null;
      return _getMessage(data, fallback: 'Gagal mengubah password.');
    } catch (e) {
      debugPrint('ERROR CHANGE PASSWORD: $e');
      return 'Gagal terhubung ke server.';
    }
  }
}