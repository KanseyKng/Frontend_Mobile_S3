// lib/models/order_model.dart
import 'dart:convert';
import '../config/app_config.dart';

class OrderItem {
  final String productName;
  final int qty;
  final String price;
  final String imageUrl;

  OrderItem({
    required this.productName,
    required this.qty,
    required this.price,
    this.imageUrl = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['productName'] as String? ?? 'Produk',
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      price: json['price'] as String? ?? 'Rp 0',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String orderId;
  final String date;
  final String status;
  final String totalPrice;
  final int totalItems;
  final List<OrderItem> items;
  final String? paymentProof;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.totalItems,
    required this.items,
    this.paymentProof,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItem>[];
    if (json['items'] != null) {
      final rawItems = json['items'];
      // ✅ Jika dari backend berupa String JSON, decode dulu
      if (rawItems is String) {
        try {
          final decoded = jsonDecode(rawItems);
          if (decoded is List) {
            itemsList = decoded.map((e) => OrderItem.fromJson(e)).toList();
          }
        } catch (_) {
          // Abaikan jika gagal parse
        }
      } 
      // ✅ Jika sudah berupa List (misalnya dari cache), langsung map
      else if (rawItems is List) {
        itemsList = rawItems.map((e) => OrderItem.fromJson(e)).toList();
      }
    }

    return OrderModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      date: DateTime.parse(json['createdAt']).toLocal().toString().split(' ')[0],
      status: json['status'] as String,
      totalPrice: 'Rp ${(json['totalPrice'] as num).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}',
      totalItems: itemsList.fold(0, (sum, item) => sum + item.qty),
      items: itemsList,
      paymentProof: json['paymentProof'] as String?,
    );
  }

  // ✅ Helper untuk mendapatkan URL gambar pertama
  String getFirstImageUrl() {
    if (items.isEmpty) return '';
    final url = items.first.imageUrl;
    if (url.isEmpty) return '';
    
    // Ubah URL localhost menjadi IP dari AppConfig
    return url
        .replaceAll('http://localhost:5000', AppConfig.baseUrl)
        .replaceAll('http://192.168.1.129:5000', AppConfig.baseUrl)
        .replaceAll('http://10.200.118.253:5000', AppConfig.baseUrl);
  }
}