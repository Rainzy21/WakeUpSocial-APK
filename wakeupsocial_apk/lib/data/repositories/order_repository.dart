import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/order_status.dart';
import '../../core/network/resilient_call.dart';
import '../../core/services/local_storage_service.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalStorageService _storage = LocalStorageService();
  final _uuid = const Uuid();

  Future<Map<String, dynamic>> createOrder({
    required String sessionId,
    required List<OrderLineInput> items,
    String? couponId,
    String? notes,
    String? idempotencyKey,
  }) {
    final key = idempotencyKey ?? _uuid.v4();
    final payload = items
        .map((i) => {'menu_item_id': i.menuItemId, 'quantity': i.quantity})
        .toList();

    return ResilientCall.run(
      operation: 'order.create',
      maxRetries: 1,
      action: () async {
        final result = await _supabase.rpc('create_order', params: {
          'p_idempotency_key': key,
          'p_session_id': sessionId,
          'p_items': payload,
          'p_coupon_id': couponId,
          'p_notes': notes,
        });
        return Map<String, dynamic>.from(result as Map? ?? {});
      },
    );
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId) {
    return _rpcOrderAction('order.cancel', 'cancel_order', orderId);
  }

  Future<Map<String, dynamic>> reviewOrder(String orderId) {
    return _rpcOrderAction('order.review', 'review_order', orderId);
  }

  Future<Map<String, dynamic>> confirmOrder(String orderId) {
    return _rpcOrderAction('order.confirm', 'confirm_order', orderId);
  }

  Future<Map<String, dynamic>> markOrderReady(String orderId) {
    return _rpcOrderAction('order.mark_ready', 'mark_order_ready', orderId);
  }

  Future<Map<String, dynamic>> completeOrder(String orderId) {
    return _rpcOrderAction('order.complete', 'complete_order', orderId);
  }

  Future<Map<String, dynamic>> _rpcOrderAction(
    String operation,
    String rpcName,
    String orderId,
  ) {
    return ResilientCall.run(
      operation: operation,
      action: () async {
        final result = await _supabase.rpc(
          rpcName,
          params: {'p_order_id': orderId},
        );
        return Map<String, dynamic>.from(result as Map? ?? {});
      },
    );
  }

  Future<List<Map<String, dynamic>>> getCashierQueue() {
    return ResilientCall.run(
      operation: 'order.get_cashier_queue',
      action: () async {
        final response = await _supabase
            .from('orders')
            .select('*, order_items(*)')
            .inFilter(
              'status_v2',
              ['SUBMITTED', 'REVIEWING', 'CONFIRMED', 'READY'],
            )
            .order('created_at')
            .limit(50);
        return (response as List).cast<Map<String, dynamic>>();
      },
    );
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) {
    return ResilientCall.run(
      operation: 'order.get_by_id',
      tags: {'order_id': orderId},
      action: () async {
        if (_supabase.auth.currentUser == null) {
          final result = await _supabase.rpc(
            'get_public_order',
            params: {'p_order_id': orderId},
          );
          return Map<String, dynamic>.from(result as Map);
        }

        final response = await _supabase
            .from('orders')
            .select('*, order_items(*)')
            .eq('id', orderId)
            .single();
        return Map<String, dynamic>.from(response);
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMyOrders() {
    return ResilientCall.run(
      operation: 'order.get_my_orders',
      action: () async {
        final response = await _supabase
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false)
            .limit(20);
        return (response as List).cast<Map<String, dynamic>>();
      },
    );
  }

  Stream<Map<String, dynamic>> watchOrder(String orderId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) {
          if (rows.isEmpty) throw Exception('Order not found');
          return Map<String, dynamic>.from(rows.first);
        });
  }

  String generateIdempotencyKey() => _uuid.v4();
}

class OrderLineInput {
  final String menuItemId;
  final int quantity;

  const OrderLineInput({required this.menuItemId, required this.quantity});
}

extension OrderMapExtension on Map<String, dynamic> {
  OrderStatusV2 get statusV2 =>
      OrderStatusV2.fromDb(this['status_v2'] as String? ?? this['status'] as String?);

  int get totalAmountInt =>
      (this['total_amount'] as num?)?.toInt() ??
      (this['total_price'] as num?)?.round() ??
      0;
}
