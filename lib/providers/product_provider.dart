// lib/providers/product_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../config/app_config.dart';
import '../utils/api_headers.dart'; // ✅ Import helper header

class ProductProvider extends ChangeNotifier {
  String get _baseUrl => AppConfig.apiUrl;

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ PERBAIKAN: Gunakan ApiHeaders untuk mengirim ngrok-skip-browser-warning
      final headers = await ApiHeaders.get(withAuth: false);
      
      final url = Uri.parse('$_baseUrl/products');
      debugPrint('=== MEMANGGIL API: $url ===');

      final res = await http.get(url, headers: headers);
      final json = jsonDecode(res.body);

      if (res.statusCode == 200 && json['success'] == true) {
        final List data = json['data'] ?? [];
        _products = data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        _error = json['message'] ?? 'Gagal memuat produk dari server.';
      }
    } catch (e) {
      _error = 'Tidak dapat terhubung ke server.\nPastikan backend menyala dan URL $_baseUrl benar.';
      debugPrint('=== ERROR FETCH: $e ===');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}