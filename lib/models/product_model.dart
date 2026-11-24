// lib/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final int price;
  final double rating;
  final int reviewCount;
  final int stock;
  final String badgeLabel;
  final String category;
  final String description;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.badgeLabel,
    required this.category,
    this.description = '',
    this.imageUrl = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num).toInt(),
      badgeLabel: json['sku'] != null ? 'Frozen' : '',
      category: json['category'] as String,
      description: json['description'] as String? ?? 'Belum ada deskripsi.',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  /// ✅ URL gambar sudah absolut dari Cloudinary
  String get fullImageUrl => imageUrl;

  String get formattedPrice {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return 'Rp $buf';
  }
}