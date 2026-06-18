import 'package:flutter/foundation.dart';
import '../../data/models/menu_item_model.dart';

import '../../data/models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  // Singleton instance
  CartService._privateConstructor();
  static final CartService instance = CartService._privateConstructor();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.menuItem.price.toInt() * item.quantity),
    );
  }

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(MenuItemModel product) {
    final existingIndex = _items.indexWhere((item) => item.menuItem.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItemModel(menuItem: product));
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
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
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
