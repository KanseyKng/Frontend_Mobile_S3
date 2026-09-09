// lib/main.dart
import 'package:flutter/material.dart';

// Import widget kartu dari folder widgets
import 'widgets/pricing_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiered Pricing Card',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(
          child: TieredPricingCard(), // <-- menampilkan kartu
        ),
      ),
    );
  }
}