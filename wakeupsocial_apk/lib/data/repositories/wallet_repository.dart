import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getWallet() async {
    final result = await _supabase.rpc('get_wallet');
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required int subtotal,
  }) async {
    final result = await _supabase.rpc(
      'validate_coupon',
      params: {'p_code': code, 'p_subtotal': subtotal},
    );
    return Map<String, dynamic>.from(result as Map);
  }
}
