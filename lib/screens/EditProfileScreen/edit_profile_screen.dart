// lib/screens/EditProfileScreen/edit_profile_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  bool _isLoading = false;
  
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _namaController.text = auth.userName;
    _emailController.text = auth.userEmail;
    _hpController.text = auth.userPhone;
    _alamatController.text = 'Jl. Contoh No. 123, Lowokwaru, Malang, Jawa Timur 65145';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  String _getValidImageUrl(String url) {
    if (url.isEmpty) return '';
    final baseUrl = AppConfig.baseUrl;
    return url
        .replaceAll('http://localhost:5000', baseUrl)
        .replaceAll('http://192.168.1.129:5000', baseUrl)
        .replaceAll('http://10.200.118.253:5000', baseUrl)
        .replaceAll('http://10.200.119.241:5000', baseUrl);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null) return;
    setState(() => _isUploading = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.uploadAvatar(_imageBytes!, _imageName ?? 'avatar.jpg');
    setState(() => _isUploading = false);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else if (mounted) {
      setState(() {
        _imageBytes = null;
        _imageName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui'), backgroundColor: Colors.green));
    }
  }

  Future<void> _deleteImage() async {
    setState(() => _isUploading = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.deleteAvatar();
    setState(() => _isUploading = false);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil dihapus'), backgroundColor: Colors.green));
    }
  }

  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40, right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.updateProfile(
      name: _namaController.text.trim(),
      email: _emailController.text.trim(),
      phone: _hpController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (error == null && mounted) _showSuccessModal();
    else if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal menyimpan perubahan'), backgroundColor: Colors.red));
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
              const Text('Edit Profil Berhasil!', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
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
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profil', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildAvatarSection(auth),
              const SizedBox(height: 24),
              _buildField(label: 'Nama Lengkap', controller: _namaController, icon: Icons.person_outline),
              const SizedBox(height: 12),
              _buildField(label: 'Alamat', controller: _alamatController, icon: Icons.location_on_outlined, maxLines: 3),
              const SizedBox(height: 12),
              _buildField(label: 'Alamat Email', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildField(label: 'Nomor Handphone', controller: _hpController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildInfoBanner(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0267D2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600)),
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF0267D2), textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600)),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(AuthProvider auth) {
    final photoUrl = auth.userPhotoUrl.isNotEmpty ? _getValidImageUrl(auth.userPhotoUrl) : '';
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (photoUrl.isNotEmpty) {
              _openImagePreview(photoUrl);
            } else {
              _pickImage();
            }
          },
          child: Stack(
            children: [
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFF),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 4))],
                ),
                child: ClipOval(
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover, width: 96, height: 96)
                      : (photoUrl.isNotEmpty
                          ? Image.network(photoUrl, fit: BoxFit.cover, width: 96, height: 96,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Text('AP', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF004590)))))
                          : const Center(child: Text('AP', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF004590))))),
                ),
              ),
              if (_isUploading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF0267D2))),
                ),
              if (!_isUploading && photoUrl.isNotEmpty)
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _deleteImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.delete, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 12, color: Colors.black),
              SizedBox(width: 6),
              Text('Ubah Foto Profil', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, required IconData icon, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8))),
          child: TextField(
            controller: controller, maxLines: maxLines, keyboardType: keyboardType,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
            decoration: InputDecoration(icon: Icon(icon, color: const Color(0xFF0267D2), size: 18), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield, size: 16, color: Color(0xFF0267D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Data Terlindungi & Akurat', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                SizedBox(height: 2),
                Text('Alamat presisi membantu armada LocalMart menjaga suhu frozen food tetap beku optimal selama pengantaran.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, height: 1.35, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}