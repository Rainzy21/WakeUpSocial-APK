import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/resilient_call.dart';

class SessionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> resolveTableByQr(String qrCode) {
    return ResilientCall.run(
      operation: 'session.resolve_table_by_qr',
      action: () async {
        final result = await _supabase.rpc(
          'resolve_table_by_qr',
          params: {'p_qr_code': qrCode},
        );
        return Map<String, dynamic>.from(result as Map);
      },
    );
  }

  Future<Map<String, dynamic>> createSession(String tableId) {
    return ResilientCall.run(
      operation: 'session.create',
      tags: {'table_id': tableId},
      action: () async {
        final result = await _supabase.rpc(
          'create_session',
          params: {'p_table_id': tableId},
        );
        return Map<String, dynamic>.from(result as Map);
      },
    );
  }

  Future<String> getTableIdByNumber(int tableNumber) {
    return ResilientCall.run(
      operation: 'session.get_table_by_number',
      tags: {'table_number': tableNumber},
      action: () async {
        final tables = await _supabase
            .from('restaurant_tables')
            .select('id')
            .eq('table_number', tableNumber)
            .limit(1);

        if (tables.isEmpty) {
          throw Exception(
            'Meja $tableNumber tidak terdaftar di sistem. Coba meja 1-5.',
          );
        }
        return tables.first['id'] as String;
      },
    );
  }
}
