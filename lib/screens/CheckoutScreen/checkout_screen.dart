// lib/screens/CheckoutScreen/checkout_screen.dart
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/logo_widget.dart';
import '../QrisPaymentScreen/qris_payment_screen.dart';
import '../KelolaAlamatScreen/kelola_alamat_screen.dart';
import '../../config/app_config.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int selectedShipping = 0;
  int selectedPayment = 0;
  bool _isLoading = false; 

  Future<void> _handleCheckout(CartProvider cart, int total) async {
    setState(() => _isLoading = true);
    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      final address = context.read<AddressProvider>().currentAddress;
      
      final items = cart.items.map((item) => {
        'productName': item.product.name,
        'qty': item.qty,
        'price': item.product.formattedPrice,
        'imageUrl': item.product.fullImageUrl,
      }).toList();

      final body = {
        'customerName': address.recipientName,
        'customerPhone': address.phoneNumber,
        'customerAddress': address.fullAddress,
        'items': items,
        'totalPrice': total, // ✅ Harga murni subtotal produk
        'paymentMethod': selectedPayment == 0 ? 'QRIS' : 'E-Wallet',
      };

      final res = await http.post(
        Uri.parse('${AppConfig.apiUrl}/transactions/checkout'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final json = jsonDecode(res.body);

      if (res.statusCode == 201 && json['success'] == true) {
        final orderId = json['data']['orderId'];
        cart.clear();
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QrisPaymentScreen(total: total, orderId: orderId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'] ?? 'Gagal membuat pesanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.totalPrice;
    // ✅ Ongkir dan biaya tambahan dinonaktifkan dulu
    const shipping = 0; 
    const biayaLayanan = 0;
    final total = subtotal + shipping + biayaLayanan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    _buildAddressCard(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('RINCIAN PRODUK (${cart.items.length})', trailing: 'Pesanan #IKO-8921'),
                          const SizedBox(height: 8),
                          _buildProductList(cart),
                          const SizedBox(height: 16),
                          // ✅ METODE PENGIRIMAN DINONAKTIFKAN DULU
                          // _buildSectionTitle('METODE PENGIRIMAN', trailing: 'Kirim dari Jl. Pahlawan'),
                          // const SizedBox(height: 8),
                          // _buildShippingOption(...),
                          _buildSectionTitle('METODE PEMBAYARAN DIGITAL', trailing: 'Aman & Otomatis'),
                          const SizedBox(height: 8),
                          _buildPaymentCard(),
                          const SizedBox(height: 16),
                          _buildSectionTitle('RINGKASAN BIAYA'),
                          const SizedBox(height: 8),
                          _buildSummaryCard(subtotal, shipping, total),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(total, cart),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 4),
          const LogoHorizontal(),
          const SizedBox(width: 12),
          const Text('Checkout Pembayaran', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final addr = context.watch<AddressProvider>().currentAddress;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFFD5E3FF), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(addr.recipientName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                      const SizedBox(width: 6),
                      Text('(${addr.phoneNumber})', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: Color(0xFF4E565D))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(addr.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, height: 1.4, color: Color(0xFF4E565D))),
                ],
              ),
            ),
            TextButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaAlamatScreen())); }, child: const Text('Ubah', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.textSecondary)),
          if (trailing != null) Text(trailing, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4E565D))),
        ],
      ),
    );
  }

  Widget _buildProductList(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]),
      child: Column(
        children: [
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.product.fullImageUrl.isNotEmpty
                            ? Image.network(item.product.fullImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: AppColors.textMuted, size: 24))
                            : const Icon(Icons.fastfood, color: AppColors.textMuted, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text('${item.qty}x @ ${item.product.formattedPrice}', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFF4E565D))),
                        ],
                      ),
                    ),
                    Text(cart.formatRupiah(item.subtotal), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.verified, color: AppColors.primary, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text('Dikemas dengan Therma-Freeze & Ice Gel Pack', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final payments = [
      {'title': 'QRIS (Semua E-Wallet & M-Banking)', 'sub': 'Proses Cepat Otomatis', 'icon': Icons.qr_code},
      {'title': 'GoPay', 'sub': 'Saldo Terhubung', 'icon': Icons.account_balance_wallet},
      {'title': 'OVO', 'sub': 'Instan OVO Push', 'icon': Icons.account_balance_wallet},
      {'title': 'DANA Dompet Digital', 'sub': 'Akun Siap', 'icon': Icons.account_balance_wallet},
      {'title': 'Transfer Bank (BCA / Mandiri / BRI)', 'sub': 'Virtual Account', 'icon': Icons.account_balance},
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]),
      child: Column(
        children: List.generate(payments.length, (i) {
          final isSelected = selectedPayment == i;
          final p = payments[i];
          return GestureDetector(
            onTap: () => setState(() => selectedPayment = i),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isSelected ? const Color(0xFFD5E3FF).withValues(alpha: 0.2) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFF767676), width: 1.5)),
                    child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))) : null,
                  ),
                  const SizedBox(width: 12),
                  Container(width: 36, height: 28, decoration: BoxDecoration(color: const Color(0xFFE6E8EA), borderRadius: BorderRadius.circular(4)), child: Icon(p['icon'] as IconData, color: AppColors.primary, size: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title'] as String, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(p['sub'] as String, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4E565D))),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(int subtotal, int shipping, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]),
      child: Column(
        children: [
          _summaryRow('Subtotal Produk', 'Rp ${_formatNumber(subtotal)}'),
          const SizedBox(height: 8),
          // ✅ Ongkir dan biaya lain dinonaktifkan dulu
          // _summaryRow('Ongkos Kirim', 'Rp ${_formatNumber(shipping)}'),
          const SizedBox(height: 8),
          _summaryRow('Diskon Promo', 'Rp 0'),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE0E3E5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Pembayaran', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('Sudah termasuk PPN & Packing Es', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4E565D))),
                ],
              ),
              Text('Rp ${_formatNumber(total)}', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBlue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: isBlue ? FontWeight.w700 : FontWeight.w600, color: isBlue ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildBottomBar(int total, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))]),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Text('Rp ${_formatNumber(total)}', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text('Metode: ${selectedPayment == 0 ? "QRIS Instan" : "Lainnya"}', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: cart.items.isEmpty || _isLoading ? null : () => _handleCheckout(cart, total),
              icon: _isLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.shield, size: 14),
              label: Text(_isLoading ? 'Memproses...' : 'Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}