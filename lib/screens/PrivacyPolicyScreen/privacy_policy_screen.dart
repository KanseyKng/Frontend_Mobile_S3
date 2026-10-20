// lib/screens/PrivacyPolicyScreen/privacy_policy_screen.dart
import 'package:flutter/material.dart';
// ✅ PERBAIKAN: Baris import app_theme.dart sudah dihapus karena tidak dipakai

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF).withValues(alpha: 0.85),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131B2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: Color(0xFF131B2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildPasal1(),
            const SizedBox(height: 14),
            _buildPasal2(),
            const SizedBox(height: 14),
            _buildPasal3(),
            const SizedBox(height: 14),
            _buildPasal4(),
            const SizedBox(height: 14),
            _buildPasal5(),
            const SizedBox(height: 14),
            _buildPasal6(),
            const SizedBox(height: 26),
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                color: const Color(0xFFD7E2FF).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified_user, size: 10, color: Color(0xFF001B3F)),
                    SizedBox(width: 4),
                    Text(
                      'Dokumen Resmi LocalMart',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF001B3F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF131B2E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'LocalMart — Ikobana Frozen Food',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF004FA5),
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Komitmen UU Pelindungan Data Pribadi (UU PDP)',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131B2E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kami berkomitmen penuh memproses dan melindungi data pribadi Anda sesuai Undang-Undang No. 27 Tahun 2022 (UU PDP) dengan transparansi, akuntabilitas, dan standar keamanan tertinggi.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFF414753),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasal1() {
    return _buildArticleCard(
      title: '1. Pendahuluan',
      children: [
        const Text(
          'LocalMart adalah aplikasi yang membantu pelanggan melihat produk frozen food, melakukan pemesanan, melakukan pembayaran, dan memantau status pengiriman. Kebijakan Privasi ini menjelaskan bagaimana informasi pelanggan dikumpulkan, digunakan, disimpan, dan dilindungi ketika menggunakan layanan LocalMart.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF131B2E)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dengan menggunakan aplikasi LocalMart, pelanggan diharapkan membaca dan memahami kebijakan ini.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
      ],
    );
  }

  Widget _buildPasal2() {
    return _buildArticleCard(
      title: '2. Informasi yang Kami Kumpulkan',
      children: [
        const Text(
          'Untuk mendukung layanan, LocalMart dapat memproses informasi berikut sesuai kebutuhan:',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
        const SizedBox(height: 8),
        _buildListItem(Icons.person_outline, 'Informasi akun: nama lengkap, alamat email, dan nomor telepon.'),
        _buildListItem(Icons.location_on_outlined, 'Informasi pengiriman: alamat penerima dan detail yang diperlukan untuk mengantarkan pesanan.'),
        _buildListItem(Icons.receipt_long_outlined, 'Informasi transaksi: nomor pesanan, produk yang dibeli, jumlah pembayaran, metode pembayaran, serta status transaksi.'),
        _buildListItem(Icons.chat_bubble_outline, 'Informasi komunikasi: pesan atau informasi yang diberikan ketika pelanggan menghubungi layanan bantuan.'),
        _buildListItem(Icons.phone_android, 'Informasi penggunaan aplikasi: informasi teknis yang diperlukan untuk menjaga fungsi, keamanan, dan kinerja aplikasi.'),
        const SizedBox(height: 8),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF004FA5)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'LocalMart tidak meminta informasi yang tidak diperlukan untuk tujuan layanan tanpa alasan yang jelas.',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF004FA5)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasal3() {
    return _buildArticleCard(
      title: '3. Tujuan Penggunaan Informasi',
      children: [
        const Text(
          'Informasi pelanggan dapat digunakan untuk:',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
        const SizedBox(height: 8),
        _buildBulletItem('Membuat dan mengelola akun pelanggan.'),
        _buildBulletItem('Memproses pesanan dan pembayaran.'),
        _buildBulletItem('Mengatur pengiriman dan memberikan pembaruan status pesanan.'),
        _buildBulletItem('Menangani pertanyaan, keluhan, dan permintaan bantuan.'),
        _buildBulletItem('Menjaga keamanan akun dan mencegah penyalahgunaan layanan.'),
        _buildBulletItem('Memperbaiki kualitas aplikasi dan pengalaman berbelanja.'),
        _buildBulletItem('Memenuhi kewajiban hukum yang berlaku.'),
      ],
    );
  }

  Widget _buildPasal4() {
    return _buildArticleCard(
      title: '4. Penggunaan dan Pembagian Informasi',
      children: [
        const Text(
          'Informasi pelanggan hanya boleh digunakan untuk tujuan yang sah dan sesuai dengan kebutuhan layanan.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF131B2E)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Jika diperlukan, informasi yang relevan dapat dibagikan kepada penyedia layanan pembayaran, jasa pengiriman, penyedia infrastruktur teknologi, atau pihak lain yang membantu operasional LocalMart.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD7E2FF).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security, size: 16, color: Color(0xFF004FA5)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Informasi hanya dibagikan sejauh diperlukan untuk tujuan tersebut, dengan memperhatikan perlindungan data dan kewajiban hukum yang berlaku. Informasi pelanggan tidak boleh diperjualbelikan untuk tujuan yang tidak sah.',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF001B3F)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasal5() {
    return _buildArticleCard(
      title: '5. Keamanan Informasi',
      children: [
        const Text(
          'LocalMart berupaya menerapkan langkah-langkah keamanan yang sesuai untuk melindungi informasi pelanggan dari akses, perubahan, pengungkapan, kehilangan, atau penggunaan tanpa izin.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF131B2E)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pelanggan juga bertanggung jawab menjaga kerahasiaan kata sandi dan tidak membagikan kode verifikasi kepada orang lain.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Meskipun langkah keamanan diterapkan, tidak ada sistem elektronik yang dapat dijamin sepenuhnya bebas dari risiko.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
      ],
    );
  }

  Widget _buildPasal6() {
    return _buildArticleCard(
      title: '6. Hak Pelanggan',
      children: [
        const Text(
          'Sesuai ketentuan hukum yang berlaku, pelanggan dapat mengajukan permintaan untuk:',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
        ),
        const SizedBox(height: 8),
        _buildCheckItem('Mendapatkan informasi mengenai pemrosesan data pribadinya.'),
        _buildCheckItem('Mengakses dan memperbaiki informasi yang tidak akurat.'),
        _buildCheckItem('Meminta penghapusan atau penghentian pemrosesan data dalam kondisi yang diperbolehkan.'),
        _buildCheckItem('Menarik persetujuan apabila pemrosesan didasarkan pada persetujuan.'),
        _buildCheckItem('Mengajukan pertanyaan atau keluhan terkait privasi.'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAEDFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Permintaan dapat disampaikan melalui layanan pelanggan LocalMart. Permintaan akan ditinjau dan diproses sesuai ketentuan yang berlaku.',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.6, color: Color(0xFF414753)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7FF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Dokumen ini merupakan draf awal untuk kebutuhan desain dan pengembangan aplikasi. Isi final perlu disesuaikan dengan praktik pemrosesan data yang sebenarnya dan ditinjau sebelum dipublikasikan kepada pelanggan.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, height: 1.6, color: Color(0xFF414753)),
      ),
    );
  }

  // Helper Widgets
  Widget _buildArticleCard({required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF131B2E)),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF004FA5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, height: 1.4, color: Color(0xFF131B2E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: Color(0xFF004FA5), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.4, color: Color(0xFF131B2E))),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 14, color: Color(0xFF004FA5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, height: 1.4, color: Color(0xFF131B2E))),
          ),
        ],
      ),
    );
  }
}