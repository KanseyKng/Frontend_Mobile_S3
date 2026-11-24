// lib/providers/wishlist_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product_model.dart';
import '../utils/api_headers.dart';

class WishlistProvider extends ChangeNotifier {
  List<ProductModel> _items = [];

  bool _isLoading = false;
  bool _isInitialized = false;

  String? _errorMessage;

  final Set<String> _processingIds = {};

  // ===============================
  // GETTERS
  // ===============================

  List<ProductModel> get items => List.unmodifiable(_items);

  int get totalItems => _items.length;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  bool isProcessing(String productId) {
    return _processingIds.contains(productId);
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id.toString() == productId);
  }

  // ===============================
  // RESPONSE HANDLER
  // ===============================

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Format response API tidak valid.');
    } on FormatException {
      throw Exception('Response server bukan JSON yang valid.');
    }
  }

  bool _isSuccess(Map<String, dynamic> data) => data['success'] == true;

  String _getMessage(
    Map<String, dynamic> data, {
    String fallback = 'Terjadi kesalahan pada server.',
  }) {
    return data['message']?.toString() ?? fallback;
  }

  // ===============================
  // FETCH WISHLIST
  // ===============================

  Future<void> fetchWishlist({bool force = false}) async {
    if (_isLoading) return;
    if (_isInitialized && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await ApiHeaders.get();
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/wishlists'),
        headers: headers,
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && _isSuccess(data)) {
        final rawData = data['data'];
        List<dynamic> productsData = [];

        if (rawData is List) {
          productsData = rawData;
        } else if (rawData is Map<String, dynamic>) {
          if (rawData['products'] is List) {
            productsData = rawData['products'];
          } else if (rawData['items'] is List) {
            productsData = rawData['items'];
          }
        }

        final fetchedItems = productsData
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();

        _items = _removeDuplicates(fetchedItems);
        _isInitialized = true;
        _errorMessage = null;
      } else {
        throw Exception(
          _getMessage(data, fallback: 'Gagal mengambil data Wishlist.'),
        );
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Fetch Wishlist Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // ADD WISHLIST
  // ===============================

  Future<bool> addToWishlist(ProductModel product) async {
    final productId = product.id.toString();
    if (isInWishlist(productId)) return true;
    if (_processingIds.contains(productId)) return false;

    _processingIds.add(productId);
    _items = [..._items, product];
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await ApiHeaders.get();
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/wishlists'),
        headers: headers,
        body: jsonEncode({'productId': productId}),
      );

      final data = _decodeResponse(response);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          _isSuccess(data)) {
        return true;
      }

      throw Exception(
        _getMessage(data, fallback: 'Gagal menambahkan produk ke Wishlist.'),
      );
    } catch (e) {
      _items.removeWhere((item) => item.id.toString() == productId);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Add Wishlist Error: $e');
      notifyListeners();
      return false;
    } finally {
      _processingIds.remove(productId);
      notifyListeners();
    }
  }

  // ===============================
  // REMOVE WISHLIST
  // ===============================

  Future<bool> removeFromWishlist(String productId) async {
    final existingIndex =
        _items.indexWhere((item) => item.id.toString() == productId);
    if (existingIndex == -1) return true;
    if (_processingIds.contains(productId)) return false;

    _processingIds.add(productId);
    final removedProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await ApiHeaders.get();
      final response = await http.delete(
        Uri.parse('${AppConfig.apiUrl}/wishlists/$productId'),
        headers: headers,
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && _isSuccess(data)) {
        return true;
      }

      throw Exception(
        _getMessage(data, fallback: 'Gagal menghapus produk dari Wishlist.'),
      );
    } catch (e) {
      if (!isInWishlist(productId)) {
        _items.insert(existingIndex.clamp(0, _items.length), removedProduct);
      }
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Remove Wishlist Error: $e');
      notifyListeners();
      return false;
    } finally {
      _processingIds.remove(productId);
      notifyListeners();
    }
  }

  // ===============================
  // TOGGLE WISHLIST
  // ===============================

  Future<bool> toggleWishlist(ProductModel product) async {
    final productId = product.id.toString();
    if (_processingIds.contains(productId)) return false;
    if (isInWishlist(productId)) return removeFromWishlist(productId);
    return addToWishlist(product);
  }

  // ===============================
  // CLEAR LOCAL WISHLIST
  // ===============================

  void clearWishlist() {
    _items.clear();
    _processingIds.clear();
    _isInitialized = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void resetWishlist() => clearWishlist();

  // ===============================
  // REMOVE DUPLICATES
  // ===============================

  List<ProductModel> _removeDuplicates(List<ProductModel> products) {
    final uniqueProducts = <String, ProductModel>{};
    for (final product in products) {
      uniqueProducts[product.id.toString()] = product;
    }
    return uniqueProducts.values.toList();
  }
}