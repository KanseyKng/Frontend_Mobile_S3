// lib/config/app_config.dart
class AppConfig {
  // ==========================================
  // ⚠️ UBAH DI SINI SAJA SAAT PINDAH WIFI / PRESENTASI
  // ==========================================

  // OPSI 1: IP Lokal (Untuk Ngoding Bareng Tim di WiFi yang sama)
  static const String baseUrl = 'http://10.200.116.23:5000';

  // OPSI 2: Ngrok (Untuk Presentasi - hapus // di bawah, dan beri // pada OPSI 1)
  // static const String baseUrl = 'https://ikobana-api.ngrok-free.app';

  // ==========================================
  // JANGAN UBAH DI BAWAH INI
  // ==========================================
  static String get apiUrl => '$baseUrl/api';
  static String get imageUrl => '$baseUrl/uploads';
}