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

    return UserModel.fromJson(response,
        email: authUser.email);
  }

  /// Updates the profile of the currently logged-in user.
  /// 
  /// Only [name], [phone], and [avatarUrl] can be updated.
  Future<UserModel> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) throw Exception('User belum login');

    if (email != null && email.isNotEmpty && email != authUser.email) {
      await _supabase.auth.updateUser(UserAttributes(email: email));
    }

    final response = await _supabase
        .from('profiles')
        .update({
          'name': name,
          'phone': ?phone,
          'avatar_url': ?avatarUrl,
        })
        .eq('id', authUser.id)
        .select()
        .single();

    return UserModel.fromJson(response,
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
