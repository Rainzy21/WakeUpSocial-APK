import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/order_status.dart';
import '../../../data/repositories/order_repository.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final _orderRepo = OrderRepository();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
    _channel = Supabase.instance.client
        .channel('cashier-orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (_) => _load(),
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final orders = await _orderRepo.getCashierQueue();
      if (mounted) setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat antrian kasir: $e')),
        );
      }
    }
  }

  Future<void> _action(String orderId, Future<Map<String, dynamic>> Function() fn) async {
    try {
      await fn();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _orders.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Tidak ada pesanan aktif')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final status = OrderStatusV2.fromDb(order['status_v2'] as String?);
                        final total = (order['total_amount'] as num?)?.toInt() ?? 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${(order['id'] as String).substring(0, 8)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(status.displayName),
                                Text('Total: Rp ${_formatIdr(total)}'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (status == OrderStatusV2.submitted ||
                                        status == OrderStatusV2.reviewing)
                                      OutlinedButton(
                                        onPressed: () => _action(
                                          order['id'] as String,
                                          () => _orderRepo.reviewOrder(order['id'] as String),
                                        ),
                                        child: const Text('Review'),
                                      ),
                                    if (status == OrderStatusV2.submitted ||
                                        status == OrderStatusV2.reviewing)
                                      ElevatedButton(
                                        onPressed: () => _action(
                                          order['id'] as String,
                                          () => _orderRepo.confirmOrder(order['id'] as String),
                                        ),
                                        child: const Text('Confirm'),
                                      ),
                                    if (status == OrderStatusV2.confirmed)
                                      ElevatedButton(
                                        onPressed: () => _action(
                                          order['id'] as String,
                                          () => _orderRepo.markOrderReady(order['id'] as String),
                                        ),
                                        child: const Text('Ready'),
                                      ),
                                    if (status == OrderStatusV2.ready)
                                      ElevatedButton(
                                        onPressed: () => _action(
                                          order['id'] as String,
                                          () => _orderRepo.completeOrder(order['id'] as String),
                                        ),
                                        child: const Text('Complete'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  String _formatIdr(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
