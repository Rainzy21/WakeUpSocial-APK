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
        return 0;
      case OrderStatusV2.reviewing:
        return 1;
      case OrderStatusV2.confirmed:
        return 2;
      case OrderStatusV2.ready:
      case OrderStatusV2.completed:
        return 3;
      case OrderStatusV2.cancelled:
      case OrderStatusV2.expired:
        return -1;
    }
  }

  /// Typical prep window (minutes) from order creation for in-progress statuses.
  int get estimatedPrepMinutes {
    switch (this) {
      case OrderStatusV2.submitted:
        return 15;
      case OrderStatusV2.reviewing:
        return 12;
      case OrderStatusV2.confirmed:
        return 8;
      case OrderStatusV2.ready:
      case OrderStatusV2.completed:
      case OrderStatusV2.cancelled:
      case OrderStatusV2.expired:
        return 0;
    }
  }
}

/// Subtitle shown on the order tracking screen, derived from status and timestamps.
String orderTrackingEtaMessage({
  required OrderStatusV2 status,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  switch (status) {
    case OrderStatusV2.ready:
      return 'Pesanan siap diambil';
    case OrderStatusV2.completed:
      return 'Pesanan selesai';
    case OrderStatusV2.cancelled:
      return 'Pesanan dibatalkan';
    case OrderStatusV2.expired:
      return 'Pesanan kedaluwarsa';
    case OrderStatusV2.submitted:
    case OrderStatusV2.reviewing:
    case OrderStatusV2.confirmed:
      final reference = updatedAt ?? createdAt;
      if (reference != null) {
        final elapsed = DateTime.now().difference(reference).inMinutes;
        final remaining =
            (status.estimatedPrepMinutes - elapsed).clamp(1, status.estimatedPrepMinutes);
        return 'Perkiraan $remaining menit lagi';
      }
      return 'Perkiraan ${status.estimatedPrepMinutes} menit lagi';
  }
}
