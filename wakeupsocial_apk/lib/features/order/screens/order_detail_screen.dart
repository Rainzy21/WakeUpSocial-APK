import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

/// ============================================================
/// OrderDetailScreen — Halaman detail satu pesanan.
/// ============================================================
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    try {
      final order = await OrderRepository().getOrderById(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pesanan: $e')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => NavigationHelper.back(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
        ),
        title: const Text(
          'ORDER DETAIL',
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
      ),
      body: ShimmerLoading(
        isLoading: _isLoading,
        skeleton: const OrderDetailSkeleton(),
        child: _order == null
            ? const Center(child: Text('Pesanan tidak ditemukan'))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── STATUS ORDER ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _order!.status == OrderStatus.delivered
                                ? Colors.green.shade50
                                : AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _order!.status.displayName,
                            style: TextStyle(
                              color: _order!.status == OrderStatus.delivered
                                  ? Colors.green.shade700
                                  : AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── NAME ORDER ──────────────────────────────────
                    const Text(
                      'Nama Pemesan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildReadonlyField(_order!.notes ?? '-'),
                    const SizedBox(height: 16),

                    // ─── ORDER NUMBER & TABLE ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Number',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildReadonlyField('#${_order!.id.substring(0, 8).toUpperCase()}'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Table',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildReadonlyField(_order!.tableNumber ?? '-'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── ORDER SUMMARY ───────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Item list
                          ..._order!.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
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
                                      _formatPrice(item.subtotal),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          const Divider(height: 16),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _formatPrice(_order!.totalPrice),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                    // ─── LIHAT STRUK BUTTON (Only if Delivered) ───────────
                    if (_order!.status == OrderStatus.delivered)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/order/receipt', arguments: _order!.id);
                          },
                          icon: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                          label: const Text(
                            'Lihat Struk',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Field readonly dengan background abu-abu.
  Widget _buildReadonlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
