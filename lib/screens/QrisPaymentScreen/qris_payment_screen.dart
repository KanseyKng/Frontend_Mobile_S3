// lib/screens/QrisPaymentScreen/qris_payment_screen.dart
import 'dart:io'; // Tetap dipakai untuk Platform check di pengiriman
import 'dart:typed_data'; // ✅ Tambahan untuk membaca gambar di Web
import 'package:flutter/foundation.dart'; // ✅ Tambahan untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/logo_widget.dart';
import '../OrderListScreen/order_list_screen.dart';
import '../../config/app_config.dart'; 

class QrisPaymentScreen extends StatefulWidget {
  final int total;
  final String orderId; 

  const QrisPaymentScreen({
    super.key, 
    required this.total,
    required this.orderId, 
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  bool showPetunjuk = true;
  
  // ✅ PERUBAHAN: Gunakan XFile dan Uint8List agar support Web
  XFile? _pickedFile; 
  Uint8List? _imageBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Baca file menjadi bytes agar bisa ditampilkan di Web & HP
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _handlePaymentSuccess() async {
    if (_pickedFile == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap unggah bukti transfer terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiUrl}/transactions/upload-proof/${widget.orderId}'),
      );
      
      // ✅ PERUBAHAN: Cara mengirim file yang support Web & Android/iOS
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'proof',
            _imageBytes!,
            filename: _pickedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('proof', _pickedFile!.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        if (mounted) {
          context.read<CartProvider>().clear(); 
          context.read<OrderProvider>().fetchOrders(); 

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OrderListScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'] ?? 'Gagal mengunggah bukti. Coba lagi.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Koneksi gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCountdownBox(),
                    const SizedBox(height: 12),
                    _buildAmountCard(),
                    const SizedBox(height: 16),
                    _buildQrisCard(),
                    const SizedBox(height: 16),
                    _buildUploadBukti(),
                    const SizedBox(height: 16),
                    _buildPrimaryActions(),
                    const SizedBox(height: 16),
                    _buildPetunjuk(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const LogoHorizontal(),
          const SizedBox(width: 12),
          const Text(
            'Pembayaran QRIS',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox() {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time,
                    size: 12, color: Color(0xFF93000A)),
                SizedBox(width: 6),
                Text(
                  'Selesaikan pembayaran dalam:',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF93000A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '14:31',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFFBA1A1A),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'menit',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Batas waktu pembayaran sebelum pesanan dan slot kurir kedaluwarsa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Color(0xFF676E76),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Tagihan Pembayaran',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: Color(0xFF4E565D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rp ${_formatNumber(widget.total)}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E3FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Menunggu Bayar',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D486D),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE6E8EA)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'QRIS',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: Color(0xFFBA1A1A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Standar Pembayaran Nasional',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E565D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'IKOBANA Frozenfood',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2,
                        size: 120, color: AppColors.textPrimary),
                    SizedBox(height: 8),
                    Text(
                      'QRIS Ikobana',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBukti() {
    return Container(
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
            'Unggah Bukti Transfer',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              // ✅ PERUBAHAN: Tampilkan gambar menggunakan Image.memory (Support Web)
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Klik untuk pilih foto dari galeri',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handlePaymentSuccess,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.verified, size: 16),
            label: Text(_isLoading ? 'Mengunggah...' : 'Saya Sudah Bayar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('Ganti Metode Pembayaran'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetunjuk() {
    final steps = [
      'Buka aplikasi mobile banking atau e-wallet favoritmu.',
      'Pilih menu Bayar atau Scan QR / QRIS.',
      'Arahkan kamera ke kode QR di atas.',
      'Masukkan PIN Anda untuk menyelesaikan pembayaran.',
      'Screenshot bukti transfer, lalu unggah di form di atas.',
    ];

    return Container(
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
          GestureDetector(
            onTap: () => setState(() => showPetunjuk = !showPetunjuk),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD5E3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline,
                          color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Petunjuk Cara Pembayaran',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  showPetunjuk
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF455F87),
                ),
              ],
            ),
          ),
          if (showPetunjuk) ...[
            const SizedBox(height: 12),
            ...List.generate(steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6E8EA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}