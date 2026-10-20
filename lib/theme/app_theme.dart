// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ============ OLD COLORS (Home, Cart, Checkout, dll) ============
  // Backgrounds
  static const Color background = Color(0xFFF7F9FB);
  static const Color cardWhite = Colors.white;
  static const Color inputBg = Color(0xFFF2F4F6);

  // Primary
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryDark = Color(0xFF001C3B);

  // Text
  static const Color textPrimary = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF434655);
  static const Color textMuted = Color(0xFF737686);

  // Utility
  static const Color divider = Color(0xFFE6E8EA);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color star = Color(0xFFF59E0B);

  // Info/Modal
  static const Color info = Color(0xFF0267D2);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFDBEAFE);

  // Pastel
  static const Color pastelBlue = Color(0xFFB5D0FD);
  static const Color pastelOrange = Color(0xFFFFF3E0);

  // ============ NEW COLORS (Profile, Privacy, Help Center) ============
  // Background & Base
  static const Color bgProfile = Color(0xFFFAF8FF); // Background baru
  static const Color primaryProfile = Color(0xFF004FA5); // Biru Profil
  
  // Text Colors
  static const Color textDark = Color(0xFF131B2E); // Text utama baru
  static const Color textGrey = Color(0xFF414753); // Text sekunder baru
  static const Color textDarkBlue = Color(0xFF001B3F); // Text khusus Privasi
  
  // Accents & Containers
  static const Color lightBlue = Color(0xFFD7E2FF); // Badge & Highlight
  static const Color veryLightBlue = Color(0xFFF2F3FF); // List item bg
  static const Color borderLight = Color(0xFFEAEDFF); // Divider & Border
  static const Color borderSubtle = Color(0xFFC2C6D5); // Border FAQ

  // Special Colors
  static const Color logoutRed = Color(0xFFA70519); // Tombol Logout
  static const Color greenAccent = Color(0xFF6CF8BB); // Icon Help Center
  static const Color greenDark = Color(0xFF00714D); // Text Help Center
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      // Font utama: Plus Jakarta Sans (dari Figma)
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
    );
  }
}