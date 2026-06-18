/// User profile + loyalty fields from public.profiles.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final int loyaltyPoints;
  final int lifetimePoints;
  final String currentTier;
  final int purchaseCount;
  final int currentStampCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'CUSTOMER',
    this.loyaltyPoints = 0,
    this.lifetimePoints = 0,
    this.currentTier = 'BRONZE',
    this.purchaseCount = 0,
    this.currentStampCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCashier => role == 'CASHIER';

  factory UserModel.fromJson(Map<String, dynamic> json, {String? email}) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: email ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetime_points'] as num?)?.toInt() ?? 0,
      currentTier: json['current_tier'] as String? ?? 'BRONZE',
      purchaseCount: (json['purchase_count'] as num?)?.toInt() ?? 0,
      currentStampCount: (json['current_stamp_count'] as num?)?.toInt() ?? 0,
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
      'name': name,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      loyaltyPoints: loyaltyPoints,
      lifetimePoints: lifetimePoints,
      currentTier: currentTier,
      purchaseCount: purchaseCount,
      currentStampCount: currentStampCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
