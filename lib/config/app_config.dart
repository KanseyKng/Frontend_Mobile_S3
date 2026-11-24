// lib/config/app_config.dart
class AppConfig {
  // ==========================================
  // URL BACKEND RAILWAY (WAJIB HTTPS)
  // ==========================================
  static const String baseUrl = 'https://backendmobilewebs3-production.up.railway.app';

  // ==========================================
  // JANGAN UBAH DI BAWAH INI
  // ==========================================
  static String get apiUrl => '$baseUrl/api';
  static String get imagecUrl => '$baseUrl/uploads';
}

 // OPSI 1: IP Lokal (Untuk Ngoding Bareng Tim di WiFi yang sama)
  // static const String baseUrl = 'http://:5000';