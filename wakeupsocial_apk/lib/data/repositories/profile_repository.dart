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

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .single();

      return UserModel.fromJson(response as Map<String, dynamic>,
          email: authUser.email);
    } catch (e) {
      // PGRST116 means JSON object requested, multiple (or no) rows returned.
      // In `.single()` context, it usually means no row was found.
      if (e is PostgrestException && e.code == 'PGRST116') {
        // Fallback: Create the profile if it doesn't exist
        final name = authUser.userMetadata?['name'] ?? authUser.email?.split('@').first ?? 'Unknown User';
        
        final newProfile = await _supabase
            .from('profiles')
            .insert({
              'id': authUser.id,
              'name': name,
              'phone': authUser.userMetadata?['phone'],
              'avatar_url': authUser.userMetadata?['avatar_url'],
            })
            .select()
            .single();

        return UserModel.fromJson(newProfile as Map<String, dynamic>,
            email: authUser.email);
      }
      rethrow;
    }
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
