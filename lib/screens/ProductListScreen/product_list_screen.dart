// lib/screens/ProductListScreen/product_list_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/common/logo_widget.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../ProductDetailScreen/product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int selectedCategory = 0;
  String selectedSort = 'Terpopuler';

  final List<Map<String, String>> kategori = const [
    {'emoji': '🍗', 'label': 'Nugget'},
    {'emoji': '🌭', 'label': 'Sosis'},
    {'emoji': '🥟', 'label': 'Dimsum'},
    {'emoji': '🍟', 'label': 'Kentang'},
    {'emoji': '🍤', 'label': 'Seafood'},
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
      name: 'Sosis Premium',
      price: 'Rp 28.000',
      rating: 4.9,
      reviewCount: 85,
      stock: 8,
      badgeLabel: 'Favorit',
      category: 'Sosis',
    ),
    ProductModel(
      id: 'p3',
      name: 'Dimsum Ayam',
      price: 'Rp 32.000',
      rating: 4.9,
      reviewCount: 95,
      stock: 15,
      badgeLabel: 'Favorit',
      category: 'Dimsum',
    ),
    ProductModel(
      id: 'p4',
      name: 'Bakso Sapi Urat Super',
      price: 'Rp 40.000',
      rating: 4.7,
      reviewCount: 70,
      stock: 0,
      badgeLabel: 'Habis',
      category: 'Lainnya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(child: _buildContent()),
                  _buildProductSliverGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
          const BottomNavBar(activeIndex: 1),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      toolbarHeight: 64,
      titleSpacing: 16,
      leadingWidth: 56,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Daftar Produk',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Produk',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Temukan frozen food favoritmu',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Badge Cold Chain
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5D0FD),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.ac_unit, size: 12, color: Color(0xFF3E5980)),
                    SizedBox(width: 4),
                    Text(
                      'Cold Chain Ready',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E5980),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk frozen food...',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Kategori Pills
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kategori.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isActive = selectedCategory == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = i),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        kategori[i]['label']!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Counter + Sort
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Menampilkan '),
                    TextSpan(
                      text: '${produk.length} produk',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' frozen food'),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    selectedSort,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primary, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

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
            final p = produk[index];
            return ProductCard(
              product: p,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: p),
                  ),
                );
              },
            );
          },
          childCount: produk.length,
        ),
      ),
    );
  }
}