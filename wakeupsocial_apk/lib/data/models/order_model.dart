/// Enum representing possible states of an order.
enum OrderStatus {
  pending,
  processing,
  ready,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu Konfirmasi';
      case OrderStatus.processing:
        return 'Sedang Diproses';
      case OrderStatus.ready:
        return 'Siap Diambil';
      case OrderStatus.delivered:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

/// Enum for payment method.
enum PaymentMethod {
  cash,
  transfer;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
    }
  }
}

/// Enum for payment status.
enum PaymentStatus {
  unpaid,
  paid;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

/// Individual item within an order.
class OrderItemModel {
  final String id;
  final String orderId;
  final String? menuItemId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      menuItemId: json['menu_item_id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      if (menuItemId != null) 'menu_item_id': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

/// Order data model.
class OrderModel {
  final String id;
  final String? userId;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double totalPrice;
  final String? notes;
  final String? tableNumber;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    this.userId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalPrice,
    this.notes,
    this.tableNumber,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      status: OrderStatus.fromString(json['status'] as String),
      paymentMethod:
          PaymentMethod.fromString(json['payment_method'] as String),
      paymentStatus:
          PaymentStatus.fromString(json['payment_status'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      tableNumber: json['table_number'] as String?,
      items: rawItems
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status.name,
      'payment_method': paymentMethod.name,
      'payment_status': paymentStatus.name,
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
      if (tableNumber != null) 'table_number': tableNumber,
    };
  }
}
