import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/page_skeletons.dart';
import '../landing/screens/landing_screen.dart';
import '../menu/screens/menu_screen.dart';
import '../order/screens/order_history_screen.dart';
import '../profile/screens/profile_screen.dart';

/// ============================================================
/// MainNavigation — Wrapper utama dengan Bottom Navigation Bar.
/// ============================================================
///
/// Widget ini menjadi "shell" utama setelah user login/masuk.
/// Menggunakan [IndexedStack] agar state tiap tab tidak hilang
/// saat berpindah tab.
///
/// **Loading Skeleton:**
/// Saat pertama kali load, menampilkan shimmer skeleton selama
/// 1.5 detik (simulate data fetching), lalu transisi smooth
/// ke konten asli menggunakan [AnimatedSwitcher].
///
/// **Tab yang tersedia:**
/// - Index 0: Home    → [LandingScreen]
/// - Index 1: Menu    → [MenuScreen]
/// - Index 2: Orders  → [OrderHistoryScreen]
/// - Index 3: Profile → [ProfileScreen]
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  /// Index tab yang sedang aktif (default: 0 = Home).
  int _currentIndex = 0;

  /// Loading state per tab — skeleton ditampilkan saat true.
  /// Setiap tab memiliki loading state independen.
  final List<bool> _isLoading = [true, true, true, true];

  /// Daftar halaman untuk setiap tab.
  final List<Widget> _pages = const [
    LandingScreen(),
    MenuScreen(),
    OrderHistoryScreen(),
    ProfileScreen(),
  ];

  /// Daftar skeleton untuk setiap tab.
  final List<Widget> _skeletons = const [
    LandingSkeleton(),
    MenuSkeleton(),
    OrderHistorySkeleton(),
    ProfileSkeleton(),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate initial data loading untuk semua tab.
    // Tab 0 (Home) load langsung, tab lain load saat pertama diklik.
    _loadTab(0);
  }

  /// Simulate loading data untuk tab tertentu.
  /// TODO: Ganti dengan fetch data asli dari API.
  Future<void> _loadTab(int index) async {
    if (!_isLoading[index]) return; // Already loaded

    // Simulate network delay (800ms - 1500ms random feel)
    await Future.delayed(Duration(milliseconds: 800 + (index * 200)));

    if (mounted) {
      setState(() => _isLoading[index] = false);
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    // Trigger loading jika tab belum pernah di-load
    if (_isLoading[index]) {
      _loadTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── BODY ──────────────────────────────────────────────
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(4, (i) {
          return _TabPage(
            isLoading: _isLoading[i],
            skeleton: _skeletons[i],
            page: _pages[i],
          );
        }),
      ),

      // ─── BOTTOM NAVIGATION BAR ────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.restaurant_menu_outlined,
                  activeIcon: Icons.restaurant_menu,
                  label: 'Menu',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Orders',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ─── NAV ITEM BUILDER ───────────────────────────────────────
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── TAB PAGE WRAPPER ──────────────────────────────────────
/// Menampilkan skeleton saat loading, fade ke konten saat selesai.
class _TabPage extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget page;

  const _TabPage({
    required this.isLoading,
    required this.skeleton,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: isLoading,
      skeleton: skeleton,
      child: page,
    );
  }
}
