// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_model.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/LoginScreen/login_screen.dart';    // ✅ DIUBAH (tambah LoginScreen/)

void main() {
  Map jsonResponse = {
    'name': 'Budi Santoso',
    'age': 22,
  };
  UserModel user = UserModel.fromJson(jsonResponse);
  debugPrint('=== DATA USER ===');
  debugPrint('Nama: ${user.name}');
  debugPrint('ID: ${user.id}');
  debugPrint('Email: ${user.email}');
  debugPrint('Umur: ${user.age}');
  debugPrint('Status: ${user.isActive}');
  debugPrint('=================');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ikobana Frozen Food',
        theme: AppTheme.light(),
        home: const LoginScreen(),
      ),
    );
  }
}