import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Handles reading and updating user profile data.
class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches the profile of the currently logged-in user.
  Future<UserModel?> getMyProfile() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .single();

    return UserModel.fromJson(response as Map<String, dynamic>,
        email: authUser.email);
  }

  /// Updates the profile of the currently logged-in user.
  /// 
  /// Only [name], [phone], and [avatarUrl] can be updated.
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    String? avatarUrl,
  }) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) throw Exception('User belum login');

    final response = await _supabase
        .from('profiles')
        .update({
          'name': name,
          if (phone != null) 'phone': phone,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        })
        .eq('id', authUser.id)
        .select()
        .single();

    return UserModel.fromJson(response as Map<String, dynamic>,
        email: authUser.email);
  }

  /// Uploads a profile avatar image to Supabase Storage and returns the public URL.
  /// 
  /// [fileBytes] is the raw bytes of the image file.
  /// [fileExt] is the file extension (e.g., 'jpg', 'png').
  Future<String> uploadAvatar({
    required Uint8List fileBytes,
    required String fileExt,
  }) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) throw Exception('User belum login');

    final filePath = '${authUser.id}/avatar.$fileExt';

    await _supabase.storage.from('avatars').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
        );

    return _supabase.storage.from('avatars').getPublicUrl(filePath);
  }
}
