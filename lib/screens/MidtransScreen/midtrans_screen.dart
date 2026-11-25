// lib/screens/MidtransScreen/midtrans_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../HomeScreen/home_screen.dart'; 

class MidtransScreen extends StatefulWidget {
  final String snapToken;
  final String orderId;

  const MidtransScreen({
    super.key,
    required this.snapToken,
    required this.orderId,
  });

  @override
  State<MidtransScreen> createState() => _MidtransScreenState();
}

class _MidtransScreenState extends State<MidtransScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isSuccessHandled = false;
  bool _isWaitingWebhook = false;
  String _statusMessage = 'Memeriksa status pembayaran...';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);

            final isFinishUrl = url.contains('finish') ||
                url.contains('success') ||
                url.contains('status_code=200') ||
                url.contains('/transactions/finish');

            if (!_isSuccessHandled && isFinishUrl) {
              _handlePaymentSuccess();
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}',
        ),
      );
  }

  Future<void> _handlePaymentSuccess() async {
    if (_isSuccessHandled) return;
    _isSuccessHandled = true;

    setState(() {
      _isWaitingWebhook = true;
      _statusMessage = 'Memeriksa status pembayaran...';
    });

    final orderProvider = context.read<OrderProvider>();
    final notifProvider = context.read<NotificationProvider>();

    String? finalStatus;
    // Diperpanjang menjadi 20 detik untuk mengantisipasi Railway Serverless "bangun"
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      
      final status = await orderProvider.pollStatus(widget.orderId);
      if (!mounted) return;

      if (status == 'Diproses') {
        finalStatus = 'Diproses';
        break;
      } else if (status == 'Dibatalkan') {
        finalStatus = 'Dibatalkan';
        break;
      }
      if (mounted) {
        setState(() {
          _statusMessage = 'Menunggu konfirmasi server... (${i + 1}s)';
        });
      }
    }

    if (!mounted) return;

    try {
      await orderProvider.refreshSilently();
      await notifProvider.fetchNotifications();
    } catch (e) {
      debugPrint('Error refresh setelah pembayaran: $e');
    }

    if (!mounted) return;

    setState(() => _isWaitingWebhook = false);

    final isSuccess = finalStatus == 'Diproses';
    final isCancelled = finalStatus == 'Dibatalkan';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isSuccess
              ? 'Pembayaran Berhasil'
              : isCancelled
                  ? 'Pembayaran Dibatalkan'
                  : 'Pembayaran Sedang Diproses',
        ),
        content: Text(
          isSuccess
              ? 'Terima kasih! Pesanan kamu sedang diproses.'
              : isCancelled
                  ? 'Pembayaran dibatalkan atau kedaluwarsa.'
                  : 'Pembayaran kamu sedang diverifikasi oleh sistem. '
                      'Silakan cek halaman pesanan beberapa saat lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk menampilkan dialog konfirmasi keluar
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
            'Pesanan kamu akan tetap tersimpan dengan status Menunggu Pembayaran.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan Bayar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Mencegah aplikasi langsung tertutup saat tombol back ditekan
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Jika pengguna menekan tombol back fisik, tampilkan konfirmasi
        _showExitConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitConfirmation,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading && !_isWaitingWebhook)
              const Center(child: CircularProgressIndicator()),
            if (_isWaitingWebhook)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}