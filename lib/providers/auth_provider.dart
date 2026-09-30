// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = 'Andi';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  void login({required String email, String? name}) {
    _isLoggedIn = true;
    _userEmail = email;
    if (name != null && name.isNotEmpty) _userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = '';
    notifyListeners();
  }
}