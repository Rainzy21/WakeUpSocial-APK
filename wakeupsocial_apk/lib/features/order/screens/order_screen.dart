import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../routes/navigation_helper.dart';
import '../../../core/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================
/// OrderScreen — Halaman checkout / konfirmasi pesanan.
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← CHECKOUT" + search icon
/// - Input field: Name, Table number
/// - Order summary card: daftar item + total
/// - Bottom: tombol "Buat Pesanan"
///
/// **Navigasi:**
/// - Back → CartScreen
/// - "Buat Pesanan" → OrderTrackingScreen
///
/// TODO: Ganti mock data dengan data dari cart repository.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = true;
  bool _isCheckingOut = false;
  final _nameController = TextEditingController();
  final _tableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final _orderItems = cart.items;
    final _totalPrice = cart.totalPrice;
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
          'CHECKOUT',
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
        skeleton: const _CheckoutSkeleton(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── NAME ───────────────────────────────────────
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _nameController,
                hint: 'Enter your name',
              ),
              const SizedBox(height: 20),

              // ─── TABLE NUMBER ───────────────────────────────
              const Text(
                'Table number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _tableController,
                hint: 'Table number',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // ─── ORDER SUMMARY ──────────────────────────────
              _buildOrderSummary(_orderItems, _totalPrice),
            ],
          ),
        ),
      ),

      // ─── BOTTOM: BUAT PESANAN ─────────────────────────────
      bottomNavigationBar: _isLoading ? null : _buildBottomButton(cart),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════════

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> orderItems, int totalPrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Item list
          ...orderItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.name}  x${item.quantity}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatPrice(item.price * item.quantity),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )),

          // Divider
          Container(
            height: 1,
            color: AppColors.divider,
            margin: const EdgeInsets.symmetric(vertical: 6),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatPrice(totalPrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: _HoverButton(
            label: _isCheckingOut ? 'Loading...' : 'Buat Pesanan',
            onTap: _isCheckingOut ? () {} : () => _submitOrder(cart),
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder(CartProvider cart) async {
    final name = _nameController.text.trim();
    final tableStr = _tableController.text.trim();

    if (name.isEmpty || tableStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Nomor Meja harus diisi')),
      );
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong')),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      // 1. Create order
      final Map<String, dynamic> orderData = {
        'status': 'pending',
        'payment_method': 'cash',
        'payment_status': 'unpaid',
        'total_price': cart.totalPrice,
        'table_number': tableStr,
        'notes': 'Atas nama: $name',
      };

      // Jika user sudah login, sertakan user_id
      if (userId != null) {
        orderData['user_id'] = userId;
      }

      final orderResponse = await supabase.from('orders').insert(orderData).select().single();

      final orderId = orderResponse['id'];

      // 2. Create order items
      final orderItemsData = cart.items.map((item) => {
        'order_id': orderId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      }).toList();

      await supabase.from('order_items').insert(orderItemsData);

      // 3. Clear cart
      cart.clearCart();

      // 4. Navigate to tracking screen
      if (mounted) {
        NavigationHelper.toOrderTracking(context, orderId: orderId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
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
          height: 50,
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.accent.withValues(alpha: 0.85)
                : AppColors.accent,
            borderRadius: BorderRadius.circular(28),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CHECKOUT SKELETON
// ══════════════════════════════════════════════════════════════

class _CheckoutSkeleton extends StatelessWidget {
  const _CheckoutSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLine(width: 50, height: 13),
          const SizedBox(height: 8),
          SkeletonBox(height: 48, borderRadius: 12),
          const SizedBox(height: 20),
          SkeletonLine(width: 90, height: 13),
          const SizedBox(height: 8),
          SkeletonBox(height: 48, borderRadius: 12),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 110, height: 14),
                const SizedBox(height: 16),
                ...List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonLine(width: 130, height: 12),
                      SkeletonLine(width: 70, height: 12),
                    ],
                  ),
                )),
                const SizedBox(height: 4),
                Container(height: 1, color: const Color(0xFFE8E8E8)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLine(width: 40, height: 14),
                    SkeletonLine(width: 80, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
