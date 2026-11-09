// lib/screens/NotificationScreen/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Tandai terbaca setelah 2 detik agar user sempat melihat titik biru
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<NotificationProvider>().markAllAsRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1B1B)),
          onPressed: () {
            // ✅ Saat back ditekan, pastikan semua sudah dibaca
            context.read<NotificationProvider>().markAllAsRead();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1B),
              ),
            ),
            if (notifProvider.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${notifProvider.unreadCount}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Belum ada notifikasi'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notif.isRead
            ? Colors.white
            : const Color(0xFFDAE1FF).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notif.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(notif.icon, color: notif.iconColor, size: 20),
              ),
              // ✅ Titik biru HANYA muncul jika belum dibaca
              if (!notif.isRead)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0050CB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF424656),
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ Teks aksi & panah sudah dihapus
                Text(
                  notif.time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF727687),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}