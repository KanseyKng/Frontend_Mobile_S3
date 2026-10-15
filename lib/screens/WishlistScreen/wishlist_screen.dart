// lib/screens/WishlistScreen/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../ProductDetailScreen/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int selectedFilter = 0;

  final List<String> filters = const [
    'Semua',
    'Terbaru',
    'Harga Terendah',
    'Harga Tertinggi',
  ];

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: wishlist.items.isEmpty
                        ? _buildEmptyState()
                        : _buildContent(wishlist),
                  ),
                ],
              ),
            ),
          ),
          const BottomNavBar(activeIndex: -1), // -1 = tidak ada tab aktif
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF131B2E)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Item Yang Disukai',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF131B2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WishlistProvider wishlist) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: const [
                Icon(Icons.ac_unit, size: 13, color: Color(0xFF006C49)),
                SizedBox(width: 6),
                Text(
                  'Jaminan Dingin -18°C Tetap Segar',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF006C49),
                  ),
                ),
              ],
            ),
          ),

          // Counter + Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${wishlist.totalItems} produk tersimpan',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF414753),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.search,
                    color: Color(0xFF414753), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isActive = selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF004FA5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        filters[i],
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF414753),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Grid Produk
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final product = wishlist.items[index];
              return _buildWishlistCard(product);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF131B2E).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar + Badge + Remove
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fastfood,
                      size: 48, color: AppColors.textMuted),
                ),
                // Badge BEKU
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0267D2).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.ac_unit,
                            color: Colors.white, size: 9),
                        SizedBox(width: 2),
                        Text(
                          'BEKU',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Remove
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<WishlistProvider>()
                          .removeFromWishlist(product.id);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite,
                          color: Color(0xFFA70519), size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Rating
            Row(
              children: [
                const Icon(Icons.star,
                    color: Color(0xFFF59E0B), size: 11),
                const SizedBox(width: 4),
                Text(
                  product.rating.toString(),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF131B2E),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '• ${product.reviewCount}+ terjual',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    color: Color(0xFF414753),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Nama
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131B2E),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),

            // Harga
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                    color: Color(0xFF131B2E),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Rp40.000',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    decoration: TextDecoration.lineThrough,
                    color: Color(0xFF727784),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add to Cart
            GestureDetector(
              onTap: () {
                context.read<CartProvider>().addToCart(product, qty: 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk ditambahkan ke keranjang'),
                    backgroundColor: Color(0xFF283044),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004FA5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart,
                        color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '+ Keranjang',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border,
              size: 80, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Belum ada item yang disukai',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap icon hati di produk untuk menyimpannya',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}