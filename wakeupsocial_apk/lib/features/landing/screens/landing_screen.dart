import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/parallax_scroll_view.dart';
import '../../../routes/navigation_helper.dart';
import '../widgets/hero_section.dart';
import '../widgets/feature_cards_section.dart';
import '../widgets/best_seller_section.dart';
import '../widgets/promo_banner.dart';

/// ============================================================
/// LandingScreen — Halaman utama / beranda (Tab 0: Home).
/// ============================================================
///
/// Menggunakan [ParallaxScrollView] untuk memberikan efek
/// parallax pada Hero banner saat user scroll ke bawah.
///
/// Struktur parallax:
/// - HeroSection  → parallax 0.4 (bergerak 60% lebih lambat)
/// - Konten lain  → scroll normal
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParallaxScrollView(
      bgColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Wake Up Social',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => NavigationHelper.toCart(context),
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Keranjang',
          ),
        ],
      ),
      children: [
        // ─── HERO BANNER (PARALLAX) ──────────────────────────
        // Gambar hero bergerak lebih lambat dari scroll,
        // menciptakan efek kedalaman visual.
        ParallaxSection(
          imageHeight: 320,
          parallaxFactor: 0.5,
          child: HeroSection.backgroundOnly(),
          overlay: HeroSection.overlayOnly(
            onExploreMenu: () => NavigationHelper.toMenu(context),
          ),
        ),

        const SizedBox(height: 20),

        // ─── FEATURE CARDS ───────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: FeatureCardsSection(),
        ),

        const SizedBox(height: 24),

        // ─── BEST SELLER ─────────────────────────────────────
        BestSellerSection(
          onSeeAll: () => NavigationHelper.toMenu(context),
          onAddToCart: (_) => NavigationHelper.toCart(context),
        ),

        const SizedBox(height: 20),

        // ─── PROMO BANNER ────────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PromoBanner(),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
