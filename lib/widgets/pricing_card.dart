// lib/widgets/pricing_card.dart
import 'package:flutter/material.dart';

/// Kartu harga layanan IT dengan tiered pricing.
/// Semua elemen sesuai gambar: Container dengan shadow, Stack dengan badge,
/// Column untuk header, Row untuk harga (baseline), daftar fitur, dan tombol CTA.
class TieredPricingCard extends StatelessWidget {
  const TieredPricingCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Data statis contoh (nanti bisa diganti dari model)
    const String packageName = 'Paket Profesional';
    const String description = 'Layanan IT terbaik untuk bisnis Anda';
    const String price = 'Rp 5.000.000';
    const String duration = '/proyek';
    const List<String> features = [
      'Desain UI/UX Khusus',
      'Setup Database',
      'Dukungan 24/7',
      'Deployment Cloud',
    ];

    // Container utama: lebar 300, putih, border-radius, shadow
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      // Stack untuk menempatkan badge melayang di sudut kanan atas
      child: Stack(
        clipBehavior: Clip.none, // agar badge bisa keluar dari batas container
        children: [
          // --- Isi utama kartu (lapisan bawah) ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Icon, Nama Paket, Deskripsi
                const Icon(Icons.computer, size: 48, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  packageName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                // 2. Harga & Durasi (Row dengan baseline alignment)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Daftar fitur (Column berisi Row untuk setiap fitur)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Text(feature, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 4. Tombol CTA (lebar penuh)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Contoh aksi: tampilkan SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Paket dipilih!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Pilih Paket'),
                  ),
                ),
              ],
            ),
          ),

          // --- Badge melayang (lapisan atas) menggunakan Positioned ---
          const Positioned(
            top: -10,
            right: -10,
            child: Badge(
              label: Text('Rekomendasi'), // <-- PERBAIKAN: label harus Widget
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}