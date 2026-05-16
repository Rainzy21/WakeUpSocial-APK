import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// ProfileHeader — Card profil user di halaman Profile.
/// ============================================================
///
/// Sesuai mockup desain, menampilkan:
/// - Avatar lingkaran di kiri
/// - Nama + email di tengah
/// - Ikon edit di kanan
///
/// Semua dalam satu card (Container putih rounded) dengan
/// drop shadow (timbul) + hover/press effect.
class ProfileHeader extends StatefulWidget {
  final String name;
  final String email;
  final VoidCallback? onEditTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.onEditTap,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
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
          widget.onEditTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isPressed ? 0.10 : _isHovered ? 0.08 : 0.05,
                ),
                blurRadius: _isPressed ? 6 : _isHovered ? 16 : 8,
                offset: Offset(0, _isPressed ? 1 : _isHovered ? 6 : 3),
                spreadRadius: _isPressed ? 0 : _isHovered ? 1 : 0,
              ),
            ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.98))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Row(
            children: [
              // ─── AVATAR ──────────────────────────────────────
              // TODO: Ganti dengan gambar profil user dari network/assets
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surface,
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),

              // ─── NAMA & EMAIL ────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── EDIT ICON ───────────────────────────────────
              if (widget.onEditTap != null)
                Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
