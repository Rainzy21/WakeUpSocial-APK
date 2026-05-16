import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// ProfileDetailScreen — Halaman detail profil (view only).
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← Profile detail" + search icon
/// - Avatar (lingkaran, placeholder)
/// - Field readonly: Nama, Email (dengan icon suffix)
/// - Tombol "Edit Profile" (merah penuh)
///
/// TODO: Ganti data statis dengan data dari UserModel.
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => NavigationHelper.back(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
        ),
        title: const Text(
          'Profile detail',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          ),
        ],
      ),
      body: ShimmerLoading(
        isLoading: _isLoading,
        skeleton: const ProfileFormSkeleton(fieldCount: 2),
        child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ─── AVATAR ──────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── NAMA ────────────────────────────────────────
            const Text(
              'Nama',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildReadonlyField(
              value: 'Example',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // ─── EMAIL ───────────────────────────────────────
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildReadonlyField(
              value: 'Example@gmail.com',
              icon: Icons.mail_outline,
            ),
            const SizedBox(height: 32),

            // ─── EDIT PROFILE BUTTON ─────────────────────────
            _HoverShadowButton(
              label: 'Edit  Profile',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Field readonly dengan border, teks di kiri, icon di kanan.
  Widget _buildReadonlyField({required String value, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(icon, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}

/// ─── HOVER/PRESS SHADOW BUTTON ──────────────────────────────
/// Tombol merah penuh yang memiliki shadow saat hover dan press.
class _HoverShadowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  const _HoverShadowButton({required this.label, this.onTap});

  @override
  State<_HoverShadowButton> createState() => _HoverShadowButtonState();
}

class _HoverShadowButtonState extends State<_HoverShadowButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.primaryDark
                : AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _isPressed ? 0.4 : _isHovered ? 0.3 : 0.0,
                ),
                blurRadius: _isPressed ? 8 : _isHovered ? 16 : 0,
                offset: Offset(0, _isPressed ? 2 : _isHovered ? 6 : 0),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
