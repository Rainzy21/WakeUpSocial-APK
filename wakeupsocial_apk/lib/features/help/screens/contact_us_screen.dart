import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// ContactUsScreen — Halaman kontak kami.
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← Contact Us"
/// - Customer Support section (Phone, Email)
/// - Social Media section (Instagram, Twitter/X, Facebook)
///
/// Setiap item memiliki efek shadow saat di-hover dan di-press.
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
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
          'Contact Us',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ShimmerLoading(
        isLoading: _isLoading,
        skeleton: const ContentPageSkeleton(),
        child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ─── CUSTOMER SUPPORT ────────────────────────────
            _ShadowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Costumer Support',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    label: 'Contact Number',
                    value: '+(62) 8123456789',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _ContactItem(
                    icon: Icons.mail_outline,
                    label: 'Email Address',
                    value: 'Help@gmail.com',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── SOCIAL MEDIA ────────────────────────────────
            _ShadowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Social Media',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  _ContactItem(
                    icon: Icons.camera_alt_outlined,
                    label: 'Instagram',
                    value: 'WakeUp Social',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _ContactItem(
                    icon: Icons.close,
                    label: 'Twitter / X',
                    value: 'WakeUP Social',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _ContactItem(
                    icon: Icons.facebook_outlined,
                    label: 'Facebook',
                    value: 'WakeUp Social',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// ─── CONTACT ITEM ROW ──────────────────────────────────────
/// Baris item kontak: icon lingkaran | label + value.
/// Memiliki efek shadow saat hover dan press.
class _ContactItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.surface
                : _isHovered
                    ? Colors.grey.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isHovered || _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.04),
                      blurRadius: _isPressed ? 6 : 10,
                      offset: Offset(0, _isPressed ? 1 : 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Icon lingkaran
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 14),

              // Label + value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── SHADOW CARD ───────────────────────────────────────────
/// Container card putih dengan border dan shadow halus.
class _ShadowCard extends StatelessWidget {
  final Widget child;
  const _ShadowCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
