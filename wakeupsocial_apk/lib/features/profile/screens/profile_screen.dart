import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/user_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

/// ============================================================
/// ProfileScreen — Halaman profil user (tab Profile).
/// ============================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _profile;
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Optional: Show error message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.coffee, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Wake Up Social',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── PROFILE CARD ─────────────────────────────────
                  ProfileHeader(
                    name: _profile?.name ?? 'Unknown User',
                    email: _profile?.email ?? 'No email',
                    onEditTap: () async {
                      // Jika user edit profil, kita refresh setelah kembali
                      await Navigator.pushNamed(context, AppRoutes.editProfile);
                      _fetchProfile();
                    },
                  ),
                  const SizedBox(height: 24),

                  // ─── ACTIVITY SECTION ─────────────────────────────
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Activity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.access_time,
                          label: 'Order History',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.shield_outlined,
                          label: 'Privacy & Policy',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── GENERAL SETTINGS SECTION ─────────────────────
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'General Settings',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.help_outline,
                          label: 'Help center / FAQ',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.headset_mic_outlined,
                          label: 'Contact Us',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          label: 'Logout',
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Dialog konfirmasi logout sesuai desain mockup.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Log Out dari Akun?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah Anda yakin ingin keluar dari aplikasi Wake Up Social?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Log out button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Tutup dialog
                      Navigator.pop(ctx);
                      // Logout dari Supabase
                      await AuthRepository().signOut();
                      // Pindah ke halaman Login (dan hapus stack navigasi sebelumnya)
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          AppRoutes.login, 
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Log out',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
