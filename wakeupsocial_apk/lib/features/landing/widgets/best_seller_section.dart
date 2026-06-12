import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// BestSellerSection — Section produk best seller (horizontal scroll).
/// ============================================================
///
/// Menampilkan header "Best Seller" + "See All >" dan daftar
/// produk horizontal yang bisa di-scroll.
///
/// **Interaksi:**
/// - Hover kartu → shadow membesar + sedikit lift.
/// - Press kartu → shadow lebih dalam + scale mengecil.
///
/// **Data Source:**
/// Saat ini menggunakan mock data statis [_mockProducts].
/// TODO: Ganti dengan data dari repository/API.
class BestSellerSection extends StatelessWidget {
  /// Callback ketika tombol "See All >" ditekan.
  final VoidCallback? onSeeAll;

  /// Callback ketika tombol "+" pada produk ditekan.
  final void Function(String name, int price)? onAddToCart;

  const BestSellerSection({
    super.key,
    this.onSeeAll,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── HEADER ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Best Seller',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              // "See All >" — navigasi ke halaman Menu
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See All >',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ─── HORIZONTAL LIST ─────────────────────────────────
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockProducts.length,
            itemBuilder: (context, index) {
              final p = _mockProducts[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _mockProducts.length - 1 ? 12 : 0,
                ),
                child: _ProductCard(
                  name: p['name'] as String,
                  price: p['priceStr'] as String,
                  onAddToCart: () => onAddToCart?.call(p['name'] as String, p['price'] as int),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Mock data produk best seller.
/// TODO: Ganti dengan data dari repository/API.
final List<Map<String, dynamic>> _mockProducts = [
  {'name': 'Flat White', 'priceStr': 'Rp 25.000', 'price': 25000},
  {'name': 'Nitro Cold Brew', 'priceStr': 'Rp 23.000', 'price': 23000},
  {'name': 'Long Black', 'priceStr': 'Rp 23.000', 'price': 23000},
  {'name': 'Iced Mocha', 'priceStr': 'Rp 28.000', 'price': 28000},
];

/// ─── PRODUCT CARD ───────────────────────────────────────────
/// Kartu produk individual dengan drop shadow + hover/press effect.
class _ProductCard extends StatefulWidget {
  final String name;
  final String price;
  final VoidCallback? onAddToCart;

  const _ProductCard({
    required this.name,
    required this.price,
    this.onAddToCart,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isPressed ? 0.10 : _isHovered ? 0.08 : 0.05,
                ),
                blurRadius: _isPressed ? 6 : _isHovered ? 16 : 8,
                offset: Offset(0, _isPressed ? 1 : _isHovered ? 6 : 3),
                spreadRadius: _isPressed ? 0 : _isHovered ? 1 : 0,
              ),
            ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.96))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── GAMBAR PLACEHOLDER ────────────────────────────
              // TODO: Ganti dengan Image.asset('assets/images/...')
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 110,
                  width: 140,
                  color: Colors.grey[200],
                  child: Icon(Icons.local_cafe, color: Colors.grey[400], size: 32),
                ),
              ),

              // ─── INFO PRODUK ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.price,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        // Tombol + → ke Cart
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
