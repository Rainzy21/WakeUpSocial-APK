import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Handles all authentication operations with Supabase Auth.
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns the currently authenticated user, or null if not logged in.
  User? get currentAuthUser => _supabase.auth.currentUser;

  /// Returns a stream that emits whenever auth state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Registers a new user with email and password.
  /// 
  /// [name] will be stored in user metadata and used when auto-creating the profile.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': ?phone,
      },
    );
  }

  /// Signs in an existing user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Initiates Google Sign In using Supabase OAuth.
  /// 
  /// This will open a web browser for the user to sign in with Google.
  /// After a successful login, it redirects back to the app using the custom scheme.
  Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      // URL Scheme redirect must match AndroidManifest.xml intent-filter
      redirectTo: 'io.supabase.wakeupsocial://login-callback/',
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Sends a password reset email to the given address.
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Fetches the current user's profile from the `profiles` table.
  /// Combines `auth.users` email with profile data.
  Future<UserModel?> getProfile() async {
    final authUser = currentAuthUser;
    if (authUser == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .single();

    return UserModel.fromJson(response, email: authUser.email);
  }
}
