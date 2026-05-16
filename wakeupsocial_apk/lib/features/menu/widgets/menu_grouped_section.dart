import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'menu_item_card.dart';

/// ============================================================
/// MenuGroupedSection — Section grup produk dengan headline.
/// ============================================================
///
/// Digunakan di halaman Menu ketika kategori "Minuman" dipilih.
/// Menampilkan:
/// - Headline sub-kategori (misal: "Espresso Based") dengan
///   garis aksen merah di kiri.
/// - Grid 2 kolom berisi [MenuItemCard].
///
/// Layout saat scroll "Minuman":
/// ```
/// |  Espresso Based
/// | [Espresso]   [Americano]
/// | [Long Black]
/// |
/// |  Milk Coffee
/// | [Flat White]  [Cappuccino]
/// | [Cafe Latte]
/// |
/// |  Signature
/// | [Wake Up Special]  [Social Fusion]
/// | ...
/// ```
///
/// Ini menggantikan sub-chip filter agar user bisa melihat
/// semua jenis minuman sekaligus tanpa perlu klik per kategori.
class MenuGroupedSection extends StatelessWidget {
  /// Judul headline (nama sub-kategori, misal "Espresso Based").
  final String title;

  /// Daftar item produk dalam grup ini.
  final List<Map<String, String>> items;

  /// Callback ketika kartu produk di-tap.
  final ValueChanged<Map<String, String>>? onItemTap;

  /// Callback ketika tombol "+" di-tap.
  final ValueChanged<Map<String, String>>? onAddToCart;

  const MenuGroupedSection({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADLINE ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Garis aksen merah vertikal
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── PRODUCT GRID ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return MenuItemCard(
                  name: item['name']!,
                  description: item['desc']!,
                  price: item['price']!,
                  onTap: () => onItemTap?.call(item),
                  onAddToCart: () => onAddToCart?.call(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
