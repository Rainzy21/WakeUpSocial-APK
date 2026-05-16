import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// HelpCenterScreen — Halaman Pusat Bantuan & FAQ.
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← Help Center / FAQ"
/// - Card putih berisi FAQ dengan 5 pertanyaan umum
/// - Bottom section: "Masih bingung? Hubungi kami"
///   dengan tombol Email (outlined) + WhatsApp (filled)
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
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
          'Help Center / FAQ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── FAQ CONTENT ───────────────────────────────────
          Expanded(
            child: ShimmerLoading(
              isLoading: _isLoading,
              skeleton: const ContentPageSkeleton(),
              child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pusat Bantuan (FAQ) Wake Up Social',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20),

                    // ─── 1 ─────────────────────────────────────
                    Text(
                      '1. Cara Melakukan Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Setelah melakukan pemesanan di aplikasi, silakan menuju ke meja kasir. Status pesanan Anda akan otomatis berubah dari Unpaid menjadi Accepted setelah pembayaran dikonfirmasi oleh staf kami.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 18),

                    // ─── 2 ─────────────────────────────────────
                    Text(
                      '2. Memantau Pesanan Aktif',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Untuk melihat pesanan yang sedang diproses, Anda dapat menekan ikon pesanan pada Navigation Bar di bagian bawah layar utama.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 18),

                    // ─── 3 ─────────────────────────────────────
                    Text(
                      '3. Melihat Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Daftar pesanan yang telah selesai di masa lalu dapat Anda temukan pada menu Order History yang terletak di dalam halaman Profil.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 18),

                    // ─── 4 ─────────────────────────────────────
                    Text(
                      '4. Perubahan Informasi Akun',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Anda dapat memperbarui data diri seperti nama dan email kapan saja melalui fitur Edit Profile agar informasi pada struk digital tetap akurat.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 18),

                    // ─── 5 ─────────────────────────────────────
                    Text(
                      '5. Bantuan Kendala Teknis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Jika status pesanan tidak berubah setelah pembayaran atau terdapat kendala lain, silakan tunjukkan layar aplikasi Anda kepada staf Wake Up Social untuk bantuan langsung.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),

          // ─── BOTTOM CTA: Email + WhatsApp ──────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Masih bingung?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Hubungi kami',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Email button (outlined)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Open email client
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // WhatsApp button (filled)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Open WhatsApp deep link
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
