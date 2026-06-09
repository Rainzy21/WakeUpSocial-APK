import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/profile_repository.dart';

/// ============================================================
/// EditProfileScreen — Halaman edit profil user.
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← Edit Profile" + search icon
/// - Avatar dengan badge icon kecil
/// - Form fields: first Name, Last Name, Email
///   (masing-masing dengan icon suffix di kanan)
/// - Tombol "Confirm edit" (merah penuh)
///
/// TODO: Hubungkan ke backend untuk menyimpan perubahan.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = true;
  UserModel? _profile;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ProfileRepository().getMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          if (profile != null) {
            _emailController.text = profile.email;
            final nameParts = profile.name.split(' ');
            _firstNameController.text = nameParts.first;
            if (nameParts.length > 1) {
              _lastNameController.text = nameParts.sublist(1).join(' ');
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
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
          'Edit Profile',
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
        skeleton: const ProfileFormSkeleton(fieldCount: 3),
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

            // ─── FIRST NAME ──────────────────────────────────
            const Text(
              'first Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _firstNameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // ─── LAST NAME ───────────────────────────────────
            const Text(
              'Last Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _lastNameController,
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
            _buildInputField(
              controller: _emailController,
              icon: Icons.mail_outline,
              readOnly: true,
            ),
            const SizedBox(height: 32),

            // ─── CONFIRM EDIT BUTTON ─────────────────────────
            _HoverShadowButton(
              label: 'Confirm edit',
              onTap: () async {
                if (_profile == null) return;
                setState(() => _isLoading = true);
                try {
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
                  
                  await ProfileRepository().updateProfile(name: fullName);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully')),
                    );
                    NavigationHelper.back(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update profile: $e')),
                    );
                    setState(() => _isLoading = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Input field dengan rounded border dan icon suffix.
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        color: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: 14,
          color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
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
