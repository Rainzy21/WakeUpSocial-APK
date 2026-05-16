import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/page_skeletons.dart';
import '../../../routes/navigation_helper.dart';

/// ============================================================
/// PrivacyPolicyScreen — Halaman Kebijakan Privasi.
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: "← Privacy & Policy"
/// - Card putih berisi teks kebijakan privasi lengkap
///   dalam bahasa Indonesia.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
          'Privacy & Policy',
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
                'Kebijakan Privasi Wake Up Social',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20),

              // ─── 1 ─────────────────────────────────────────
              Text(
                '1. Informasi yang Kami Kumpulkan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Kami mengumpulkan data pribadi yang Anda berikan secara sukarela, seperti nama lengkap dan alamat email saat Anda melakukan pendaftaran atau memperbarui profil melalui fitur Edit Profile.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 18),

              // ─── 2 ─────────────────────────────────────────
              Text(
                '2. Penggunaan Data Anda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Informasi yang dikumpulkan digunakan untuk mengelola akun Anda, memproses transaksi pada fitur Order History, serta meningkatkan kualitas layanan di cafe kami agar lebih personal.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 18),

              // ─── 3 ─────────────────────────────────────────
              Text(
                '3. Keamanan Informasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Kami berkomitmen untuk menjaga keamanan data Anda dengan menerapkan standar perlindungan pada sistem aplikasi guna mencegah akses yang tidak sah, penyalahgunaan, atau perubahan data pribadi tanpa izin.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 18),

              // ─── 4 ─────────────────────────────────────────
              Text(
                '4. Hak Akses dan Kontrol Pengguna',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Anda memiliki kendali penuh untuk melihat, memperbarui, atau mengubah informasi profil Anda kapan saja. Kami memastikan bahwa data yang Anda berikan tetap akurat sesuai dengan perubahan yang Anda lakukan.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 18),

              // ─── 5 ─────────────────────────────────────────
              Text(
                '5. Persetujuan Layanan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Dengan menggunakan aplikasi Wake Up Social, Anda dianggap menyetujui seluruh ketentuan dalam kebijakan privasi ini sebagai dasar kenyamanan dan keamanan bersama dalam bertransaksi.',
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
    );
  }
}
