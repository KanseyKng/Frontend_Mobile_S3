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
    final name = json['productName'] as String? ?? 
                 json['name'] as String? ?? 
                 'Produk';

    final img = json['imageUrl'] as String? ?? 
                json['image'] as String? ?? '';

    return OrderItem(
      productName: name,
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      price: json['price']?.toString() ?? 'Rp 0',
      imageUrl: img,
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
      if (rawItems is String) {
        try {
          final decoded = jsonDecode(rawItems);
          if (decoded is List) {
            itemsList = decoded.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
          }
        } catch (e) {
          print('Gagal decode items: $e');
        }
      } else if (rawItems is List) {
        itemsList = rawItems.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']).toLocal().toString().split(' ')[0]
          : '-',
      status: json['status']?.toString() ?? 'Menunggu',
      totalPrice: 'Rp ${(json['totalPrice'] as num?)?.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.") ?? '0'}',
      totalItems: itemsList.fold(0, (sum, item) => sum + item.qty),
      items: itemsList,
      paymentProof: json['paymentProof']?.toString(),
    );
  }

  String getFirstImageUrl() {
    if (items.isEmpty) return '';
    final rawUrl = items.first.imageUrl.trim();
    if (rawUrl.isEmpty) return '';

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    
    final baseUrl = AppConfig.baseUrl;
    if (rawUrl.startsWith('/')) {
      return '$baseUrl$rawUrl';
    } else {
      return '$baseUrl/$rawUrl';
    }
  }
}