import 'package:flutter/material.dart';

/// ============================================================
/// ParallaxScrollView — ScrollView dengan efek parallax.
/// ============================================================
///
/// Widget ini menyediakan [ScrollController] yang otomatis
/// melacak posisi scroll. Child widget bisa menggunakan
/// [ParallaxSection] untuk memberikan efek parallax pada
/// gambar/konten tertentu.
///
/// **Cara penggunaan:**
/// ```dart
/// ParallaxScrollView(
///   children: [
///     ParallaxSection(
///       imageHeight: 320,
///       parallaxFactor: 0.5,
///       child: Image.asset('hero.png', fit: BoxFit.cover),
///       overlay: Text('Hello'),
///     ),
///     // konten lain yang scroll normal...
///   ],
/// )
/// ```
///
/// **Parameter:**
/// - [children]  — List widget yang akan ditampilkan.
/// - [appBar]    — AppBar opsional di atas scroll view.
/// - [bgColor]   — Warna background scaffold.
class ParallaxScrollView extends StatefulWidget {
  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final Color? bgColor;
  final EdgeInsetsGeometry? padding;

  const ParallaxScrollView({
    super.key,
    required this.children,
    this.appBar,
    this.bgColor,
    this.padding,
  });

  @override
  State<ParallaxScrollView> createState() => _ParallaxScrollViewState();
}

class _ParallaxScrollViewState extends State<ParallaxScrollView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: widget.appBar,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: widget.padding,
        child: _ParallaxData(
          scrollOffset: _scrollOffset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

/// ─── InheritedWidget untuk meneruskan scroll offset ─────────
/// ke seluruh child tree tanpa perlu passing manual.
class _ParallaxData extends InheritedWidget {
  final double scrollOffset;

  const _ParallaxData({
    required this.scrollOffset,
    required super.child,
  });

  static double of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ParallaxData>()?.scrollOffset ?? 0;
  }

  @override
  bool updateShouldNotify(_ParallaxData oldWidget) {
    return scrollOffset != oldWidget.scrollOffset;
  }
}

/// ============================================================
/// ParallaxSection — Section dengan efek parallax pada gambar.
/// ============================================================
///
/// Gambar/child di dalam section ini akan bergerak lebih lambat
/// dari konten lain saat user scroll, menciptakan efek depth.
///
/// **Parameter:**
/// - [imageHeight]    — Tinggi area gambar (visible height).
/// - [parallaxFactor] — Seberapa lambat gambar bergerak relatif
///                      terhadap scroll. Range 0.0 - 1.0.
///                      0.0 = tidak bergerak (fixed),
///                      0.5 = bergerak setengah kecepatan scroll,
///                      1.0 = bergerak normal (tidak ada parallax).
///                      Default: 0.4 (efek parallax halus).
/// - [child]          — Widget gambar/konten yang di-parallax.
/// - [overlay]        — Widget yang ditampilkan di atas gambar
///                      (teks, gradient, tombol, dll).
/// - [borderRadius]   — Border radius area parallax.
class ParallaxSection extends StatelessWidget {
  final double imageHeight;
  final double parallaxFactor;
  final Widget child;
  final Widget? overlay;
  final BorderRadius? borderRadius;

  const ParallaxSection({
    super.key,
    required this.imageHeight,
    this.parallaxFactor = 0.4,
    required this.child,
    this.overlay,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scrollOffset = _ParallaxData.of(context);

    // Hitung offset parallax:
    // Gambar bergerak lebih lambat karena kita menggesernya
    // ke arah berlawanan dengan sebagian dari scroll offset.
    final parallaxOffset = scrollOffset * (1 - parallaxFactor);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // ─── PARALLAX IMAGE ──────────────────────────────
            // Gambar dibuat lebih tinggi (1.3x) agar saat digeser
            // ke atas masih ada konten yang terlihat.
            Positioned(
              top: -parallaxOffset,
              left: 0,
              right: 0,
              child: SizedBox(
                height: imageHeight * 1.4,
                child: child,
              ),
            ),

            // ─── OVERLAY (teks, gradient, dll) ───────────────
            if (overlay != null)
              Positioned.fill(child: overlay!),
          ],
        ),
      ),
    );
  }
}
