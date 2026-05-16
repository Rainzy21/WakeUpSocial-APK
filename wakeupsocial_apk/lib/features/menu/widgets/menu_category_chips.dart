import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// MenuCategoryChips — Chip filter kategori utama menu.
/// ============================================================
///
/// Menampilkan chip horizontal untuk filter:
/// All Menu, Makanan, Minuman, Snack, Pastry.
///
/// Chip yang aktif ditandai dengan background gelap (accent)
/// dan teks putih.
///
/// **Interaksi:**
/// - Hover  → shadow muncul + sedikit highlight.
/// - Press  → shadow lebih dalam.
/// - Active → shadow tetap ada (drop shadow).
class MenuCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const MenuCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1 ? 8 : 0,
            ),
            child: _ChipItem(
              label: category,
              isSelected: isSelected,
              onTap: () => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}

/// ─── CHIP ITEM ──────────────────────────────────────────────
/// Individual chip dengan hover/press shadow effect.
class _ChipItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ChipItem> createState() => _ChipItemState();
}

class _ChipItemState extends State<_ChipItem> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accent
                : _isPressed
                    ? AppColors.surface
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accent
                  : _isHovered
                      ? AppColors.textSecondary
                      : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : Colors.black.withValues(
                        alpha: _isPressed ? 0.08 : _isHovered ? 0.06 : 0.03,
                      ),
                blurRadius: widget.isSelected
                    ? 8
                    : _isPressed ? 4 : _isHovered ? 10 : 4,
                offset: Offset(0, widget.isSelected
                    ? 3
                    : _isPressed ? 1 : _isHovered ? 4 : 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              color: widget.isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
