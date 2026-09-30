// lib/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final String price;
  final double rating;
  final int reviewCount;
  final int stock;
  final String badgeLabel;
  final String category;

  // ✅ Constructor dibuat const agar bisa dipakai di list const
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.badgeLabel,
    required this.category,
  });
}