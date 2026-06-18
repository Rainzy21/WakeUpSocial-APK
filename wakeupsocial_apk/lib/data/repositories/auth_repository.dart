import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/resilient_call.dart';
import '../models/user_model.dart';

/// Handles all authentication operations with Supabase Auth.
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentAuthUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) {
    return ResilientCall.run(
      operation: 'auth.sign_up',
      retryOnFailure: false,
      action: () => _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': ?phone},
      ),
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return ResilientCall.run(
      operation: 'auth.sign_in',
      retryOnFailure: false,
      action: () =>
          _supabase.auth.signInWithPassword(email: email, password: password),
    );
  }

  Future<bool> signInWithGoogle() {
    return ResilientCall.run(
      operation: 'auth.sign_in_google',
      retryOnFailure: false,
      action: () => _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.wakeupsocial://login-callback/',
      ),
    );
  }

  Future<void> updateFcmToken(String token) {
    return ResilientCall.run(
      operation: 'auth.update_fcm_token',
      action: () =>
          _supabase.rpc('update_fcm_token', params: {'p_token': token}),
    );
  }

  Future<void> signOut() {
    return ResilientCall.run(
      operation: 'auth.sign_out',
      retryOnFailure: false,
      action: () => _supabase.auth.signOut(),
    );
  }

  Future<void> resetPassword(String email) {
    return ResilientCall.run(
      operation: 'auth.reset_password',
      retryOnFailure: false,
      action: () => _supabase.auth.resetPasswordForEmail(email),
    );
  }

  Future<UserModel?> getProfile() {
    return ResilientCall.run(
      operation: 'auth.get_profile',
      action: () async {
        final authUser = currentAuthUser;
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
}
