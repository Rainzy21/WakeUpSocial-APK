import 'package:flutter/material.dart';

/// ============================================================
/// Shimmer Effect — Animasi gradient bergerak untuk loading skeleton.
/// ============================================================
///
/// Widget ini membungkus child widget dengan efek shimmer
/// (gradient highlight bergerak dari kiri ke kanan).
///
/// **Penggunaan:**
/// ```dart
/// Shimmer(
///   child: SkeletonBox(width: 200, height: 20),
/// )
/// ```
///
/// Atau gunakan [ShimmerLoading] sebagai shorthand wrapper:
/// ```dart
/// ShimmerLoading(
///   isLoading: true,
///   skeleton: MySkeleton(),
///   child: MyActualContent(),
/// )
/// ```
class Shimmer extends StatefulWidget {
  final Widget child;

  /// Warna dasar skeleton (abu muda).
  final Color baseColor;

  /// Warna highlight yang bergerak (lebih terang).
  final Color highlightColor;

  /// Durasi satu siklus animasi shimmer.
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE8E8E8),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                (_animation.value + 2) / 4, // Normalize to 0-1
                1.0,
              ],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Transform untuk menggeser gradient dari kiri ke kanan.
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// ══════════════════════════════════════════════════════════════
// SKELETON BUILDING BLOCKS
// ══════════════════════════════════════════════════════════════

/// Kotak skeleton dengan rounded corners.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Lingkaran skeleton (untuk avatar).
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Garis skeleton (untuk teks placeholder).
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({
    super.key,
    required this.width,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHIMMER LOADING WRAPPER
// ══════════════════════════════════════════════════════════════

/// Widget yang menampilkan skeleton saat loading, dan
/// transisi smooth ke konten asli setelah loading selesai.
///
/// ```dart
/// ShimmerLoading(
///   isLoading: _isLoading,
///   skeleton: MenuSkeleton(),
///   child: MenuContent(),
/// )
/// ```
class ShimmerLoading extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;

  /// Durasi transisi fade dari skeleton ke konten.
  final Duration fadeDuration;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.fadeDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: fadeDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isLoading
          ? Shimmer(key: const ValueKey('skeleton'), child: skeleton)
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}
