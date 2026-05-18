import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// LoginScreen — Halaman login user.
/// ============================================================
///
/// Menampilkan:
/// - Logo / judul "WakeUpSocial"
/// - Subjudul "Welcome Back"
/// - Form: Email, Password
/// - Tombol "Sign In"       → [NavigationHelper.toHome]
/// - Social login buttons (Facebook, Google) — placeholder
/// - Link "Don't have an account? Sign Up" → [NavigationHelper.toSignUp]
///
/// **Navigasi dari halaman ini:**
/// - "Sign In"             → MainNavigation (home)
/// - "Sign Up" link        → SignUpScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ─── LOGO / JUDUL ──────────────────────────────
              // TODO: Ganti dengan Image.asset('assets/images/logo.png')
              const Text(
                'WAKE UP\nSOCIAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),

              // ─── FORM EMAIL ────────────────────────────────
              CustomTextField(
                label: 'Email',
                hint: 'Example@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // ─── FORM PASSWORD ─────────────────────────────
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ─── TOMBOL SIGN IN ────────────────────────────
              // Untuk demo: langsung navigasi ke Home tanpa validasi backend
              CustomButton(
                text: 'Sign In',
                onPressed: () => NavigationHelper.toHome(context),
              ),
              const SizedBox(height: 24),

              // ─── DIVIDER "Or Sign Up With" ─────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Or Sign Up With',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SOCIAL LOGIN BUTTONS ──────────────────────
              // Placeholder — belum terintegrasi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, 'Facebook'),
                  const SizedBox(width: 12),
                  _buildSocialButton(Icons.g_mobiledata, 'Google'),
                ],
              ),
              const SizedBox(height: 24),

              // ─── LINK KE SIGN UP ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => NavigationHelper.toSignUp(context),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget tombol social login (Facebook / Google).
  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
