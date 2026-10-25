// lib/screens/RegisterScreen/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Tambahkan ini
import '../../theme/app_theme.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/google_button.dart';
import '../../widgets/inputs/success_modal.dart';
import '../../widgets/inputs/error_modal.dart'; // ✅ Tambahkan ini
import '../../widgets/common/logo_widget.dart';
import '../../providers/auth_provider.dart'; // ✅ Tambahkan ini

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool showPassword = false;
  bool showKonfirmasi = false;
  bool setujuSyarat = false;
  bool isLoading = false; // ✅ State untuk loading

  // ✅ Tambahkan Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ✅ Fungsi Register
  Future<void> _handleRegister() async {
    // Validasi Dasar
    if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
      _showError('Data Belum Lengkap', 'Nama dan Nomor WhatsApp wajib diisi.');
      return;
    }
    if (passwordController.text.length < 8) {
      _showError('Password Lemah', 'Kata sandi minimal 8 karakter.');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError('Konfirmasi Salah', 'Kata sandi dan konfirmasi tidak cocok.');
      return;
    }
    if (!setujuSyarat) {
      _showError('Syarat Belum Disetujui', 'Centang persetujuan Syarat & Ketentuan.');
      return;
    }

    setState(() => isLoading = true);

    // Panggil API Backend
    final error = await context.read<AuthProvider>().register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          password: passwordController.text,
        );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error == null) {
      // ✅ Berhasil
      SuccessModal.show(
        context,
        onGoToLogin: () {
          Navigator.pop(context); // Kembali ke Login
        },
      );
    } else {
      // ❌ Gagal (misal email sudah terdaftar)
      _showError('Registrasi Gagal', error);
    }
  }

  void _showError(String title, String desc) {
    ErrorModal.show(
      context,
      title: title,
      description: desc,
      hint: 'Periksa kembali data Anda',
      onRetry: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Center(child: LogoSquare(size: 84)),
              const SizedBox(height: 12),
              const Text(
                'Buat Akun LOCALMART',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Daftar dan nikmati kemudahan pesan frozen food segar siap saji langsung ke rumah Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FORM CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Lengkap
                    _buildLabel('Nama Lengkap', wajib: true),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: nameController,
                      hint: 'Contoh: Andi Pratama',
                      prefixIcon: Icons.person_outline,
                      withShadow: true,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),

                    // Nomor WhatsApp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Nomor WhatsApp', wajib: true),
                        const Text(
                          'Kirim nota & update kurir',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '+62',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            controller: phoneController,
                            hint: '812 3456 7890',
                            prefixIcon: Icons.phone_outlined,
                            withShadow: true,
                            backgroundColor: Colors.white,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Email
                    _buildLabel('Email'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: emailController,
                      hint: 'nama@email.com',
                      prefixIcon: Icons.email_outlined,
                      withShadow: true,
                      backgroundColor: Colors.white,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Kata Sandi
                    _buildLabel('Kata Sandi', wajib: true),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: passwordController,
                      hint: 'Minimal 8 karakter',
                      prefixIcon: Icons.lock_outline,
                      withShadow: true,
                      backgroundColor: Colors.white,
                      obscureText: !showPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () => setState(() => showPassword = !showPassword),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Konfirmasi
                    _buildLabel('Konfirmasi Kata Sandi', wajib: true),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: confirmPasswordController,
                      hint: 'Ulangi kata sandi Anda',
                      prefixIcon: Icons.refresh,
                      withShadow: true,
                      backgroundColor: Colors.white,
                      obscureText: !showKonfirmasi,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showKonfirmasi ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () => setState(() => showKonfirmasi = !showKonfirmasi),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Checkbox Syarat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: setujuSyarat,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onChanged: (v) => setState(() => setujuSyarat = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                height: 1.3,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: 'Saya menyetujui '),
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' serta '),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' Ikobana Frozenfood.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TOMBOL DAFTAR
                    PrimaryButton(
                      label: isLoading ? 'Memproses...' : 'Daftar Sekarang',
                      showArrow: !isLoading,
                      onPressed: isLoading ? null : _handleRegister,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider, height: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau daftar lebih cepat dengan',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider, height: 1)),
                ],
              ),
              const SizedBox(height: 16),

              GoogleButton(
                label: 'Daftar dengan Google',
                backgroundColor: Colors.white,
                onPressed: () {},
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk di Sini',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool wajib = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (wajib) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}