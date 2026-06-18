import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/navigation_helper.dart';
import '../widgets/menu_category_chips.dart';
import '../widgets/menu_promo_carousel.dart';
import '../widgets/menu_item_card.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/menu_category_model.dart';
import '../../../data/repositories/menu_repository.dart';

/// ============================================================
/// MenuScreen — Halaman daftar menu produk terhubung ke Supabase.
/// ============================================================
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuRepository _menuRepository = MenuRepository();
  bool _isLoading = true;

  List<MenuCategoryModel> _categories = [];
  List<MenuItemModel> _menuItems = [];

  String _selectedCategory = 'All Menu';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final categories = await _menuRepository.getCategories();
      final items = await _menuRepository.getMenuItems();

      if (mounted) {
        setState(() {
          _categories = categories;
          _menuItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat menu: $e')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> get _mainCategories {
    return ['All Menu', ..._categories.map((c) => c.name)];
  }

  /// ─── FILTER ────────────────────────────────────────────────
  List<MenuItemModel> get _filteredItems {
    return _menuItems.where((item) {
      // Filter kategori utama
      if (_selectedCategory != 'All Menu') {
        if (item.category?.name != _selectedCategory) return false;
      }

      // Filter search
      if (_searchQuery.isNotEmpty) {
        final name = item.name.toLowerCase();
        final desc = (item.description ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !desc.contains(query)) return false;
      }

      return true;
    }).toList();
  }

  void _addToCart(MenuItemModel item) {
    context.read<CartProvider>().addMenuItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString().split('').reversed.join('');
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildSearchBar(),
                  const SizedBox(height: 12),

                  // ─── KATEGORI UTAMA ──────────────────────────────
                  if (_categories.isNotEmpty) ...[
                    MenuCategoryChips(
                      categories: _mainCategories,
                      selectedCategory: _selectedCategory,
                      onSelected: (c) => setState(() => _selectedCategory = c),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── KONTEN MENU ─────────────────────────────────
                  _buildFlatGrid(),

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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => NavigationHelper.toCart(context),
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Keranjang',
            ),
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                final count = cart.totalItemCount;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
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

  /// ─── FLAT GRID ────────────────────────────
  Widget _buildFlatGrid() {
    final filtered = _filteredItems;

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
                name: item.name,
                description: item.description ?? '',
                price: _formatPrice(item.price),
                imageUrl: item.imageUrl,
                onTap: () {},
                onAddToCart: () => _addToCart(item),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ─── SECTION HEADER ───────────────────────────────────────
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
