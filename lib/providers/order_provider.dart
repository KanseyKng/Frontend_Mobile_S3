// lib/providers/order_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/order_model.dart';
import '../config/app_config.dart';

class OrderProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String get _baseUrl => AppConfig.apiUrl;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final res = await http.get(
        Uri.parse('$_baseUrl/transactions'),
        headers: { if (token != null) 'Authorization': 'Bearer $token' },
      );

      final json = jsonDecode(res.body);

      if (res.statusCode == 200 && json['success'] == true) {
        final List data = json['data'] ?? [];
        _orders = data.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        _error = json['message'] ?? 'Gagal memuat pesanan';
      }
    } catch (e) {
      _error = 'Tidak dapat terhubung ke server.';
      debugPrint('Error Fetch Orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ FUNGSI BARU: Untuk Customer menandai pesanan "Selesai"
  Future<bool> markAsCompleted(String transactionId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final res = await http.put(
        Uri.parse('$_baseUrl/transactions/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': 'Selesai'}),
      );

      if (res.statusCode == 200) {
        // Update state lokal agar UI langsung berubah
        final index = _orders.indexWhere((o) => o.id == transactionId);
        if (index != -1) {
          final oldOrder = _orders[index];
          _orders[index] = OrderModel(
            id: oldOrder.id,
            orderId: oldOrder.orderId,
            date: oldOrder.date,
            status: 'Selesai',
            totalPrice: oldOrder.totalPrice,
            totalItems: oldOrder.totalItems,
            items: oldOrder.items,
            paymentProof: oldOrder.paymentProof,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error Mark Completed: $e');
      return false;
    }
  }

  void addOrderLocal(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  List<OrderModel> getOrdersByStatus(String status) {
    if (status == 'Semua') return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  int getOrderCountByStatus(String status) {
    if (status == 'Semua') return _orders.length;
    return _orders.where((o) => o.status == status).length;
  }
}