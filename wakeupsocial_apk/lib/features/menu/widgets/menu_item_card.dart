import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// MenuItemCard — Kartu produk untuk grid di halaman Menu.
/// ============================================================
///
/// Menampilkan:
/// - Gambar produk (placeholder abu-abu).
/// - Nama produk.
/// - Harga.
/// - Tombol add-to-cart (ikon "+").
///
/// **Interaksi:**
/// - Hover  → muncul shadow + sedikit lift effect.
/// - Press  → shadow lebih dalam + scale sedikit.
/// - Normal → shadow halus default.
///
/// **Cara mengganti gambar:**
/// Ganti Container placeholder dengan:
/// ```dart
/// Image.asset('assets/images/products/$productId.png', fit: BoxFit.cover)
/// ```
class MenuItemCard extends StatefulWidget {
  final String name;
  final String description;
  final String price;
  final String? imageUrl; // Parameter untuk image content (Asset / Network)
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const MenuItemCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.onAddToCart,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isPressed ? 0.10 : _isHovered ? 0.08 : 0.04,
                ),
                blurRadius: _isPressed ? 6 : _isHovered ? 14 : 8,
                offset: Offset(0, _isPressed ? 1 : _isHovered ? 5 : 2),
              ),
            ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── GAMBAR PRODUK ─────────────────
              // Mendukung 3 mode:
              //   1. Network  → imageUrl dimulai dengan 'http'
              //   2. Asset    → imageUrl = path asset, misal 'assets/images/menu/kopi.png'
              //   3. Kosong   → placeholder icon
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: _buildProductImage(),
                ),
              ),

              // ─── INFO PRODUK ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama produk
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
                    const SizedBox(height: 2),

                    // Deskripsi singkat
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Harga + tombol add-to-cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
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

  // ══════════════════════════════════════════════════════════════
  // IMAGE BUILDER — otomatis pilih Network / Asset / Placeholder
  // ══════════════════════════════════════════════════════════════

  Widget _buildProductImage() {
    final url = widget.imageUrl;

    // Jika kosong → placeholder
    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

    // Jika dimulai dengan http → Network image
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        // Loading indicator saat gambar sedang di-download
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
              ),
            ),
          );
        },
        // Jika gagal load (URL diblokir/broken) → tampilkan placeholder
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(showError: true);
        },
      );
    }

    // Selain http → Asset image (file lokal dari assets/)
    return Image.asset(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(showError: true);
      },
    );
  }

  /// Placeholder ketika gambar belum ada atau gagal load.
  Widget _buildPlaceholder({bool showError = false}) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showError ? Icons.broken_image_outlined : Icons.image_outlined,
              color: Colors.grey[400],
              size: 36,
            ),
            if (showError) ...[
              const SizedBox(height: 4),
              Text(
                'Gambar error',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
