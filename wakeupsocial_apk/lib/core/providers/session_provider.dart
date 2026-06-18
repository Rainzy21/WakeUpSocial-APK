import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider(this._storage) {
    _load();
  }

  final LocalStorageService _storage;

  String? sessionId;
  String? tableId;
  int? tableNumber;

  bool get hasActiveSession => sessionId != null && tableId != null;

  Future<void> _load() async {
    final saved = await _storage.loadSession();
    sessionId = saved.sessionId;
    tableId = saved.tableId;
    tableNumber = saved.tableNumber;
    notifyListeners();
  }

  Future<void> setSession({
    required String sessionId,
    required String tableId,
    required int tableNumber,
  }) async {
    this.sessionId = sessionId;
    this.tableId = tableId;
    this.tableNumber = tableNumber;
    await _storage.saveSession(
      sessionId: sessionId,
      tableId: tableId,
      tableNumber: tableNumber,
    );
    notifyListeners();
  }

  Future<void> clear() async {
    sessionId = null;
    tableId = null;
    tableNumber = null;
    await _storage.clearSession();
    notifyListeners();
  }
}
