import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/observability/app_logger.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/session_provider.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/session_repository.dart';

/// ============================================================
/// OrderScreen — Halaman checkout / konfirmasi pesanan.
/// ============================================================
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  final _nameController = TextEditingController();
  final _tableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final profile = await AuthRepository().getProfile();
      if (profile != null && mounted) {
        _nameController.text = profile.name;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString().split('').reversed.join('');
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  Future<void> _submitOrder() async {
    final cart = context.read<CartProvider>();
    final cartItems = cart.items;
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang belanja kosong')));
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama pemesan harus diisi')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      String? currentSessionId = sessionProvider.sessionId;

      // Jembatan untuk kompatibilitas jika tidak scan QR:
      if (currentSessionId == null) {
        // Jika tidak boleh menggunakan anonymous, kita paksa user login dulu
        final isLoggedIn = await NavigationHelper.requireAuth(context);
        if (!isLoggedIn) {
          setState(() => _isSubmitting = false);
          return;
        }

        final tNum = int.tryParse(_tableController.text.trim()) ?? 1;
        final sessionRepo = SessionRepository();
        final tableId = await sessionRepo.getTableIdByNumber(tNum);
        final sessionResp = await sessionRepo.createSession(tableId);
        currentSessionId = sessionResp['id'] as String;
        await sessionProvider.setSession(
          sessionId: currentSessionId,
          tableId: tableId,
          tableNumber: tNum,
        );
      }

      final orderItemsInput = cartItems
          .map(
            (item) => OrderLineInput(
              menuItemId: item.menuItemId,
              quantity: item.quantity,
            ),
          )
          .toList();

      final orderMap = await OrderRepository().createOrder(
        sessionId: currentSessionId!,
        items: orderItemsInput,
        notes:
            _nameController.text.trim() +
            (_tableController.text.trim().isNotEmpty
                ? ' (Meja: ${_tableController.text.trim()})'
                : ''),
      );

      final orderId = orderMap['order_id'] as String;

      await cart.clearCart();
      if (mounted) {
        // Pop the current OrderScreen and CartScreen and go tracking
        Navigator.popUntil(context, (route) => route.isFirst); // back to home
        NavigationHelper.toOrderTracking(context, orderId: orderId);
      }
    } catch (e, st) {
      AppLogger.error('order.submit_failed', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 22,
          ),
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
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
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
              _buildOrderSummary(),
            ],
          ),
        ),
      ),

      // ─── BOTTOM: BUAT PESANAN ─────────────────────────────
      bottomNavigationBar: _isLoading ? null : _buildBottomButton(),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;
    final totalPrice = cart.totalPrice.toDouble();
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
          ...cartItems.map(
            (item) => Padding(
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
                    _formatPrice((item.price * item.quantity).toDouble()),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

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

  Widget _buildBottomButton() {
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
          child: _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : _HoverButton(label: 'Buat Pesanan', onTap: _submitOrder),
        ),
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
          height: 50,
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.accent.withValues(alpha: 0.85)
                : AppColors.accent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(
                  alpha: _isPressed
                      ? 0.15
                      : _isHovered
                      ? 0.25
                      : 0.1,
                ),
                blurRadius: _isPressed
                    ? 4
                    : _isHovered
                    ? 14
                    : 6,
                offset: Offset(
                  0,
                  _isPressed
                      ? 1
                      : _isHovered
                      ? 5
                      : 2,
                ),
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
                ...List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLine(width: 130, height: 12),
                        SkeletonLine(width: 70, height: 12),
                      ],
                    ),
                  ),
                ),
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
