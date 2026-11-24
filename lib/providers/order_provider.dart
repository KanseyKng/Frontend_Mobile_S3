// lib/providers/order_provider.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/order_model.dart';
import '../config/app_config.dart';
import '../utils/api_headers.dart';

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
      final headers = await ApiHeaders.get();
      final res = await http.get(
        Uri.parse('$_baseUrl/transactions'),
        headers: headers,
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

  Future<void> refreshSilently() async {
    try {
      final headers = await ApiHeaders.get();
      final res = await http.get(
        Uri.parse('$_baseUrl/transactions'),
        headers: headers,
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['success'] == true) {
        final List data = json['data'] ?? [];
        _orders = data.map((e) => OrderModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshSilently: $e');
    }
  }

  Future<String?> pollStatus(String orderId) async {
    try {
      final headers = await ApiHeaders.get();
      final res = await http.get(
        Uri.parse('$_baseUrl/transactions/status/$orderId'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return json['data']['status'] as String?;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error pollStatus: $e');
      return null;
    }
  }

  // ✅ PERBAIKAN: Panggil endpoint /complete
  Future<bool> markAsCompleted(String transactionId) async {
    try {
      final headers = await ApiHeaders.get();
      final res = await http.put(
        Uri.parse('$_baseUrl/transactions/$transactionId/complete'),
        headers: headers,
      );

      if (res.statusCode == 200) {
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
    if (status == 'Menunggu Verifikasi') {
      return _orders
          .where((o) =>
              o.status == 'Menunggu Verifikasi' ||
              o.status == 'Menunggu Pembayaran')
          .toList();
    }
    return _orders.where((o) => o.status == status).toList();
  }

  int getOrderCountByStatus(String status) {
    if (status == 'Semua') return _orders.length;
    if (status == 'Menunggu Verifikasi') {
      return _orders
          .where((o) =>
              o.status == 'Menunggu Verifikasi' ||
              o.status == 'Menunggu Pembayaran')
          .length;
    }
    return _orders.where((o) => o.status == status).length;
  }

  void clear() {
    _orders.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}