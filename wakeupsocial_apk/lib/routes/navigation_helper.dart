import 'package:flutter/material.dart';
import 'app_routes.dart';

/// ============================================================
/// NavigationHelper — Helper terpusat untuk navigasi antar halaman.
/// ============================================================
///
/// Gunakan class ini untuk semua navigasi agar konsisten.
/// Dengan cara ini, jika route berubah, cukup update di sini saja.
///
/// **Penggunaan:**
/// ```dart
/// // Navigasi ke halaman menu
/// NavigationHelper.toMenu(context);
///
/// // Navigasi ke detail order
/// NavigationHelper.toOrderDetail(context, orderId: '1001');
/// ```
class NavigationHelper {
  NavigationHelper._();

  // ─── AUTH ────────────────────────────────────────────────────
  
  /// Navigasi ke halaman Login (hapus semua history).
  static void toLogin(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);

  /// Navigasi ke halaman Sign Up.
  static void toSignUp(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.signUp);

  // ─── MAIN ────────────────────────────────────────────────────

  /// Navigasi ke halaman utama (Bottom Nav Shell).
  /// Hapus semua history sebelumnya (untuk setelah login).
  static void toHome(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);

  // ─── MENU ────────────────────────────────────────────────────

  /// Navigasi ke halaman Menu lengkap (push ke stack).
  static void toMenu(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.menu);

  // ─── CART ────────────────────────────────────────────────────

  /// Navigasi ke halaman Keranjang.
  static void toCart(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.cart);

  // ─── ORDER ───────────────────────────────────────────────────

  /// Navigasi ke halaman konfirmasi/summary Order.
  static void toOrder(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.order);

  /// Navigasi ke halaman Detail Order berdasarkan [orderId].
  static void toOrderDetail(BuildContext context, {required String orderId}) =>
      Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: orderId);

  /// Navigasi ke halaman Riwayat Pesanan.
  static void toOrderHistory(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.orderHistory);

  /// Navigasi ke halaman Order Tracking berdasarkan [orderId].
  static void toOrderTracking(BuildContext context, {required String orderId}) =>
      Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: orderId);

  // ─── PROFILE ─────────────────────────────────────────────────

  /// Navigasi ke halaman Profile Detail (lihat data profil).
  static void toProfileDetail(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.profileDetail);

  /// Navigasi ke halaman Edit Profile.
  static void toEditProfile(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.editProfile);

  // ─── HELP & LEGAL ────────────────────────────────────────────

  /// Navigasi ke halaman Privacy & Policy.
  static void toPrivacyPolicy(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.privacyPolicy);

  /// Navigasi ke halaman Help Center & FAQ.
  static void toHelpCenter(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.helpCenter);

  /// Navigasi ke halaman Contact Us.
  static void toContactUs(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.contactUs);

  // ─── GENERAL ─────────────────────────────────────────────────

  /// Kembali ke halaman sebelumnya.
  static void back(BuildContext context) => Navigator.pop(context);

  /// Kembali ke halaman sebelumnya dengan membawa [result].
  static void backWithResult(BuildContext context, dynamic result) =>
      Navigator.pop(context, result);
}
