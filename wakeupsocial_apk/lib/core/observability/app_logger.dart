import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Structured application logger. Emits single-line JSON for easy parsing.
class AppLogger {
  static void debug(String message, {Map<String, Object?> context = const {}}) {
    _log('debug', message, context);
  }

  static void info(String message, {Map<String, Object?> context = const {}}) {
    _log('info', message, context);
  }

  static void warn(String message, {Map<String, Object?> context = const {}}) {
    _log('warn', message, context);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _log(
      'error',
      message,
      {
        ...context,
        if (error != null) 'error': error.toString(),
        if (stackTrace != null) 'stack': stackTrace.toString(),
      },
    );
  }

  static void _log(
    String level,
    String message,
    Map<String, Object?> context,
  ) {
    final payload = {
      'ts': DateTime.now().toUtc().toIso8601String(),
      'level': level,
      'message': message,
      if (context.isNotEmpty) 'context': context,
    };

    final line = jsonEncode(payload);
    if (kDebugMode || level == 'error' || level == 'warn') {
      debugPrint(line);
    }
  }
}
