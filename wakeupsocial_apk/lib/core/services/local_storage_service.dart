import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists cart and table session across process death.
class LocalStorageService {
  static const _cartKey = 'current_cart';
  static const _sessionIdKey = 'table_session_id';
  static const _tableIdKey = 'table_id';
  static const _tableNumberKey = 'table_number';
  static const _menuSyncedAtKey = 'menu_synced_at';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveCart(List<Map<String, dynamic>> items) async {
    final prefs = await _getPrefs;
    await prefs.setString(_cartKey, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> loadCart() async {
    final prefs = await _getPrefs;
    final raw = prefs.getString(_cartKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> clearCart() async {
    final prefs = await _getPrefs;
    await prefs.remove(_cartKey);
  }

  Future<void> saveSession({
    required String sessionId,
    required String tableId,
    required int tableNumber,
  }) async {
    final prefs = await _getPrefs;
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setString(_tableIdKey, tableId);
    await prefs.setInt(_tableNumberKey, tableNumber);
  }

  Future<({String? sessionId, String? tableId, int? tableNumber})> loadSession() async {
    final prefs = await _getPrefs;
    return (
      sessionId: prefs.getString(_sessionIdKey),
      tableId: prefs.getString(_tableIdKey),
      tableNumber: prefs.getInt(_tableNumberKey),
    );
  }

  Future<void> clearSession() async {
    final prefs = await _getPrefs;
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_tableIdKey);
    await prefs.remove(_tableNumberKey);
  }

  Future<void> setMenuSyncedAt(DateTime time) async {
    final prefs = await _getPrefs;
    await prefs.setString(_menuSyncedAtKey, time.toIso8601String());
  }

  Future<DateTime?> getMenuSyncedAt() async {
    final prefs = await _getPrefs;
    final raw = prefs.getString(_menuSyncedAtKey);
    return raw != null ? DateTime.tryParse(raw) : null;
  }
}
