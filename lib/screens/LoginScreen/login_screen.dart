// lib/screens/LoginScreen/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/google_button.dart';
import '../../widgets/common/logo_widget.dart';
import '../../widgets/inputs/error_modal.dart';
import '../../providers/auth_provider.dart';
import '../RegisterScreen/register_screen.dart';
import '../HomeScreen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool ingatSaya = true;
  bool showPassword = false;
  bool isLoading = false; 
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ErrorModal.show(
        context,
        title: 'Email atau Password Kosong',
        description: 'Email dan kata sandi wajib diisi.',
        hint: 'Periksa kembali form Anda',
        onRetry: () {},
        onForgotPassword: () {},
      );
      return;
    }

    setState(() => isLoading = true);

    final error = await context.read<AuthProvider>().login(
          identifier: email,
          password: password,
        );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      ErrorModal.show(
        context,
        title: 'Login Gagal',
        description: error,
        hint: 'Periksa email dan password Anda',
        onRetry: () {},
        onForgotPassword: () {},
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: LogoHorizontal(),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Masuk untuk belanja frozen food segar & nikmati promo gratis ongkir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
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
                      const Text(
                        'Email / No. HP',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: emailController,
                        hint: 'Contoh: 08123456789 atau nama@email.com',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kata Sandi',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lupa Kata Sandi?',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: passwordController,
                        hint: 'Masukkan kata sandi',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Checkbox(
                              value: ingatSaya,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                              onChanged: (v) {
                                setState(() => ingatSaya = v ?? false);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Ingat Saya di perangkat ini',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: isLoading ? 'Memproses...' : 'Masuk Sekarang',
                        showArrow: !isLoading,
                        onPressed: isLoading ? null : _handleLogin,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.divider, height: 1),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'atau masuk dengan',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.divider, height: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GoogleButton(
                        label: 'Masuk dengan Google',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Daftar Akun Baru',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}