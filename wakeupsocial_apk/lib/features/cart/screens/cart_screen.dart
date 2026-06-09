import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// CartScreen — Halaman keranjang belanja.
/// ============================================================
///
/// Desain minimalis + aesthetic sesuai mockup:
/// - AppBar: "← CART" + search icon
/// - Daftar item keranjang (gambar, nama, harga, qty ± , delete)
/// - Bottom bar: Total + Tombol "Checkout"
///
/// **Fitur interaktif:**
/// - Card item dengan drop shadow + hover/press effect
/// - Tombol ± quantity dengan AnimatedSwitcher pada angka
/// - Swipe-to-delete (Dismissible) dengan background merah
/// - Empty state saat keranjang kosong
///
/// TODO: Integrasi dengan state management (Provider/Riverpod).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  /// Mock cart items — TODO: Ganti dengan data dari cart repository
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  int get _totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  void _incrementQty(int index) {
    setState(() => _cartItems[index]['qty']++);
  }

  void _decrementQty(int index) {
    if (_cartItems[index]['qty'] > 1) {
      setState(() => _cartItems[index]['qty']--);
    }
  }

  void _removeItem(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => NavigationHelper.back(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
        ),
        title: const Text(
          'CART',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      body: ShimmerLoading(
        isLoading: _isLoading,
        skeleton: const _CartSkeleton(),
        child: _cartItems.isEmpty ? _buildEmptyState() : _buildCartList(),
      ),

      // ─── BOTTOM BAR: Total + Checkout ─────────────────────
      bottomNavigationBar: _isLoading || _cartItems.isEmpty
          ? null
          : _buildBottomBar(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 36, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          const Text(
            'Keranjang kosong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Yuk, pesan kopi favoritmu!',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Dismissible(
          key: ValueKey('${item['name']}_$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeItem(index),
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.delete_outline, color: AppColors.error, size: 24),
          ),
          child: _CartItemCard(
            name: item['name'],
            price: _formatPrice(item['price']),
            qty: item['qty'],
            iconData: item['image'],
            onIncrement: () => _incrementQty(index),
            onDecrement: () => _decrementQty(index),
            onDelete: () => _removeItem(index),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ─── TOTAL ──────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatPrice(_totalPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // ─── CHECKOUT BUTTON ────────────────────────────
              Expanded(
                child: _HoverButton(
                  label: 'Checkout',
                  onTap: () => NavigationHelper.toOrder(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CART ITEM CARD
// ══════════════════════════════════════════════════════════════

class _CartItemCard extends StatefulWidget {
  final String name;
  final String price;
  final int qty;
  final IconData iconData;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.name,
    required this.price,
    required this.qty,
    required this.iconData,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered ? 0.08 : 0.04,
              ),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 3),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // ─── IMAGE PLACEHOLDER ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.surface,
                child: Icon(widget.iconData, color: Colors.grey[500], size: 28),
              ),
            ),
            const SizedBox(width: 12),

            // ─── INFO ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.price,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ─── QTY CONTROLS ─────────────────────────
                  _buildQtyControls(),
                ],
              ),
            ),

            // ─── DELETE BUTTON ───────────────────────────────
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_outline, color: AppColors.error, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          GestureDetector(
            onTap: widget.onDecrement,
            child: const SizedBox(
              width: 32,
              height: 30,
              child: Center(
                child: Text('−', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          // Quantity
          Container(
            width: 28,
            height: 30,
            color: AppColors.accent,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '${widget.qty}',
                key: ValueKey(widget.qty),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Plus
          GestureDetector(
            onTap: widget.onIncrement,
            child: const SizedBox(
              width: 32,
              height: 30,
              child: Center(
                child: Text('+', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HOVER BUTTON
// ══════════════════════════════════════════════════════════════

class _HoverButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _HoverButton({required this.label, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
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
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.accent.withValues(alpha: 0.85)
                : AppColors.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(
                  alpha: _isPressed ? 0.15 : _isHovered ? 0.25 : 0.1,
                ),
                blurRadius: _isPressed ? 4 : _isHovered ? 14 : 6,
                offset: Offset(0, _isPressed ? 1 : _isHovered ? 5 : 2),
              ),
            ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CART SKELETON
// ══════════════════════════════════════════════════════════════

class _CartSkeleton extends StatelessWidget {
  const _CartSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SkeletonBox(width: 64, height: 64, borderRadius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 110, height: 14),
                    const SizedBox(height: 6),
                    SkeletonLine(width: 80, height: 12),
                    const SizedBox(height: 8),
                    SkeletonBox(width: 92, height: 30, borderRadius: 8),
                  ],
                ),
              ),
              SkeletonBox(width: 32, height: 32, borderRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
