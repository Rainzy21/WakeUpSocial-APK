import 'menu_item_model.dart';

/// Cart item data model.
class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
  });

  double get subtotal => menuItem.price * quantity;
}
