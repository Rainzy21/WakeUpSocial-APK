import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../../data/models/menu_item_model.dart';

class CartItem {
  final String menuItemId;
  final String name;
  final int price;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) => CartItem(
    menuItemId: menuItemId,
    name: name,
    price: price,
    imageUrl: imageUrl,
    quantity: quantity ?? this.quantity,
  );

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    menuItemId: json['menu_item_id'] as String? ?? json['id'] as String? ?? '',
    name: json['name'] as String,
    price: (json['price'] as num).toInt(),
    imageUrl: json['image_url'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 1,
  );

  int get subtotal => price * quantity;
}

class CartProvider extends ChangeNotifier {
  CartProvider(this._storage) {
    _restore();
  }

  final LocalStorageService _storage;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _restore() async {
    final saved = await _storage.loadCart();
    _items
      ..clear()
      ..addAll(saved.map(CartItem.fromJson));
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveCart(_items.map((e) => e.toJson()).toList());
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    await addItem(
      menuItemId: item.id,
      name: item.name,
      price: item.priceInt,
      imageUrl: item.imageUrl ?? '',
    );
  }

  Future<void> addItem({
    required String menuItemId,
    required String name,
    required int price,
    required String imageUrl,
  }) async {
    final idx = _items.indexWhere((i) => i.menuItemId == menuItemId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(
        CartItem(
          menuItemId: menuItemId,
          name: name,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    await _persist();
    notifyListeners();
  }

  Future<void> incrementQty(int index) async {
    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> decrementQty(int index) async {
    if (_items[index].quantity > 1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity - 1,
      );
      await _persist();
      notifyListeners();
    }
  }

  Future<void> removeItem(int index) async {
    _items.removeAt(index);
    await _persist();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await _storage.clearCart();
    notifyListeners();
  }
}
