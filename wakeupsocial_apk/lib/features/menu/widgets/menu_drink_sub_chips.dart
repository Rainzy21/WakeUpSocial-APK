import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ============================================================
/// MenuDrinkSubChips — Sub-kategori chip untuk filter minuman.
/// ============================================================
///
/// Muncul hanya ketika kategori utama "Minuman" dipilih.
///
/// Sub-kategori yang tersedia:
/// Semua, Espresso Based, Milk Coffee, Signature, Mocktail, Non Coffee, Tea.
///
/// Tampil dengan style lebih kecil dan underline pada item aktif
/// agar secara visual berbeda dari chip kategori utama.
class MenuDrinkSubChips extends StatelessWidget {
  final List<String> subCategories;
  final String selectedSub;
  final ValueChanged<String> onSelected;

  const MenuDrinkSubChips({
    super.key,
    required this.subCategories,
    required this.selectedSub,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          final sub = subCategories[index];
          final isSelected = sub == selectedSub;

          return Padding(
            padding: EdgeInsets.only(
              right: index < subCategories.length - 1 ? 16 : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(sub),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Underline indicator untuk item aktif
                  Container(
                    height: 2,
                    width: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
