import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// HeroSection — Banner utama di Landing Page.
/// ============================================================
///
/// Menyediakan 3 cara penggunaan:
///
/// **1. Standalone (tanpa parallax):**
/// ```dart
/// HeroSection(onExploreMenu: () => ...)
/// ```
///
/// **2. Dengan parallax (split background + overlay):**
/// ```dart
/// ParallaxSection(
///   child: HeroSection.backgroundOnly(),
///   overlay: HeroSection.overlayOnly(onExploreMenu: () => ...),
/// )
/// ```
///
/// **Cara mengganti gambar:**
/// Ganti Container placeholder di [backgroundOnly] dengan:
/// ```dart
/// Image.asset('assets/images/hero_coffee.png', fit: BoxFit.cover)
/// ```
class HeroSection extends StatelessWidget {
  final VoidCallback onExploreMenu;

  const HeroSection({
    super.key,
    required this.onExploreMenu,
  });

  /// ─── BACKGROUND ONLY ──────────────────────────────────────
  /// Mengembalikan hanya gambar background (untuk parallax).
  /// TODO: Ganti Container placeholder dengan Image.asset(...)
  static Widget backgroundOnly() {
    return Container(
      color: Colors.grey[400],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee, size: 64, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'Hero Image\n(assets/images/hero_coffee.png)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// ─── OVERLAY ONLY ─────────────────────────────────────────
  /// Mengembalikan gradient + teks + tombol (untuk parallax overlay).
  static Widget overlayOnly({required VoidCallback onExploreMenu}) {
    return Stack(
      children: [
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        // Content
        Positioned(
          left: 24,
          right: 24,
          bottom: 40,
          child: Column(
            children: [
              const Text(
                'The ritual of morning connection. Discover artisanal brews, share your daily start, and join a community that celebrates the art of coffee.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onExploreMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Explore the menu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ─── STANDALONE BUILD (tanpa parallax) ────────────────────
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(child: backgroundOnly()),
          Positioned.fill(child: overlayOnly(onExploreMenu: onExploreMenu)),
        ],
      ),
    );
  }
}
