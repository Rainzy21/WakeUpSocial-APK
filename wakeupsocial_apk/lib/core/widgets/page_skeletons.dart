import 'package:flutter/material.dart';
import '../../core/widgets/shimmer_loading.dart';

/// ============================================================
/// Page Skeletons — Skeleton layout spesifik per halaman.
/// ============================================================
///
/// Setiap skeleton meniru layout konten asli agar transisi
/// dari loading ke konten terasa mulus dan natural.
///
/// File ini berisi semua skeleton dalam satu tempat agar
/// mudah di-maintain dan konsisten secara visual.

// ══════════════════════════════════════════════════════════════
// LANDING PAGE SKELETON
// ══════════════════════════════════════════════════════════════

/// Skeleton untuk LandingScreen.
/// Meniru: Hero banner, feature cards, best seller list, promo banner.
class LandingSkeleton extends StatelessWidget {
  const LandingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner skeleton
          const SkeletonBox(height: 280, borderRadius: 0),
          const SizedBox(height: 20),

          // Feature cards (2 side by side)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SkeletonBox(height: 180, borderRadius: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(height: 180, borderRadius: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Best Seller header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(width: 100, height: 16),
                SkeletonLine(width: 60, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Best Seller horizontal cards
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(4, (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 110, borderRadius: 12),
                      const SizedBox(height: 10),
                      SkeletonLine(width: 100, height: 12),
                      const SizedBox(height: 6),
                      SkeletonLine(width: 70, height: 10),
                    ],
                  ),
                ),
              )),
            ),
          ),
          const SizedBox(height: 20),

          // Promo banner skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonBox(height: 120, borderRadius: 16),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MENU PAGE SKELETON
// ══════════════════════════════════════════════════════════════

/// Skeleton untuk MenuScreen.
/// Meniru: Search bar, category chips, product grid.
class MenuSkeleton extends StatelessWidget {
  const MenuSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonBox(height: 44, borderRadius: 22),
          ),
          const SizedBox(height: 12),

          // Category chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(5, (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SkeletonBox(
                  width: 70 + (i * 5).toDouble(),
                  height: 36,
                  borderRadius: 20,
                ),
              )),
            ),
          ),
          const SizedBox(height: 16),

          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SkeletonBox(width: 3, height: 20, borderRadius: 2),
                const SizedBox(width: 8),
                SkeletonLine(width: 120, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Product grid (2 columns)
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
              itemCount: 6,
              itemBuilder: (_, __) => const _MenuCardSkeleton(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Skeleton untuk satu kartu produk menu.
class _MenuCardSkeleton extends StatelessWidget {
  const _MenuCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          AspectRatio(
            aspectRatio: 1.2,
            child: SkeletonBox(
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 80, height: 12),
                const SizedBox(height: 6),
                SkeletonLine(width: 100, height: 10),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLine(width: 60, height: 12),
                    SkeletonBox(width: 28, height: 28, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ORDER HISTORY SKELETON
// ══════════════════════════════════════════════════════════════

/// Skeleton untuk OrderHistoryScreen.
/// Meniru: List order cards.
class OrderHistorySkeleton extends StatelessWidget {
  const OrderHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Bag icon skeleton
            SkeletonBox(width: 42, height: 42, borderRadius: 10),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonLine(width: 90, height: 12),
                      const SizedBox(width: 8),
                      SkeletonLine(width: 60, height: 10),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SkeletonLine(width: 40, height: 10),
                      const SizedBox(width: 10),
                      SkeletonLine(width: 70, height: 10),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge
            SkeletonBox(width: 56, height: 24, borderRadius: 6),
            const SizedBox(width: 8),
            SkeletonBox(width: 18, height: 18, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PROFILE PAGE SKELETON
// ══════════════════════════════════════════════════════════════

/// Skeleton untuk ProfileScreen.
/// Meniru: Profile card, Activity section, General Settings section.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SkeletonCircle(size: 56),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 100, height: 14),
                    const SizedBox(height: 6),
                    SkeletonLine(width: 140, height: 11),
                  ],
                ),
                const Spacer(),
                SkeletonBox(width: 20, height: 20, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Activity label
          SkeletonLine(width: 60, height: 12),
          const SizedBox(height: 10),

          // Activity section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(2, (_) => _menuItemSkeleton()),
            ),
          ),
          const SizedBox(height: 24),

          // General Settings label
          SkeletonLine(width: 110, height: 12),
          const SizedBox(height: 10),

          // General Settings section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(3, (_) => _menuItemSkeleton()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, borderRadius: 10),
          const SizedBox(width: 14),
          Expanded(child: SkeletonLine(width: 120, height: 13)),
          SkeletonBox(width: 20, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PROFILE DETAIL / EDIT PROFILE SKELETON
// ══════════════════════════════════════════════════════════════

/// Skeleton untuk ProfileDetail / EditProfile.
/// Meniru: Avatar, form fields, button.
class ProfileFormSkeleton extends StatelessWidget {
  final int fieldCount;
  const ProfileFormSkeleton({super.key, this.fieldCount = 2});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Avatar
          const Center(child: SkeletonCircle(size: 96)),
          const SizedBox(height: 32),

          // Form fields
          ...List.generate(fieldCount, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 70, height: 11),
                const SizedBox(height: 8),
                SkeletonBox(height: 48, borderRadius: 28),
              ],
            ),
          )),
          const SizedBox(height: 12),

          // Button
          SkeletonBox(height: 48, borderRadius: 28),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ORDER DETAIL SKELETON
// ══════════════════════════════════════════════════════════════

/// Skeleton untuk OrderDetailScreen.
class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Order label + field
          SkeletonLine(width: 80, height: 11),
          const SizedBox(height: 8),
          SkeletonBox(height: 44, borderRadius: 10),
          const SizedBox(height: 16),

          // Order number label + field
          SkeletonLine(width: 90, height: 11),
          const SizedBox(height: 8),
          SkeletonBox(height: 44, borderRadius: 10),
          const SizedBox(height: 24),

          // Order summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 100, height: 13),
                const SizedBox(height: 16),
                ...List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonLine(width: 120, height: 11),
                      SkeletonLine(width: 70, height: 11),
                    ],
                  ),
                )),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLine(width: 40, height: 13),
                    SkeletonLine(width: 80, height: 13),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONTENT PAGE SKELETON (Privacy, FAQ, Contact Us)
// ══════════════════════════════════════════════════════════════

/// Skeleton generik untuk halaman konten teks (Privacy, FAQ).
class ContentPageSkeleton extends StatelessWidget {
  const ContentPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            SkeletonLine(width: 200, height: 14),
            const SizedBox(height: 20),

            // Sections
            ...List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 180, height: 12),
                  const SizedBox(height: 8),
                  SkeletonLine(width: double.infinity, height: 10),
                  const SizedBox(height: 4),
                  SkeletonLine(width: double.infinity, height: 10),
                  const SizedBox(height: 4),
                  SkeletonLine(width: 200, height: 10),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
