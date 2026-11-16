// lib/screens/GantiPasswordScreen/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperLower = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password);
      _hasNumber = RegExp(r'\d').hasMatch(password);
      _hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi'), backgroundColor: Colors.red));
      return;
    }
    if (!_hasMinLength || !_hasUpperLower || !_hasNumber || !_hasSymbol) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru belum memenuhi semua persyaratan'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    setState(() => _isLoading = false);
    if (error == null && mounted) {
      _showSuccessModal();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal mengubah password'), backgroundColor: Colors.red));
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0267D2), shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF0267D2).withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Edit Password Berhasil!', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 44,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0267D2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Selesai', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF172033)), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ganti Password', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF172033))),
            Text('Amankan akunmu dengan password baru', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF647084))),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0267D2), Color(0xFF7A8BFF)]), shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFF5267F5).withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 10))],
                      ),
                      child: const Icon(Icons.shield, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text('Enkripsi Akun 256-bit Terproteksi', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF647084))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildPasswordField(label: 'Password Saat Ini', controller: _currentPasswordController, obscureText: _obscureCurrent, onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent)),
              const SizedBox(height: 14),
              _buildPasswordField(label: 'Password Baru', controller: _newPasswordController, obscureText: _obscureNew, onToggle: () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 14),
              _buildPasswordField(label: 'Konfirmasi Password Baru', controller: _confirmPasswordController, obscureText: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECECF5))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFEEF0FD), borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: const [
                              Icon(Icons.lightbulb, color: Color(0xFF0267D2), size: 16),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tips Password', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF172033))),
                                    SizedBox(height: 2),
                                    Text('Gunakan kombinasi huruf besar, huruf kecil, angka, dan simbol untuk keamanan yang lebih baik.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF647084))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Persyaratan Password Baru:', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
                    const SizedBox(height: 8),
                    _buildRequirement(r'Minimal 8 karakter', _hasMinLength),
                    _buildRequirement(r'Mengandung huruf besar dan kecil', _hasUpperLower),
                    _buildRequirement(r'Mengandung angka', _hasNumber),
                    _buildRequirement(r'Mengandung simbol (!@#$%^&*)', _hasSymbol),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0267D2), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                    shadowColor: const Color(0xFF5267F5).withValues(alpha: 0.38),
                    textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Simpan Password'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Sesi aktif di perangkat lain akan tetap aman setelah kata sandi diperbarui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF647084)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required String label, required TextEditingController controller, required bool obscureText, required VoidCallback onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
        const SizedBox(height: 6),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECECF5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Color(0xFF647084), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller, obscureText: obscureText,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF172033)),
                  decoration: InputDecoration(
                    hintText: label == 'Password Saat Ini' ? 'Masukkan password saat ini' : (label == 'Password Baru' ? 'Masukkan password baru' : 'Ulangi password baru'),
                    hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0x99647084)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF647084), size: 20),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: isValid ? const Color(0xFF0267D2) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: isValid ? const Color(0xFF0267D2) : const Color(0xFFECECF5)),
            ),
            child: isValid ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: isValid ? const Color(0xFF0267D2) : const Color(0xFF647084))),
        ],
      ),
    );
  }
}