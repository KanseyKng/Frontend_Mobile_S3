// lib/widgets/pricing_card.dart
import 'package:flutter/material.dart';

class PricingCard extends StatelessWidget {
  final String name;
  final String price;
  final VoidCallback onTap;

  const PricingCard({
    super.key,
    required this.name,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.fastfood, color: Colors.green),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(price),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap, // Event & State: Aksi klik
      ),
    );
  }
}