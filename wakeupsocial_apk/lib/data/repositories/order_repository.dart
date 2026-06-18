import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/order_status.dart';
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
  }) async {
    final key = idempotencyKey ?? _uuid.v4();
    final payload = items
        .map((i) => {'menu_item_id': i.menuItemId, 'quantity': i.quantity})
        .toList();

    final result = await _supabase.rpc('create_order', params: {
      'p_idempotency_key': key,
      'p_session_id': sessionId,
      'p_items': payload,
      'p_coupon_id': couponId,
      'p_notes': notes,
    });

    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final result = await _supabase.rpc(
      'cancel_order',
      params: {'p_order_id': orderId},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> reviewOrder(String orderId) async {
    final result = await _supabase.rpc(
      'review_order',
      params: {'p_order_id': orderId},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> confirmOrder(String orderId) async {
    final result = await _supabase.rpc(
      'confirm_order',
      params: {'p_order_id': orderId},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> markOrderReady(String orderId) async {
    final result = await _supabase.rpc(
      'mark_order_ready',
      params: {'p_order_id': orderId},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> completeOrder(String orderId) async {
    final result = await _supabase.rpc(
      'complete_order',
      params: {'p_order_id': orderId},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<List<Map<String, dynamic>>> getCashierQueue() async {
    final response = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .inFilter('status_v2', ['SUBMITTED', 'REVIEWING', 'CONFIRMED', 'READY'])
        .order('created_at');

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();
    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
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

/// Legacy adapter for screens still using OrderModel.
extension OrderMapExtension on Map<String, dynamic> {
  OrderStatusV2 get statusV2 =>
      OrderStatusV2.fromDb(this['status_v2'] as String? ?? this['status'] as String?);

  int get totalAmountInt =>
      (this['total_amount'] as num?)?.toInt() ??
      (this['total_price'] as num?)?.round() ??
      0;
}
