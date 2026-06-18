import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/resilient_call.dart';

class WalletRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getWallet() {
    return ResilientCall.run(
      operation: 'wallet.get',
      action: () async {
        final result = await _supabase.rpc('get_wallet');
        return Map<String, dynamic>.from(result as Map);
      },
    );
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required int subtotal,
  }) {
    return ResilientCall.run(
      operation: 'wallet.validate_coupon',
      retryOnFailure: false,
      action: () async {
        final result = await _supabase.rpc(
          'validate_coupon',
          params: {'p_code': code, 'p_subtotal': subtotal},
        );
        return Map<String, dynamic>.from(result as Map);
      },
    );
  }
}
