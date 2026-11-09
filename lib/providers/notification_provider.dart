// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';

class AppNotification {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  bool isRead;

  AppNotification({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  // Data Awal (Dummy) agar tidak kosong saat pertama dibuka
  NotificationProvider() {
    _notifications.addAll([
      AppNotification(
        title: 'Pesanan Berhasil Dibuat',
        description: 'Pesanan #LM001 berhasil dibuat. Segera selesaikan pembayaran untuk mengamankan…',
        time: '5 menit lalu',
        icon: Icons.shopping_bag_outlined,
        iconColor: const Color(0xFF0050CB),
        iconBgColor: const Color(0xFFDAE1FF),
      ),
      AppNotification(
        title: 'Pembayaran Berhasil',
        description: 'Pembayaran pesanan #LM001 via QRIS telah terverifikasi. Tim sedang menyiapkan boks…',
        time: '15 menit lalu',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF00682B),
        iconBgColor: const Color(0xFF7FFC97),
      ),
    ]);
  }

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Fungsi untuk memicu notifikasi baru
  void addNotification({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        title: title,
        description: description,
        time: 'Baru saja',
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        isRead: false,
      ),
    );
    notifyListeners();
  }

  // Fungsi untuk menandai semua sudah dibaca (angka & titik biru hilang)
  void markAllAsRead() {
    bool changed = false;
    for (var notif in _notifications) {
      if (!notif.isRead) {
        notif.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}