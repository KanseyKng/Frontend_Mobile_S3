// lib/widgets/pricing_card.dart
import 'package:flutter/material.dart';

// Kartu produk yang bisa diklik (dipakai di Screen 1 - ListView)
class PricingCard extends StatelessWidget {
  final String nama;
  final String harga;
  final String kategori;
  final bool isPromo;
  final VoidCallback onTap;

  const PricingCard({
    super.key,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.onTap,
    this.isPromo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      // ListTile = item yang bisa diklik (SESUAI REQUIREMENT)
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9), // pastel hijau
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.ac_unit,
            color: Colors.green,
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (isPromo)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2), // pastel merah
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PROMO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kategori,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                harga,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap, // <-- onTap untuk Navigator.push
      ),
    );
  }
}