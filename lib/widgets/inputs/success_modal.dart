// lib/widgets/success_modal.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SuccessModal extends StatelessWidget {
  final VoidCallback onGoToLogin;

  const SuccessModal({super.key, required this.onGoToLogin});

  /// Helper untuk memanggil modal dari mana saja
  static Future<void> show(BuildContext context,
      {required VoidCallback onGoToLogin}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => SuccessModal(onGoToLogin: onGoToLogin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Icon Check Biru dengan shadow =====
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),

            // ===== Judul =====
            const Text(
              'Registrasi Berhasil!',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            // ===== Deskripsi =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Akun IKOBANA FROZENFOOD kamu berhasil dibuat. Sekarang kamu sudah bisa mulai berbelanja frozen food favoritmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  height: 1.6,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== Badge Info =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.infoBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Selamat datang di IKOBANA FROZEENFOOD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Tombol Outlined "Ke Halaman Login" =====
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // tutup modal dulu
                  onGoToLogin(); // lalu jalankan aksi
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.info),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ke Halaman Login',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}