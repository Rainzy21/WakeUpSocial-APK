import 'package:supabase_flutter/supabase_flutter.dart';

class SessionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> resolveTableByQr(String qrCode) async {
    final result = await _supabase.rpc(
      'resolve_table_by_qr',
      params: {'p_qr_code': qrCode},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> createSession(String tableId) async {
    final result = await _supabase.rpc(
      'create_session',
      params: {'p_table_id': tableId},
    );
    return Map<String, dynamic>.from(result as Map);
  }
}
