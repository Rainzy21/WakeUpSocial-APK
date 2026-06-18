import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakeupsocial_apk/core/network/resilient_call.dart';

void main() {
  group('ResilientCall', () {
    test('returns result on first successful attempt', () async {
      final result = await ResilientCall.run(
        operation: 'test.success',
        action: () async => 42,
      );
      expect(result, 42);
    });

    test('retries on transient SocketException then succeeds', () async {
      var attempts = 0;
      final result = await ResilientCall.run(
        operation: 'test.retry',
        maxRetries: 2,
        action: () async {
          attempts++;
          if (attempts == 1) {
            throw const SocketException('connection reset');
          }
          return 'ok';
        },
      );

      expect(result, 'ok');
      expect(attempts, 2);
    });

    test('throws TimeoutException when action exceeds timeout', () async {
      await expectLater(
        ResilientCall.run(
          operation: 'test.timeout',
          timeout: const Duration(milliseconds: 50),
          maxRetries: 0,
          action: () async {
            await Future<void>.delayed(const Duration(milliseconds: 200));
            return true;
          },
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
