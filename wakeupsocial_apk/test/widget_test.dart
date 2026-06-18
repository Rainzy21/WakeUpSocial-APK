import 'package:flutter_test/flutter_test.dart';
import 'package:wakeupsocial_apk/core/constants/order_status.dart';
import 'package:wakeupsocial_apk/core/providers/cart_provider.dart';
import 'package:wakeupsocial_apk/data/models/order_model.dart';
import 'package:wakeupsocial_apk/data/models/user_model.dart';
import 'package:wakeupsocial_apk/data/repositories/order_repository.dart';

void main() {
  group('CartItem', () {
    test('subtotal is price times quantity', () {
      const item = CartItem(
        menuItemId: 'item-1',
        name: 'Latte',
        price: 25000,
        imageUrl: '',
        quantity: 2,
      );

      expect(item.subtotal, 50000);
    });

    test('copyWith updates quantity', () {
      const item = CartItem(
        menuItemId: 'item-1',
        name: 'Latte',
        price: 25000,
        imageUrl: '',
      );

      expect(item.copyWith(quantity: 4).quantity, 4);
    });
  });

  group('OrderStatusV2', () {
    test('fromDb normalizes uppercase database values', () {
      expect(OrderStatusV2.fromDb('CONFIRMED'), OrderStatusV2.confirmed);
      expect(OrderStatusV2.fromDb('ready'), OrderStatusV2.ready);
    });

    test('trackingStep maps blueprint statuses to UI steps', () {
      expect(OrderStatusV2.submitted.trackingStep, 0);
      expect(OrderStatusV2.confirmed.trackingStep, 2);
      expect(OrderStatusV2.ready.trackingStep, 3);
      expect(OrderStatusV2.cancelled.trackingStep, -1);
    });
  });

  group('orderTrackingEtaMessage', () {
    test('returns terminal status messages', () {
      expect(
        orderTrackingEtaMessage(status: OrderStatusV2.ready),
        'Pesanan siap diambil',
      );
      expect(
        orderTrackingEtaMessage(status: OrderStatusV2.completed),
        'Pesanan selesai',
      );
    });

    test('derives remaining minutes from createdAt', () {
      final createdAt = DateTime.now().subtract(const Duration(minutes: 5));
      final message = orderTrackingEtaMessage(
        status: OrderStatusV2.confirmed,
        createdAt: createdAt,
      );

      expect(message, 'Perkiraan 3 menit lagi');
    });
  });

  group('OrderModel', () {
    test('fromJson prefers status_v2 and total_amount', () {
      final order = OrderModel.fromJson({
        'id': 'order-1',
        'status_v2': 'READY',
        'status': 'pending',
        'total_amount': 42000,
        'total_price': 1000,
        'payment_method': 'cash',
        'payment_status': 'unpaid',
        'created_at': '2026-06-19T10:00:00.000Z',
        'order_items': [],
      });

      expect(order.status, OrderStatus.ready);
      expect(order.totalPrice, 42000);
    });
  });

  group('UserModel', () {
    test('isCashier is true only for CASHIER role', () {
      const cashier = UserModel(
        id: '1',
        name: 'Cashier',
        email: 'c@example.com',
        role: 'CASHIER',
      );
      const customer = UserModel(
        id: '2',
        name: 'Customer',
        email: 'u@example.com',
      );

      expect(cashier.isCashier, isTrue);
      expect(customer.isCashier, isFalse);
    });
  });

  group('OrderMapExtension', () {
    test('statusV2 and totalAmountInt read blueprint columns', () {
      final map = {
        'status_v2': 'CONFIRMED',
        'total_amount': 55000,
      };

      expect(map.statusV2, OrderStatusV2.confirmed);
      expect(map.totalAmountInt, 55000);
    });
  });
}
