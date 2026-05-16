import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// PromoBanner — Banner promo diskon di bagian bawah landing page.
/// ============================================================
///
/// Menampilkan banner gradient gelap-merah dengan:
/// - Teks "Promo hari ini" sebagai judul.
/// - Deskripsi promo (diskon 10% untuk 3 orang tercepat).
///
/// **Interaksi:**
/// - Hover  → shadow glow merah + sedikit lift.
/// - Press  → shadow lebih intens + scale mengecil.
///
/// **Cara mengganti dengan gambar banner:**
/// Ganti seluruh Container di bawah dengan:
/// ```dart
/// ClipRRect(
///   borderRadius: BorderRadius.circular(16),
///   child: Image.asset('assets/images/promo_banner.png', ...),
/// )
/// ```
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
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
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _isPressed ? 0.35 : _isHovered ? 0.25 : 0.12,
                ),
                blurRadius: _isPressed ? 8 : _isHovered ? 20 : 10,
                offset: Offset(0, _isPressed ? 2 : _isHovered ? 8 : 4),
                spreadRadius: _isPressed ? 0 : _isHovered ? 2 : 0,
              ),
            ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── JUDUL PROMO ─────────────────────────────────
              Text(
                'Promo hari ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8),

              // ─── DESKRIPSI PROMO ─────────────────────────────
              Text(
                '3 orang tercepat memsan menu ini akan mendapatkan diskon 10%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
