import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/navigation_helper.dart';
import '../widgets/menu_category_chips.dart';
import '../widgets/menu_promo_carousel.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_grouped_section.dart';

/// ============================================================
/// MenuScreen — Halaman daftar menu produk (Tab 1 di Bottom Nav).
/// ============================================================
///
/// Layout:
/// 1. Search bar
/// 2. [MenuCategoryChips]      — All Menu, Makanan, Minuman, Snack, Pastry
/// 3. [MenuPromoCarousel]      — Banner promo (parallax)
/// 4. Konten menu:
///    - Jika **Minuman** dipilih → [MenuGroupedSection] per sub-kategori
///      (Espresso Based, Milk Coffee, Signature, Mocktail, Non Coffee, Tea)
///    - Jika kategori lain → grid biasa
///
/// Approach ini menghindari redundansi sub-chip, user bisa scroll
/// dan melihat semua jenis minuman sekaligus, terorganisir rapi.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All Menu';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final List<String> _mainCategories = [
    'All Menu',
    'Makanan',
    'Minuman',
    'Snack',
    'Pastry',
  ];

  /// Urutan sub-kategori minuman (untuk grouped sections).
  final List<String> _drinkGroups = [
    'Espresso Based',
    'Milk Coffee',
    'Signature',
    'Mocktail',
    'Non Coffee',
    'Tea',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ─── FILTER ────────────────────────────────────────────────
  List<Map<String, String>> _getFilteredItems({String? subCategory}) {
    return _allMenuItems.where((item) {
      // Filter kategori utama
      if (_selectedCategory != 'All Menu') {
        if (item['category'] != _selectedCategory) return false;
      }

      // Filter sub-kategori (untuk grouped section Minuman)
      if (subCategory != null) {
        if (item['subCategory'] != subCategory) return false;
      }

      // Filter search
      if (_searchQuery.isNotEmpty) {
        final name = item['name']!.toLowerCase();
        final desc = item['desc']!.toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !desc.contains(query)) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 12),

            // ─── KATEGORI UTAMA ──────────────────────────────
            MenuCategoryChips(
              categories: _mainCategories,
              selectedCategory: _selectedCategory,
              onSelected: (c) => setState(() => _selectedCategory = c),
            ),
            const SizedBox(height: 16),

            // ─── KONTEN MENU ─────────────────────────────────
            _buildMenuContent(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD METHODS
  // ══════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: false,
      title: const Row(
        children: [
          Icon(Icons.coffee, color: AppColors.primary, size: 24),
          SizedBox(width: 8),
          Text(
            'Wake Up Social',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => NavigationHelper.toCart(context),
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.textPrimary,
          ),
          tooltip: 'Keranjang',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search for your favorite brew...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
          ],
        ),
      ),
    );
  }

  /// ─── KONTEN UTAMA ─────────────────────────────────────────
  /// Jika "Minuman" dipilih → tampilkan grouped sections.
  /// Jika kategori lain   → tampilkan grid biasa.
  Widget _buildMenuContent() {
    if (_selectedCategory == 'Minuman') {
      return _buildDrinkGroupedSections();
    } else {
      return _buildFlatGrid();
    }
  }

  /// ─── GROUPED SECTIONS (Minuman) ───────────────────────────
  /// Setiap sub-kategori minuman ditampilkan sebagai section
  /// dengan headline + grid produk di bawahnya.
  Widget _buildDrinkGroupedSections() {
    final sections = <Widget>[];

    for (final group in _drinkGroups) {
      final items = _getFilteredItems(subCategory: group);
      if (items.isEmpty) continue; // Skip jika kosong (misal karena search)

      sections.add(
        MenuGroupedSection(
          title: group,
          items: items,
          onItemTap: (_) {
            // TODO: Navigasi ke detail produk
          },
          onAddToCart: (_) => NavigationHelper.toCart(context),
        ),
      );
    }

    if (sections.isEmpty) {
      return _buildEmptyState();
    }

    return Column(children: sections);
  }

  /// ─── FLAT GRID (kategori lain) ────────────────────────────
  Widget _buildFlatGrid() {
    final filtered = _getFilteredItems();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionHeader(
            _selectedCategory == 'All Menu' ? 'Main Menu' : _selectedCategory,
          ),
        ),
        const SizedBox(height: 12),

        // Grid
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
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return MenuItemCard(
                name: item['name']!,
                description: item['desc']!,
                price: item['price']!,
                imageUrl: item['imageUrl'],
                onTap: () {},
                onAddToCart: () => NavigationHelper.toCart(context),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ─── SECTION HEADER ───────────────────────────────────────
  /// Garis merah vertikal + teks judul (sesuai desain).
  static Widget _buildSectionHeader(String title) {
    return Row(
      children: [
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Menu tidak ditemukan',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PARALLAX PROMO CAROUSEL
// ══════════════════════════════════════════════════════════════
class _ParallaxPromoCarousel extends StatelessWidget {
  final double scrollOffset;
  const _ParallaxPromoCarousel({required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    final parallaxOffset = scrollOffset * 0.3;
    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, parallaxOffset * 0.15),
        child: const MenuPromoCarousel(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DATA MENU — GANTI imageUrl DENGAN URL GAMBAR MENU ANDA
// ══════════════════════════════════════════════════════════════
//
// Cara menambahkan / mengedit menu:
//   1. Copy template di bawah ini:
//
//   {'name': 'Nama Menu', 'desc': 'Deskripsi singkat', 'price': 'Rp XX.000', 'imageUrl': 'https://url-gambar-anda.com/gambar.png', 'category': 'Minuman', 'subCategory': 'Espresso Based'},
//
//   2. Ganti masing-masing value:
//      - name       → Nama produk
//      - desc       → Deskripsi singkat
//      - price      → Harga (format: "Rp XX.000")
//      - imageUrl   → URL gambar menu (kosongkan '' jika belum ada)
//      - category   → Kategori utama: 'Minuman', 'Makanan', 'Snack', 'Pastry'
//      - subCategory→ Sub-kategori (khusus Minuman): 'Espresso Based', 'Milk Coffee', 'Signature', 'Mocktail', 'Non Coffee', 'Tea'
//                     Untuk kategori lain, isi '' (kosong)
//
//   3. Tempel di bawah kategori yang sesuai.
//
// ══════════════════════════════════════════════════════════════
final List<Map<String, String>> _allMenuItems = [
  // ┌──────────────────────────────────────────────────────────┐
  // │  MINUMAN: Espresso Based                                 │
  // │  Ganti imageUrl dengan URL gambar menu Anda              │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Espresso',
    'desc': 'Pure double shot espresso',
    'price': 'Rp 18.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Espresso Based',
  },
  {
    'name': 'Americano',
    'desc': 'Espresso with hot water',
    'price': 'Rp 22.000',
    'imageUrl': 'assets/images/menu/Americano.jpg',
    'category': 'Minuman',
    'subCategory': 'Espresso Based',
  },
  {
    'name': 'Long Black',
    'desc': 'Double espresso poured over hot water',
    'price': 'Rp 23.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Espresso Based',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  MINUMAN: Milk Coffee                                    │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Flat White',
    'desc': 'Ristretto shots with silky steamed milk',
    'price': 'Rp 25.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Milk Coffee',
  },
  {
    'name': 'Cappuccino',
    'desc': 'Espresso, steamed milk, thick foam',
    'price': 'Rp 24.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Milk Coffee',
  },
  {
    'name': 'Cafe Latte',
    'desc': 'Smooth espresso with steamed milk',
    'price': 'Rp 25.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Milk Coffee',
  },
  {
    'name': 'Kopi Susu',
    'desc': 'Kopi susu segar khas WakeUp',
    'price': 'Rp 25.000',
    'imageUrl': 'assets/images/menu/Americano.jpg',
    'category': 'Minuman',
    'subCategory': 'Milk Coffee',
  },
  // ┌──────────────────────────────────────────────────────────┐
  // │  MINUMAN: Signature                                      │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Wake Up Special',
    'desc': 'Our signature house blend',
    'price': 'Rp 32.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Signature',
  },
  {
    'name': 'Social Fusion',
    'desc': 'Espresso, caramel, vanilla cream',
    'price': 'Rp 35.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Signature',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  MINUMAN: Mocktail                                       │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Berry Fizz',
    'desc': 'Mixed berry with sparkling soda',
    'price': 'Rp 28.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Mocktail',
  },
  {
    'name': 'Tropical Sunset',
    'desc': 'Mango, passion fruit, lychee',
    'price': 'Rp 30.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Mocktail',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  MINUMAN: Non Coffee                                     │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Matcha Latte',
    'desc': 'Japanese green tea latte',
    'price': 'Rp 26.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Non Coffee',
  },
  {
    'name': 'Chocolate',
    'desc': 'Rich Belgian chocolate',
    'price': 'Rp 25.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Non Coffee',
  },
  {
    'name': 'Vanilla Milkshake',
    'desc': 'Creamy vanilla ice blend',
    'price': 'Rp 27.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Non Coffee',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  MINUMAN: Tea                                            │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Earl Grey',
    'desc': 'Classic bergamot black tea',
    'price': 'Rp 20.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Tea',
  },
  {
    'name': 'Chamomile',
    'desc': 'Calming floral herbal tea',
    'price': 'Rp 22.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Tea',
  },
  {
    'name': 'Lemon Ginger Tea',
    'desc': 'Fresh lemon with warm ginger',
    'price': 'Rp 22.000',
    'imageUrl': '',
    'category': 'Minuman',
    'subCategory': 'Tea',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  MAKANAN (Main Course)                                   │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Nasi Goreng',
    'desc': 'Indonesian fried rice special',
    'price': 'Rp 35.000',
    'imageUrl': '',
    'category': 'Makanan',
    'subCategory': '',
  },
  {
    'name': 'Chicken Steak',
    'desc': 'Grilled chicken with mushroom sauce',
    'price': 'Rp 45.000',
    'imageUrl': '',
    'category': 'Makanan',
    'subCategory': '',
  },
  {
    'name': 'Aglio Olio',
    'desc': 'Spaghetti garlic, chili, olive oil',
    'price': 'Rp 38.000',
    'imageUrl': '',
    'category': 'Makanan',
    'subCategory': '',
  },
  {
    'name': 'Club Sandwich',
    'desc': 'Triple decker with fries',
    'price': 'Rp 40.000',
    'imageUrl': '',
    'category': 'Makanan',
    'subCategory': '',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  SNACK                                                   │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'French Fries',
    'desc': 'Crispy golden fries',
    'price': 'Rp 20.000',
    'imageUrl': '',
    'category': 'Snack',
    'subCategory': '',
  },
  {
    'name': 'Chicken Wings',
    'desc': 'Spicy buffalo wings (6 pcs)',
    'price': 'Rp 30.000',
    'imageUrl': '',
    'category': 'Snack',
    'subCategory': '',
  },
  {
    'name': 'Nachos',
    'desc': 'Tortilla chips with cheese dip',
    'price': 'Rp 28.000',
    'imageUrl': '',
    'category': 'Snack',
    'subCategory': '',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  PASTRY                                                  │
  // └──────────────────────────────────────────────────────────┘
  {
    'name': 'Croissant',
    'desc': 'Buttery French pastry',
    'price': 'Rp 22.000',
    'imageUrl': '',
    'category': 'Pastry',
    'subCategory': '',
  },
  {
    'name': 'Cinnamon Roll',
    'desc': 'Warm cinnamon with cream cheese',
    'price': 'Rp 25.000',
    'imageUrl': '',
    'category': 'Pastry',
    'subCategory': '',
  },
  {
    'name': 'Banana Bread',
    'desc': 'Moist banana cake slice',
    'price': 'Rp 20.000',
    'imageUrl': '',
    'category': 'Pastry',
    'subCategory': '',
  },

  // ┌──────────────────────────────────────────────────────────┐
  // │  TAMBAH MENU BARU DI SINI — Copy template berikut:      │
  // │                                                          │
  // │  {'name': 'Nama Menu',                                   │
  // │   'desc': 'Deskripsi singkat',                           │
  // │   'price': 'Rp XX.000',                                  │
  // │   'imageUrl': 'https://url-gambar.com/gambar.png',       │
  // │   'category': 'Minuman',                                 │
  // │   'subCategory': 'Espresso Based'},                      │
  // └──────────────────────────────────────────────────────────┘
];
