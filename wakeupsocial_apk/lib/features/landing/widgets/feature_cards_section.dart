import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// FeatureCardsSection — Dua kartu informasi di bawah hero banner.
/// ============================================================
///
/// Menampilkan dua kartu berdampingan:
///
/// 1. **Morning Curator** (kiri)
///    - Deskripsi layanan kurasi kopi harian.
///    - Gambar kopi latte art di bagian bawah kartu.
///
/// 2. **Brewing Today** (kanan)
///    - Info jam operasional (Senin-Minggu, Buka 24 jam).
///    - Gambar barista/interior di bagian kanan kartu.
///
/// **Interaksi:**
/// - Hover → shadow membesar + sedikit terangkat.
/// - Press → shadow lebih dalam + scale mengecil sedikit.
///
/// **Cara mengganti gambar:**
/// Ganti `_buildImagePlaceholder(...)` dengan `Image.asset(...)`.
class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── KARTU KIRI: Morning Curator ─────────────────────
        Expanded(child: _HoverCard(child: _buildMorningCuratorContent())),
        const SizedBox(width: 12),

        // ─── KARTU KANAN: Brewing Today ──────────────────────
        Expanded(child: _HoverCard(child: _buildBrewingTodayContent())),
      ],
    );
  }

  /// ─── Morning Curator Card content ─────────────────────────
  Widget _buildMorningCuratorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Morning Curator',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your personalized daily selection of the finest roasts and brewing techniques.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        // TODO: Ganti placeholder dengan gambar asli
        // Path: assets/images/morning_curator.png
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImagePlaceholder(
            height: 100,
            label: 'morning_curator.png',
          ),
        ),
      ],
    );
  }

  /// ─── Brewing Today Card content ───────────────────────────
  Widget _buildBrewingTodayContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WE'RE NOW",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Brewing Today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kami siap melayani harimu. Senin - Minggu. Buka 24 jam.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // TODO: Ganti placeholder dengan gambar asli
        // Path: assets/images/brewing_today.png
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImagePlaceholder(
            width: 80,
            height: 120,
            label: 'brewing_today.png',
          ),
        ),
      ],
    );
  }

  /// ─── IMAGE PLACEHOLDER ──────────────────────────────────────
  Widget _buildImagePlaceholder({
    double? width,
    double height = 100,
    required String label,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey[500], size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── HOVER CARD ─────────────────────────────────────────────
/// Card wrapper dengan drop shadow default + hover lift + press sink.
class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  // DI SINI PERUBAHANNYA: Inisialisasi parameter 'this.onTap' ke dalam constructor
  const _HoverCard({required this.child, this.onTap});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(
                  _isPressed
                      ? 25
                      : _isHovered
                      ? 20
                      : 13, // Menggunakan integer untuk alpha di Flutter terbaru
                ),
                blurRadius: _isPressed
                    ? 6
                    : _isHovered
                    ? 16
                    : 8,
                offset: Offset(
                  0,
                  _isPressed
                      ? 1
                      : _isHovered
                      ? 6
                      : 3,
                ),
                spreadRadius: _isPressed
                    ? 0
                    : _isHovered
                    ? 1
                    : 0,
              ),
            ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
