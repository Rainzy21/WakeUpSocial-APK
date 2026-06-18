import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../observability/app_logger.dart';
import '../observability/app_metrics.dart';
import '../observability/crash_reporter.dart';

/// Executes external calls with timeout, retry, and structured telemetry.
class ResilientCall {
  static const Duration defaultTimeout = Duration(seconds: 15);
  static const int defaultMaxRetries = 2;

  static Future<T> run<T>({
    required String operation,
    required Future<T> Function() action,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
    bool retryOnFailure = true,
    Map<String, Object?> tags = const {},
  }) async {
    final stopwatch = Stopwatch()..start();
    Object? lastError;
    StackTrace? lastStack;

    for (var attempt = 1; attempt <= maxRetries + 1; attempt++) {
      try {
        final result = await action().timeout(timeout);
        stopwatch.stop();
        AppMetrics.recordSuccess(
          operation,
          durationMs: stopwatch.elapsedMilliseconds,
          tags: {...tags, 'attempt': attempt},
        );
        return result;
      } on TimeoutException catch (e, st) {
        lastError = e;
        lastStack = st;
        AppLogger.warn(
          'operation.timeout',
          context: {
            'operation': operation,
            'attempt': attempt,
            'timeout_ms': timeout.inMilliseconds,
          },
        );
      } catch (e, st) {
        lastError = e;
        lastStack = st;
        if (!retryOnFailure || attempt > maxRetries || !_isRetryable(e)) {
          break;
        }
        AppLogger.warn(
          'operation.retry',
          context: {
            'operation': operation,
            'attempt': attempt,
            'error': e.toString(),
          },
        );
        await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
      }
    }

    stopwatch.stop();
    AppMetrics.recordFailure(
      operation,
      error: lastError ?? StateError('Unknown failure'),
      tags: tags,
    );
    await CrashReporter.captureException(
      lastError ?? StateError('Unknown failure'),
      stackTrace: lastStack,
      context: {'operation': operation, ...tags},
    );
    Error.throwWithStackTrace(lastError!, lastStack ?? StackTrace.current);
  }

  static bool _isRetryable(Object error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is PostgrestException) {
      final code = error.code;
      return code == null ||
          code.startsWith('5') ||
          code == 'PGRST001' ||
          code == 'PGRST003';
    }
    if (error is AuthRetryableFetchException) return true;
    if (error is StorageException) {
      final status = error.statusCode;
      return status == null || status >= 500;
    }
    final message = error.toString().toLowerCase();
    return message.contains('connection') ||
        message.contains('network') ||
        message.contains('timeout');
  }
}
