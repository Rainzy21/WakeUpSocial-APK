/// Order data model.
class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String status; // pending, processing, delivered, cancelled
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  // TODO: Add fromJson / toJson
}

/// Individual item within an order.
class OrderItemModel {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  // TODO: Add fromJson / toJson
}
