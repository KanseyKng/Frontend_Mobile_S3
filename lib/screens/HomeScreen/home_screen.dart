// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/cards/category_pill.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/cards/bento_reorder_card.dart';
import '../CardScreen/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  int bottomNavIndex = 0;

  final List<Map<String, String>> kategori = const [
    {'emoji': '🍗', 'label': 'Nugget'},
    {'emoji': '🌭', 'label': 'Sosis'},
    {'emoji': '🥟', 'label': 'Dimsum'},
    {'emoji': '🍟', 'label': 'Kentang'},
    {'emoji': '🍤', 'label': 'Seafood'},
    {'emoji': '⋯', 'label': 'Lainnya'},
  ];

  final List<ProductModel> produk = const [
    ProductModel(
      id: 'p1',
      name: 'Nugget Ayam Crispy',
      price: 'Rp 35.000',
      rating: 4.8,
      reviewCount: 120,
      stock: 25,
      badgeLabel: 'Terlaris',
      category: 'Nugget',
    ),
    ProductModel(
      id: 'p2',
      name: 'Sosis Sapi & Ayam Premium',
      price: 'Rp 28.000',
      rating: 4.9,
      reviewCount: 85,
      stock: 8,
      badgeLabel: 'Favorit',
      category: 'Sosis',
    ),
    ProductModel(
      id: 'p3',
      name: 'Dimsum Siomay Ayam',
      price: 'Rp 32.000',
      rating: 4.9,
      reviewCount: 95,
      stock: 15,
      badgeLabel: 'Favorit',
      category: 'Dimsum',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // ✅ ADVANCED UI: CustomScrollView + SliverAppBar
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(child: _buildBodyContent()),
                  _buildProductSliverGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ===== SLIVER APP BAR (header yang collapse saat scroll) =====
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      expandedHeight: 64,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: Colors.white),
        titlePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Row(
          children: [
            Container(
              width: 84,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'Ikobana',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: AppColors.primary, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Mojokerto, Jawa Timur',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'LOCALMART - Beranda',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_none,
                  color: AppColors.textSecondary, size: 24),
            ),
            Positioned(
              right: 12,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== BODY (greeting, promo, kategori, jaminan) =====
  Widget _buildBodyContent() {
    // ✅ Global state: greeting pakai nama dari AuthProvider
    final auth = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${auth.userName} 👋',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mau pesan frozen food apa hari ini?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _buildPromoBanner(),
          const SizedBox(height: 20),
          _buildKategoriSection(),
          const SizedBox(height: 20),
          _buildJaminanBanner(),
          const SizedBox(height: 20),
          _buildProdukHeader(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ===== SLIVER GRID: produk + bento card =====
  Widget _buildProductSliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Bento card di posisi terakhir (index = 3)
            if (index == produk.length) {
              return const BentoReorderCard();
            }
            final p = produk[index];
            return ProductCard(
              product: p,
              onTap: () {},
            );
          },
          childCount: produk.length + 1, // +1 untuk bento card
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text(
                      'PROMO SPESIAL UMKM',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gratis Ongkir!',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Untuk pesanan tertentu di seluruh area Mojokerto',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFFEEEFFF),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Belanja Sekarang',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward,
                        color: AppColors.primary, size: 11),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Kategori',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Segar & Beku',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kategori.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return CategoryPill(
                emoji: kategori[i]['emoji']!,
                label: kategori[i]['label']!,
                isActive: selectedCategory == i,
                onTap: () => setState(() => selectedCategory = i),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJaminanBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB5D0FD).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaminan Rantai Dingin',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ice pack higienis di setiap pesanan kurir instan.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk Pilihan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Koleksi favorit warga Mojokerto',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ===== BOTTOM NAV (badge dari CartProvider) =====
  Widget _buildBottomNav() {
    // ✅ Global state: badge keranjang otomatis update
    final cart = context.watch<CartProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home, 'Beranda'),
            _navItem(1, Icons.search, 'Cari'),
            _navItem(
              2,
              Icons.shopping_cart_outlined,
              'Keranjang',
              badge: cart.totalItems > 0 ? '${cart.totalItems}' : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
              },
            ),
            _navItem(3, Icons.receipt_long, 'Pesanan'),
            _navItem(4, Icons.person_outline, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label, {
    String? badge,
    VoidCallback? onTap,
  }) {
    final bool isActive = bottomNavIndex == index;
    final Color color =
        isActive ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap ?? () => setState(() => bottomNavIndex = index),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 20),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}