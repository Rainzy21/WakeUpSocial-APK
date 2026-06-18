import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app_logger.dart';

/// Optional crash reporting via Sentry when [SENTRY_DSN] is configured.
class CrashReporter {
  static bool _initialized = false;
  static bool get isEnabled => _initialized;

  static Future<void> init() async {
    const dsn = String.fromEnvironment('SENTRY_DSN');

    if (dsn.isEmpty) {
      _installFallbackHandlers();
      AppLogger.info(
        'crash_reporter.disabled',
        context: {'reason': 'SENTRY_DSN not set'},
      );
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.tracesSampleRate = 0.2;
      options.environment = kReleaseMode ? 'production' : 'development';
    });

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Sentry.captureException(details.exception, stackTrace: details.stack);
      AppLogger.error(
        'flutter.framework_error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      AppLogger.error('platform.async_error', error: error, stackTrace: stack);
      return true;
    };

    _initialized = true;
    AppLogger.info('crash_reporter.enabled');
  }

  static void _installFallbackHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'flutter.framework_error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('platform.async_error', error: error, stackTrace: stack);
      return true;
    };
  }

  static Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) async {
    AppLogger.error(
      'crash.capture',
      error: error,
      stackTrace: stackTrace,
      context: context,
    );

    if (!_initialized) return;

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        for (final entry in context.entries) {
          scope.setTag(entry.key, entry.value.toString());
        }
      },
    );
  }

  static Future<void> captureMessage(
    String message, {
    String level = 'info',
    Map<String, Object?> context = const {},
  }) async {
    AppLogger.info(message, context: context);

    if (!_initialized) return;

    final sentryLevel = switch (level) {
      'error' => SentryLevel.error,
      'warning' => SentryLevel.warning,
      _ => SentryLevel.info,
    };

    await Sentry.captureMessage(
      message,
      level: sentryLevel,
      withScope: (scope) {
        for (final entry in context.entries) {
          scope.setTag(entry.key, entry.value.toString());
        }
      },
    );
  }
}

/// Catches uncaught async errors outside Flutter framework handlers.
Future<void> runGuarded(Future<void> Function() body) async {
  await runZonedGuarded(() async => body(), (error, stack) async {
    await CrashReporter.captureException(error, stackTrace: stack);
  });
}
