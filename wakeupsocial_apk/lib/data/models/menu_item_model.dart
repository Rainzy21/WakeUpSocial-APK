import 'menu_category_model.dart';

/// Menu item data model.
class MenuItemModel {
  final String id;
  final String? categoryId;
  final MenuCategoryModel? category; // populated via join
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MenuItemModel({
    required this.id,
    this.categoryId,
    this.category,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      category: json['menu_categories'] != null
          ? MenuCategoryModel.fromJson(
              json['menu_categories'] as Map<String, dynamic>)
          : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: (json['is_available'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (categoryId != null) 'category_id': categoryId,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }
}
