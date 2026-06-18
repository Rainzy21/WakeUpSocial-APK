import 'app_logger.dart';
import 'crash_reporter.dart';

/// Lightweight in-app metrics/events for monitoring critical paths.
class AppMetrics {
  static void recordSuccess(
    String operation, {
    required int durationMs,
    Map<String, Object?> tags = const {},
  }) {
    AppLogger.info(
      'operation.success',
      context: {'operation': operation, 'duration_ms': durationMs, ...tags},
    );

    if (durationMs > 5000) {
      CrashReporter.captureMessage(
        'Slow operation: $operation (${durationMs}ms)',
        level: 'warning',
        context: tags,
      );
    }
  }

  static void recordFailure(
    String operation, {
    required Object error,
    Map<String, Object?> tags = const {},
  }) {
    AppLogger.error(
      'operation.failure',
      error: error,
      context: {'operation': operation, ...tags},
    );

    CrashReporter.captureMessage(
      'Operation failed: $operation',
      level: 'error',
      context: {'error': error.toString(), ...tags},
    );
  }

  static void recordEvent(String name, {Map<String, Object?> tags = const {}}) {
    AppLogger.info('event', context: {'event': name, ...tags});
  }
}
