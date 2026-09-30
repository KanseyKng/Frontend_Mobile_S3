// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  int get subtotal {
    final int priceNum = int.parse(
      product.price.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    return priceNum * qty;
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.qty);

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  bool isInCart(String productId) =>
      _items.any((i) => i.product.id == productId);

  int qtyOf(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    return idx == -1 ? 0 : _items[idx].qty;
  }

  void addToCart(ProductModel product, {int qty = 1}) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx == -1) {
      _items.add(CartItem(product: product, qty: qty));
    } else {
      _items[idx].qty += qty;
    }
    notifyListeners();
  }

  void increment(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx != -1) {
      _items[idx].qty++;
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx != -1) {
      if (_items[idx].qty > 1) {
        _items[idx].qty--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  String formatRupiah(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return 'Rp $buf';
  }
}