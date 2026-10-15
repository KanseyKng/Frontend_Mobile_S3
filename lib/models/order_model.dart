// lib/models/order_model.dart
class OrderItem {
  final String productName;
  final int qty;
  final String price;
  final String imageUrl;

  const OrderItem({
    required this.productName,
    required this.qty,
    required this.price,
    this.imageUrl = '',
  });
}

class OrderModel {
  final String orderId;
  final String date;
  final String status; // 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
  final List<OrderItem> items;
  final String totalPrice;
  final int totalItems;

  const OrderModel({
    required this.orderId,
    required this.date,
    required this.status,
    required this.items,
    required this.totalPrice,
    required this.totalItems,
  });
}