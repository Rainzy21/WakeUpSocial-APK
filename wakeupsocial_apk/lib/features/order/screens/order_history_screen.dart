import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// OrderHistoryScreen — Halaman riwayat pesanan (dari Profile).
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← Order History" + search icon
/// - List card order: icon, nama, jumlah menu, order number,
///   tanggal, badge "Selesai", icon receipt
///
/// TODO: Ganti mock data dengan data dari API/repository.
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

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
          'Order History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          ),
        ],
      ),
      body: _mockOrders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada pesanan', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _mockOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final order = _mockOrders[index];
                return _OrderHistoryCard(
                  name: order['name']!,
                  menuCount: order['menuCount']!,
                  orderNumber: order['orderNumber']!,
                  date: order['date']!,
                  status: order['status']!,
                  onTap: () => NavigationHelper.toOrderDetail(
                    context,
                    orderId: order['orderNumber']!,
                  ),
                );
              },
            ),
    );
  }
}

/// ─── ORDER HISTORY CARD ─────────────────────────────────────
/// Layout sesuai mockup: bag icon | info (name, menu count, order#, date) | status badge | receipt icon
class _OrderHistoryCard extends StatelessWidget {
  final String name;
  final String menuCount;
  final String orderNumber;
  final String date;
  final String status;
  final VoidCallback? onTap;

  const _OrderHistoryCard({
    required this.name,
    required this.menuCount,
    required this.orderNumber,
    required this.date,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // ─── BAG ICON ──────────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // ─── INFO ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + order number
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• Order #$orderNumber',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Menu count + date
                  Row(
                    children: [
                      Text(
                        '$menuCount Menu',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── STATUS BADGE ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF388E3C),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ─── RECEIPT ICON ──────────────────────────────
            Icon(
              Icons.receipt_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock data order history (sesuai mockup).
/// TODO: Ganti dengan data dari repository/API.
final List<Map<String, String>> _mockOrders = [
  {'name': 'Nabil jaringan', 'menuCount': '3', 'orderNumber': '03', 'date': '12-05-2026', 'status': 'Selesai'},
  {'name': 'Nabil jaringan', 'menuCount': '3', 'orderNumber': '03', 'date': '12-05-2026', 'status': 'Selesai'},
  {'name': 'Nabil jaringan', 'menuCount': '3', 'orderNumber': '03', 'date': '12-05-2026', 'status': 'Selesai'},
  {'name': 'Nabil jaringan', 'menuCount': '3', 'orderNumber': '03', 'date': '12-05-2026', 'status': 'Selesai'},
  {'name': 'Nabil jaringan', 'menuCount': '3', 'orderNumber': '03', 'date': '12-05-2026', 'status': 'Selesai'},
];
