/// Menu category data model.
class MenuCategoryModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}
