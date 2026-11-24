// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ CONDITIONAL IMPORT
import 'webview_platform_stub.dart'
    if (dart.library.html) 'webview_platform_web.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';
import 'providers/product_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/LoginScreen/login_screen.dart';
import 'screens/HomeScreen/home_screen.dart';

void main() {
  // ✅ Panggil fungsi inisialisasi
  initWebViewPlatform();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = CartProvider();
    final wishlistProvider = WishlistProvider();
    final orderProvider = OrderProvider();
    final notificationProvider = NotificationProvider();
    final addressProvider = AddressProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: wishlistProvider),
        ChangeNotifierProvider.value(value: orderProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: addressProvider),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            cartProvider: cartProvider,
            wishlistProvider: wishlistProvider,
            orderProvider: orderProvider,
            notificationProvider: notificationProvider,
            addressProvider: addressProvider,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ikobana Frozen Food',
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.checkSession();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}