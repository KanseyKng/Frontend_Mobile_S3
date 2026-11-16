// lib/screens/HomeScreen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/cards/category_pill.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/cards/bento_reorder_card.dart';
import '../../widgets/common/logo_widget.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/sheets/address_bottom_sheet.dart';
import '../ProductListScreen/product_list_screen.dart';
import '../ProductDetailScreen/product_detail_screen.dart';
import '../NotificationScreen/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;

  final List<Map<String, String>> kategori = const [
    {'emoji': '🍗', 'label': 'Nugget'},
    {'emoji': '🌭', 'label': 'Sosis'},
    {'emoji': '🥟', 'label': 'Dimsum'},
    {'emoji': '🍟', 'label': 'Kentang'},
    {'emoji': '🍤', 'label': 'Seafood'},
    {'emoji': '⋯', 'label': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  void _goToProductList() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
  }

  void _goToProductDetail(ProductModel product) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
  }

  void _goToNotification() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddressBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<ProductProvider>().fetchProducts();
                await context.read<AddressProvider>().fetchAddresses();
              },
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(child: _buildBodyContent()),
                  _buildProductSliverGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
          const BottomNavBar(activeIndex: 0),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      surfaceTintColor: Colors.white,
      elevation: 0,
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Row(
        children: [
          const LogoHorizontal(),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _showAddressBottomSheet,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 12),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'Alamat Pengiriman',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 14),
                    ],
                  ),
                  Text(
                    context.watch<AddressProvider>().displayAddress,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _goToNotification,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 24),
                Consumer<NotificationProvider>(
                  builder: (context, notifProvider, child) {
                    if (notifProvider.unreadCount == 0) return const SizedBox();
                    return Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        child: Text('${notifProvider.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyContent() {
    final auth = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Halo, ${auth.userName} 👋', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Mau pesan frozen food apa hari ini?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _buildAddressCard(),
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

  Widget _buildAddressCard() {
    final addr = context.watch<AddressProvider>().currentAddress;
    return GestureDetector(
      onTap: _showAddressBottomSheet,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF00682B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                  child: const Text('ALAMAT UTAMA', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF00682B))),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward, color: Color(0xFF191C1E), size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text('${addr.recipientName} (${addr.phoneNumber})', style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
            const SizedBox(height: 4),
            Text(addr.fullAddress, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF424656), height: 1.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFDAE1FF).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      const Icon(Icons.home, size: 10, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(addr.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSliverGrid() {
    final productProvider = context.watch<ProductProvider>();

    if (productProvider.isLoading) {
      return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())));
    }

    if (productProvider.error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(productProvider.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => productProvider.fetchProducts(), child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final selectedCatName = kategori[selectedCategory]['label']!;
    final filteredProducts = productProvider.products.where((p) {
      if (selectedCatName == 'Lainnya') {
        final availableCats = kategori.map((e) => e['label']).toList();
        return !availableCats.contains(p.category);
      }
      return p.category == selectedCatName;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada produk di kategori ini.', style: TextStyle(color: AppColors.textSecondary)))));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.62),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == filteredProducts.length) return const BentoReorderCard();
            final p = filteredProducts[index];
            return ProductCard(product: p, onTap: () => _goToProductDetail(p));
          },
          childCount: filteredProducts.length + 1,
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF004AC6), Color(0xFF001C3B)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -30, bottom: -30,
            child: Container(width: 128, height: 128, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text('PROMO SPESIAL UMKM', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.25)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Gratis Ongkir!', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              const Text('Untuk pesanan tertentu di seluruh area Mojokerto', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFFEEEFFF))),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _goToProductList,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Belanja Sekarang', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: AppColors.primary, size: 11),
                    ],
                  ),
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
            Text('Kategori', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('Segar & Beku', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
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
              return CategoryPill(emoji: kategori[i]['emoji']!, label: kategori[i]['label']!, isActive: selectedCategory == i, onTap: () => setState(() => selectedCategory = i));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJaminanBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFB5D0FD).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jaminan Rantai Dingin', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('Ice pack higienis di setiap pesanan kurir instan.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textSecondary)),
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
            Text('Produk Pilihan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('Koleksi favorit warga Mojokerto', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        GestureDetector(
          onTap: _goToProductList,
          child: const Text('Lihat Semua', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ],
    );
  }
}