import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// ProfileMenuItem — Item menu navigasi di halaman Profile.
/// ============================================================
///
/// Widget baris tunggal yang menampilkan:
/// - Ikon di sebelah kiri (dalam kotak rounded).
/// - Label teks di tengah.
/// - Panah chevron (>) di sebelah kanan.
///
/// **Interaksi:**
/// - Hover  → muncul shadow halus + background berubah sedikit.
/// - Press  → shadow lebih dalam + background lebih gelap.
/// - Normal → tanpa shadow.
class ProfileMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
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
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.surface
                : _isHovered
                    ? Colors.grey.withValues(alpha: 0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered || _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.04),
                      blurRadius: _isPressed ? 4 : 8,
                      offset: Offset(0, _isPressed ? 1 : 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // ─── IKON ──────────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),

              // ─── LABEL ─────────────────────────────────────
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // ─── CHEVRON ────────────────────────────────────
              Icon(
                Icons.chevron_right,
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
