import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

/// Handles all order-related CRUD operations.
class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Creates a new order from the user's cart items.
  /// 
  /// This is a two-step operation:
  /// 1. Insert the `orders` header row.
  /// 2. Insert all `order_items` linked to the new order.
  /// 
  /// Returns the newly created [OrderModel].
  Future<OrderModel> createOrder({
    required List<CartItemModel> cartItems,
    required PaymentMethod paymentMethod,
    String? tableNumber,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');
    if (cartItems.isEmpty) throw Exception('Keranjang belanja kosong');

    // Calculate total
    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    // Step 1: Insert order header
    final orderResponse = await _supabase.from('orders').insert({
      'user_id': userId,
      'payment_method': paymentMethod.name,
      'total_price': totalPrice,
      if (tableNumber != null) 'table_number': tableNumber,
      if (notes != null) 'notes': notes,
    }).select().single();

    final orderId = orderResponse['id'] as String;

    // Step 2: Insert order items (price & name snapshotted at this moment)
    final orderItemsPayload = cartItems
        .map((cartItem) => {
              'order_id': orderId,
              'menu_item_id': cartItem.menuItem.id,
              'name': cartItem.menuItem.name,
              'price': cartItem.menuItem.price,
              'quantity': cartItem.quantity,
            })
        .toList();

    await _supabase.from('order_items').insert(orderItemsPayload);

    // Fetch the complete order with items to return
    return getOrderById(orderId);
  }

  /// Fetches all orders belonging to the current user, newest first.
  Future<List<OrderModel>> getMyOrders() async {
    final response = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single order by its ID (with all items).
  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();

    return OrderModel.fromJson(response as Map<String, dynamic>);
  }

  /// Returns a real-time stream for a specific order.
  /// Useful for the order-tracking screen to show live status updates.
  Stream<OrderModel> watchOrder(String orderId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) {
          if (rows.isEmpty) throw Exception('Order tidak ditemukan');
          return OrderModel.fromJson(rows.first);
        });
  }

  /// Cancels an order. Only works if the order is still in 'pending' status.
  Future<OrderModel> cancelOrder(String orderId) async {
    // Fetch current order to check its status first
    final current = await getOrderById(orderId);

    if (current.status != OrderStatus.pending) {
      throw Exception(
          'Order tidak bisa dibatalkan karena sudah dalam status: ${current.status.displayName}');
    }

    final response = await _supabase
        .from('orders')
        .update({'status': OrderStatus.cancelled.name})
        .eq('id', orderId)
        .select('*, order_items(*)')
        .single();

    return OrderModel.fromJson(response as Map<String, dynamic>);
  }
}
