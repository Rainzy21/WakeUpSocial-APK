import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// MenuPromoCarousel — Banner promo carousel di halaman Menu.
/// ============================================================
///
/// Menampilkan satu atau beberapa banner promo yang bisa
/// di-swipe horizontal menggunakan [PageView].
///
/// Setiap slide berisi:
/// - Gambar latar (placeholder/gambar asli).
/// - Judul promo.
/// - Deskripsi promo.
///
/// **Cara mengganti gambar:**
/// Ganti Container placeholder dengan:
/// ```dart
/// Image.asset('assets/images/promo_menu_1.png', fit: BoxFit.cover)
/// ```
///
/// **Menambah/mengurangi slide:**
/// Edit list [_promoSlides] di bawah.
class MenuPromoCarousel extends StatefulWidget {
  const MenuPromoCarousel({super.key});

  @override
  State<MenuPromoCarousel> createState() => _MenuPromoCarouselState();
}

class _MenuPromoCarouselState extends State<MenuPromoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── PAGE VIEW ─────────────────────────────────────
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _promoSlides.length,
            itemBuilder: (context, index) {
              final slide = _promoSlides[index];
              return _buildSlide(slide);
            },
          ),
        ),
        const SizedBox(height: 8),

        // ─── PAGE INDICATOR DOTS ───────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoSlides.length,
            (i) => Container(
              width: _currentPage == i ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun satu slide promo.
  Widget _buildSlide(Map<String, String> slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ─── BACKGROUND IMAGE PLACEHOLDER ──────────────
            // TODO: Ganti dengan Image.asset(slide['image']!)
            Positioned.fill(
              child: Container(
                color: Colors.grey[400],
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[500],
                    size: 40,
                  ),
                ),
              ),
            ),

            // ─── GRADIENT OVERLAY ──────────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),

            // ─── TEKS PROMO ────────────────────────────────
            Positioned(
              left: 20,
              top: 20,
              right: 80,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Judul promo
                  Text(
                    slide['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Deskripsi promo
                  Text(
                    slide['desc']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data slides promo.
/// TODO: Ganti dengan data dari backend/CMS.
final List<Map<String, String>> _promoSlides = [
  {
    'title': 'Latte art',
    'desc': 'POV: Kamu nemu kopi paling worth it di kota ini.',
    'image': 'assets/images/promo_latte_art.png',
  },
  {
    'title': 'New Menu!',
    'desc': 'Coba Social Fusion, signature blend terbaru kami.',
    'image': 'assets/images/promo_new_menu.png',
  },
  {
    'title': 'Happy Hour',
    'desc': 'Buy 1 Get 1 setiap hari Jumat, jam 3-5 sore.',
    'image': 'assets/images/promo_happy_hour.png',
  },
];
