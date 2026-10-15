// lib/widgets/common/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../screens/HomeScreen/home_screen.dart';
import '../../screens/ProductListScreen/product_list_screen.dart';
import '../../screens/CartScreen/cart_screen.dart';
import '../../screens/OrderListScreen/order_list_screen.dart';
import '../../screens/ProfileScreen/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex; // 0=Beranda, 1=Cari, 2=Keranjang, 3=Pesanan, 4=Profil

  const BottomNavBar({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context, 0, Icons.home, 'Beranda',
                onTap: () {
                  if (activeIndex == 0) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
              _navItem(
                context, 1, Icons.search, 'Cari',
                onTap: () {
                  if (activeIndex == 1) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  );
                },
              ),
              _navItem(
                context, 2, Icons.shopping_cart_outlined, 'Keranjang',
                badge: cart.totalItems > 0 ? '${cart.totalItems}' : null,
                onTap: () {
                  if (activeIndex == 2) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              _navItem(
                context, 3, Icons.receipt_long, 'Pesanan',
                onTap: () {
                  if (activeIndex == 3) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderListScreen()),
                  );
                },
              ),
              _navItem(
                context, 4, Icons.person_outline, 'Profil',
                onTap: () {
                  if (activeIndex == 4) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    IconData icon,
    String label, {
    String? badge,
    VoidCallback? onTap,
  }) {
    final bool isActive = activeIndex == index;
    final Color color =
        isActive ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
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