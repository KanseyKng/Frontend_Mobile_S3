// lib/providers/wishlist_provider.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);
  int get totalItems => _items.length;

  bool isInWishlist(String productId) =>
      _items.any((p) => p.id == productId);

  void addToWishlist(ProductModel product) {
    if (!isInWishlist(product.id)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}