import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final int price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void addToCart({
    required String name,
    required int price,
    required String imageUrl,
  }) {
    // Check if item already exists in cart
    final index = _items.indexWhere((item) => item.name == name);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(
        name: name,
        price: price,
        imageUrl: imageUrl,
      ));
    }
    notifyListeners();
  }

  void incrementQty(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decrementQty(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
