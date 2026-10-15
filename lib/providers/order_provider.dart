// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  // Data dummy untuk demo — nantinya bisa dari API
  final List<OrderModel> _orders = const [
    OrderModel(
      orderId: '#TRX-001',
      date: '18 Sep 2026 • 14:30 WIB',
      status: 'Diproses',
      totalPrice: 'Rp 113.000',
      totalItems: 3,
      items: [
        OrderItem(
          productName: 'Nugget Ayam Crispy (x2), Sosis Premium (x1)',
          qty: 3,
          price: 'Rp 113.000',
        ),
      ],
    ),
    OrderModel(
      orderId: '#TRX-000',
      date: '10 Sep 2026',
      status: 'Selesai',
      totalPrice: 'Rp 32.000',
      totalItems: 1,
      items: [
        OrderItem(
          productName: 'Dimsum Siomay Ayam (x1)',
          qty: 1,
          price: 'Rp 32.000',
        ),
      ],
    ),
  ];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<OrderModel> getOrdersByStatus(String status) {
    if (status == 'Semua') return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  int getOrderCountByStatus(String status) {
    if (status == 'Semua') return _orders.length;
    return _orders.where((o) => o.status == status).length;
  }
}