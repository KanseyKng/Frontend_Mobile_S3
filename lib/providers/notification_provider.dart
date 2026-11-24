// lib/providers/notification_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/api_headers.dart';

class AppNotification {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  bool isRead;
  final String category;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isRead = false,
    required this.category,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Notifikasi';
    final category = json['category'] as String? ?? 'Sistem';

    IconData icon;
    Color iconColor;
    Color iconBgColor;

    if (category == 'Pesanan') {
      icon = Icons.shopping_bag_outlined;
      iconColor = const Color(0xFF0050CB);
      iconBgColor = const Color(0xFFDAE1FF);
    } else if (category == 'Pengiriman') {
      icon = Icons.local_shipping_outlined;
      iconColor = const Color(0xFF6B21A8);
      iconBgColor = const Color(0xFFE9D5FF);
    } else if (category == 'Stok Produk') {
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFC2410C);
      iconBgColor = const Color(0xFFFFF7ED);
    } else {
      icon = Icons.account_balance_wallet_outlined;
      iconColor = const Color(0xFF00682B);
      iconBgColor = const Color(0xFF7FFC97);
    }

    final createdAt = DateTime.parse(json['createdAt']).toLocal();
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    String timeStr = '';
    if (diff.inMinutes < 1) {
      timeStr = 'Baru saja';
    } else if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      timeStr = '${diff.inHours} jam lalu';
    } else {
      timeStr = '${diff.inDays} hari lalu';
    }

    return AppNotification(
      id: json['id'] as String,
      title: title,
      description: json['message'] as String? ?? '',
      time: timeStr,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      isRead: json['isRead'] as bool? ?? false,
      category: category,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final headers = await ApiHeaders.get();
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/notifications'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List list = data['data'] ?? [];
        _notifications.clear();
        _notifications.addAll(
          list.map((e) => AppNotification.fromJson(e)).toList(),
        );
      } else {
        debugPrint('Gagal mengambil notifikasi: ${data['message']}');
      }
    } catch (e) {
      debugPrint('Error fetch notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    for (var notif in _notifications) {
      if (!notif.isRead) {
        notif.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      try {
        final headers = await ApiHeaders.get();
        await http.put(
          Uri.parse('${AppConfig.apiUrl}/notifications/read-all'),
          headers: headers,
        );
      } catch (e) {
        debugPrint('Error mark all as read: $e');
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();

      try {
        final headers = await ApiHeaders.get();
        await http.put(
          Uri.parse('${AppConfig.apiUrl}/notifications/$id/read'),
          headers: headers,
        );
      } catch (e) {
        debugPrint('Error mark as read: $e');
      }
    }
  }

  void clear() {
    _notifications.clear();
    _isLoading = false;
    notifyListeners();
  }
}