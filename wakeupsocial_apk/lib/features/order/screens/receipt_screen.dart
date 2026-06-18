import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/navigation_helper.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

/// ============================================================
/// ReceiptScreen — Halaman struk/resi digital.
/// ============================================================
class ReceiptScreen extends StatefulWidget {
  final String orderId;

  const ReceiptScreen({super.key, required this.orderId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
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
          SnackBar(content: Text('Error loading receipt: $e')),
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
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // We'll have a custom back to home button
        title: const Text(
          'E-RECEIPT',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _order == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : _buildReceiptContent(),
    );
  }

  Widget _buildReceiptContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // ─── RECEIPT PAPER ──────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                const SizedBox(height: 24),
                Icon(Icons.coffee, size: 40, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  'Wake Up Social',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thank you for your order!',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDashedLine(),
                const SizedBox(height: 20),

                // Order Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildInfoRow('Order ID', '#${_order!.id.substring(0, 8).toUpperCase()}'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Date', '${_order!.createdAt.day}-${_order!.createdAt.month}-${_order!.createdAt.year} ${_order!.createdAt.hour}:${_order!.createdAt.minute.toString().padLeft(2, '0')}'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Name', _order!.notes ?? '-'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Table No.', _order!.tableNumber ?? '-'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Status', 'PAID / DELIVERED', isBold: true, color: const Color(0xFF388E3C)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDashedLine(),
                const SizedBox(height: 20),

                // Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: _order!.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              _formatPrice(item.subtotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDashedLine(),
                const SizedBox(height: 20),

                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatPrice(_order!.totalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // ─── BOTTOM ACTION ────────────────────────────────
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => NavigationHelper.toHome(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 5.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.divider),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
