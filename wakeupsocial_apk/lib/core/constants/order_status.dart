/// Blueprint order status values (maps to orders.status_v2 in Postgres).
enum OrderStatusV2 {
  submitted,
  reviewing,
  confirmed,
  ready,
  completed,
  cancelled,
  expired;

  static OrderStatusV2 fromDb(String? value) {
    if (value == null) return OrderStatusV2.submitted;
    final normalized = value.toLowerCase();
    return OrderStatusV2.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => OrderStatusV2.submitted,
    );
  }

  String get dbValue => name.toUpperCase();

  String get displayName {
    switch (this) {
      case OrderStatusV2.submitted:
        return 'Menunggu Konfirmasi';
      case OrderStatusV2.reviewing:
        return 'Sedang Ditinjau Kasir';
      case OrderStatusV2.confirmed:
        return 'Dikonfirmasi';
      case OrderStatusV2.ready:
        return 'Siap Diambil';
      case OrderStatusV2.completed:
        return 'Selesai';
      case OrderStatusV2.cancelled:
        return 'Dibatalkan';
      case OrderStatusV2.expired:
        return 'Kedaluwarsa';
    }
  }

  int get trackingStep {
    switch (this) {
      case OrderStatusV2.submitted:
      case OrderStatusV2.reviewing:
        return 1;
      case OrderStatusV2.confirmed:
        return 2;
      case OrderStatusV2.ready:
      case OrderStatusV2.completed:
        return 3;
      case OrderStatusV2.cancelled:
      case OrderStatusV2.expired:
        return 0;
    }
  }
}
