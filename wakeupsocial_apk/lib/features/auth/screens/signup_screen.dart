import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// SignUpScreen — Halaman registrasi user baru.
/// ============================================================
///
/// Menampilkan:
/// - Logo / judul "WakeUpSocial"
/// - Subjudul "Create Account"
/// - Form: Name, Email, Password, Confirm Password
/// - Tombol "Sign Up"          → [NavigationHelper.toHome]
/// - Social login buttons      — placeholder
/// - Link "Already have an account? Sign In" → Navigator.pop
///
/// **Navigasi dari halaman ini:**
/// - "Sign Up"         → MainNavigation (home)
/// - "Sign In" link    → kembali ke LoginScreen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              const SizedBox(height: 24),

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
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // ─── FORM NAME ─────────────────────────────────
              CustomTextField(
                label: 'Name',
                hint: 'Enter your name...',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),

              // ─── FORM EMAIL ────────────────────────────────
              CustomTextField(
                label: 'Email',
                hint: 'Example@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // ─── FORM PASSWORD ─────────────────────────────
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ─── FORM CONFIRM PASSWORD ─────────────────────
              CustomTextField(
                label: 'Confirm Password',
                hint: '••••••••',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── TOMBOL SIGN UP ────────────────────────────
              // Untuk demo: langsung navigasi ke Home tanpa validasi
              CustomButton(
                text: 'Sign Up',
                onPressed: () => NavigationHelper.toHome(context),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 14),

              // ─── SOCIAL LOGIN BUTTONS ──────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, 'Facebook'),
                  const SizedBox(width: 12),
                  _buildSocialButton(Icons.g_mobiledata, 'Google'),
                ],
              ),
              const SizedBox(height: 20),

              // ─── LINK KE LOGIN ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => NavigationHelper.back(context),
                    child: const Text(
                      'Sign In',
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

  /// Widget tombol social login.
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
