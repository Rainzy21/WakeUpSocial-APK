import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/resilient_call.dart';
import '../models/user_model.dart';

/// Handles reading and updating user profile data.
class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> getMyProfile() {
    return ResilientCall.run(
      operation: 'profile.get_my_profile',
      action: () async {
        final authUser = _supabase.auth.currentUser;
        if (authUser == null) return null;

        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', authUser.id)
            .single();

        return UserModel.fromJson(response, email: authUser.email);
      },
    );
  }

  Future<UserModel> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return ResilientCall.run(
      operation: 'profile.update',
      retryOnFailure: false,
      action: () async {
        final authUser = _supabase.auth.currentUser;
        if (authUser == null) throw Exception('User belum login');

        if (email != null && email.isNotEmpty && email != authUser.email) {
          await _supabase.auth.updateUser(UserAttributes(email: email));
        }

        final response = await _supabase
            .from('profiles')
            .update({'name': name, 'phone': ?phone, 'avatar_url': ?avatarUrl})
            .eq('id', authUser.id)
            .select()
            .single();

        return UserModel.fromJson(response, email: authUser.email);
      },
    );
  }

  Future<String> uploadAvatar({
    required Uint8List fileBytes,
    required String fileExt,
  }) {
    return ResilientCall.run(
      operation: 'profile.upload_avatar',
      maxRetries: 1,
      action: () async {
        final authUser = _supabase.auth.currentUser;
        if (authUser == null) throw Exception('User belum login');

        final filePath = '${authUser.id}/avatar.$fileExt';

        await _supabase.storage
            .from('avatars')
            .uploadBinary(
              filePath,
              fileBytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: 'image/$fileExt',
              ),
            );

        return _supabase.storage.from('avatars').getPublicUrl(filePath);
      },
    );
  }
}
