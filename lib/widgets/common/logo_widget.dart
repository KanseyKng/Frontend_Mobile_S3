// lib/widgets/common/logo_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Logo horizontal "Ikobana" — untuk header screen
class LogoHorizontal extends StatelessWidget {
  final double width;
  final double height;

  const LogoHorizontal({
    super.key,
    this.width = 84,
    this.height = 28,
  });

  // URL logo dari Figma
  static const String _logoUrl =
      'https://api.builder.io/api/v1/image/assets/TEMP/e16f90b3a9da8f115d04ed330a997821aba10e1a?width=168';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        _logoUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
        // Loading placeholder
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallback();
        },
        // Error fallback (kalau URL gagal dimuat)
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
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
    );
  }
}

/// Logo square "Ikobana" — untuk splash/register
class LogoSquare extends StatelessWidget {
  final double size;

  const LogoSquare({super.key, this.size = 84});

  static const String _logoUrl =
      'https://api.builder.io/api/v1/image/assets/TEMP/9ed813abd496127126b76e9e698cff8401f1f24c?width=168';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        _logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallback();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          '🍗',
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }
}