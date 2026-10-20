// lib/screens/HelpCenterScreen/help_center_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildGreetingSection(),
                    const SizedBox(height: 24),
                    // ✅ PERBAIKAN: Tambahkan context
                    _buildFaqSection(context),
                    const SizedBox(height: 24),
                    _buildBottomSupportCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFFAF8FF).withValues(alpha: 0.8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF131B2E)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Pusat Bantuan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.45,
              color: Color(0xFF131B2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF6CF8BB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.ac_unit, size: 14, color: Color(0xFF00714D)),
            ),
            const SizedBox(width: 8),
            const Text(
              'IKOBANA CARE',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFF004FA5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Kami siap membantu kamu',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF131B2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Solusi cepat untuk pesanan frozen food, pengiriman, dan kendala akun.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            height: 1.4,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ✅ PERBAIKAN: Tambahkan parameter BuildContext context
  Widget _buildFaqSection(BuildContext context) {
    final faqs = [
      {
        'question': 'Bagaimana cara melakukan pemesanan?',
        'answer': 'Pilih produk yang diinginkan, masukkan ke keranjang, lalu lanjutkan ke pembayaran.'
      },
      {
        'question': 'Metode pembayaran apa saja yang tersedia?',
        'answer': 'Kami menerima QRIS (semua e-wallet dan m-banking), Transfer Bank (BCA/Mandiri/BRI), serta pembayaran melalui GoPay, OVO, dan DANA.'
      },
      {
        'question': 'Bagaimana jika stok produk habis?',
        'answer': 'Anda dapat menggunakan fitur "Beri tahu saya" pada halaman produk untuk mendapatkan notifikasi ketika stok tersedia kembali.'
      },
      {
        'question': 'Bagaimana cara menghubungi layanan pelanggan?',
        'answer': 'Anda dapat menghubungi kami melalui tombol "Hubungi Kami" di bawah atau melalui WhatsApp resmi Ikobana.'
      },
      {
        'question': 'Bagaimana jika pembayaran gagal?',
        'answer': 'Silakan periksa koneksi internet, saldo, atau limit kartu Anda. Jika masih gagal, coba beberapa saat lagi atau gunakan metode pembayaran lain.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan Umum',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF131B2E),
          ),
        ),
        const SizedBox(height: 12),
        ...faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC2C6D5).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF131B2E),
                    ),
                  ),
                  iconColor: const Color(0xFF727784),
                  collapsedIconColor: const Color(0xFF727784),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq['answer']!,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          height: 1.5,
                          color: Color(0xFF414753),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildBottomSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC2C6D5).withValues(alpha: 0.3)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.support_agent, color: Color(0xFF004FA5), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masih Butuh Bantuan?',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131B2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hubungi tim kami untuk mendapatkan bantuan lebih lanjut.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEDFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified_user, size: 12, color: Color(0xFF006C49)),
                          SizedBox(width: 4),
                          Text(
                            'Setiap hari, 08.00–21.00 WIB',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF414753),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Aksi hubungi kami (misal buka WhatsApp)
              },
              icon: const Icon(Icons.headset_mic, size: 18),
              label: const Text(
                'Hubungi Kami',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004FA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}