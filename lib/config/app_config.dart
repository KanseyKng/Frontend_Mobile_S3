// lib/config/app_config.dart
class AppConfig {
  // ==========================================
  // ⚠️ UBAH DI SINI SAJA SAAT PINDAH WIFI / PRESENTASI
  // ==========================================

  // OPSI 1: IP Lokal (Untuk Ngoding Bareng Tim di WiFi yang sama)
  // static const String baseUrl = 'http://192.168.1.16:5000';

  // OPSI 2: Ngrok (Untuk Presentasi - hapus // di bawah, dan beri // pada OPSI 1)
   static const String baseUrl = 'https://uncurious-implosive-uninjured.ngrok-free.dev';

  // ==========================================
  // JANGAN UBAH DI BAWAH INI
  // ==========================================
  static String get apiUrl => '$baseUrl/api';
  static String get imagecUrl => '$baseUrl/uploads';
}