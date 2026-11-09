// lib/screens/OrderListScreen/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/common/logo_widget.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../ChatScreen/chat_screen.dart';
import '../ProductListScreen/product_list_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  int selectedFilter = 0;

  final List<String> filters = const [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final filteredOrders = orderProvider.getOrdersByStatus(filters[selectedFilter]);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => context.read<OrderProvider>().fetchOrders(),
                      child: filteredOrders.isEmpty
                          ? _buildEmptyStateWithTabs(orderProvider)
                          : _buildOrderList(orderProvider, filteredOrders),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNavBar(activeIndex: 3),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithTabs(OrderProvider orderProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pantau pesanan frozen food Anda',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFilterTabs(orderProvider),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(child: _buildEmptyState()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textMuted),
        SizedBox(height: 16),
        Text(
          'Belum ada pesanan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList(OrderProvider orderProvider, List<OrderModel> orders) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pantau pesanan frozen food Anda',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildFilterTabs(orderProvider),
          const SizedBox(height: 16),
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOrderCard(order),
            ),
          ),
        ],
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const LogoHorizontal(),
          const SizedBox(width: 12),
          const Text(
            'Status Pesanan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(OrderProvider orderProvider) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = selectedFilter == i;
          final count = orderProvider.getOrderCountByStatus(filters[i]);
          final showBadge = (filters[i] == 'Menunggu Verifikasi' || filters[i] == 'Diproses') && count > 0;

          return GestureDetector(
            onTap: () => setState(() => selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2563EB) : AppColors.inputBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Text(
                    filters[i],
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  if (showBadge) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isDiproses = order.status == 'Diproses';
    final isMenunggu = order.status == 'Menunggu Verifikasi';
    final isActive = isDiproses || isMenunggu;
    final isDikirim = order.status == 'Dikirim';

    Color getBadgeColor() {
      if (isMenunggu) return const Color(0xFFFFF7ED);
      if (isDiproses) return const Color(0xFFD5E3FF);
      if (isDikirim) return const Color(0xFFE9D5FF);
      return const Color(0xFFF3F4F6);
    }

    Color getBadgeTextColor() {
      if (isMenunggu) return const Color(0xFFC2410C);
      if (isDiproses) return const Color(0xFF004AC6);
      if (isDikirim) return const Color(0xFF6B21A8);
      return const Color(0xFF434655);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, size: 16, color: isActive ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'IKOBANA FROZENFOOD Mojokerto',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                order.orderId,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Text('•', style: TextStyle(color: Color(0xFFC3C6D7), fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                order.date,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: getBadgeColor(), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: getBadgeTextColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: order.getFirstImageUrl().isNotEmpty
                        ? Image.network(
                            order.getFirstImageUrl(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: AppColors.textMuted, size: 28),
                          )
                        : const Icon(Icons.fastfood, color: AppColors.textMuted, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ DAFTAR PRODUK YANG DIPESAN
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${item.qty}x ${item.productName}',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )),
                      const SizedBox(height: 4),
                      if (isDiproses) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD5E3FF), borderRadius: BorderRadius.circular(6)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.ac_unit, size: 11, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Rantai Dingin Terjaga',
                                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2D486D)),
                              ),
                            ],
                          ),
                        ),
                      ] else if (isMenunggu) ...[
                        const Text(
                          'Menunggu verifikasi bukti transfer oleh admin.',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFC2410C)),
                        ),
                      ] else if (isDikirim) ...[
                        const Text(
                          'Pesanan sedang dalam perjalanan.',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B21A8)),
                        ),
                      ] else ...[
                        const Text(
                          '300 gr • Suhu Simpan -18°C',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pesanan (${order.totalItems} barang)',
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                order.totalPrice,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isDikirim)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Apakah Anda sudah menerima pesanan ini dengan baik?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Selesai')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final success = await context.read<OrderProvider>().markAsCompleted(order.id);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pesanan telah selesai. Terima kasih!')),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menyelesaikan pesanan.')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Pesanan Selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else if (isActive)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Hubungi Penjual'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
                },
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Beli Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5D0FD),
                  foregroundColor: const Color(0xFF3E5980),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}