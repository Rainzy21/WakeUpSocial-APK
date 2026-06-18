import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/widgets/parallax_scroll_view.dart';
import '../../../routes/navigation_helper.dart';
import '../widgets/hero_section.dart';
import '../widgets/feature_cards_section.dart';
import '../widgets/best_seller_section.dart';
import '../widgets/promo_banner.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/menu_repository.dart';

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
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isLoading = true;
  List<MenuItemModel> _bestSellers = [];

  @override
  void initState() {
    super.initState();
    _fetchBestSellers();
  }

  Future<void> _fetchBestSellers() async {
    try {
      final items = await MenuRepository().getMenuItems();
      if (mounted) {
        setState(() {
          // Untuk sementara ambil 4 item pertama sebagai "Best Seller"
          _bestSellers = items.take(4).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat best seller: $e')));
      }
    }
  }

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
          overlay: HeroSection.overlayOnly(
            onExploreMenu: () => NavigationHelper.toMenu(context),
          ),
          child: HeroSection.backgroundOnly(),
        ),

        const SizedBox(height: 20),

        // ─── FEATURE CARDS ───────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: FeatureCardsSection(),
        ),

        const SizedBox(height: 24),

        // ─── BEST SELLER ─────────────────────────────────────
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : BestSellerSection(
                items: _bestSellers,
                onSeeAll: () => NavigationHelper.toMenu(context),
                onAddToCart: (item) {
                  context.read<CartProvider>().addMenuItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} ditambahkan ke keranjang'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
