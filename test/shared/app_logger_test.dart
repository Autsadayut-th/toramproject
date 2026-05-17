import 'package:flutter_test/flutter_test.dart';
import 'package:toramonline/shared/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('should log info level', () {
      expect(() => AppLogger.info('Test info message'), returnsNormally);
    });

    test('should log warning level', () {
      expect(() => AppLogger.warning('Test warning message'), returnsNormally);
    });

    test('should log error level', () {
      expect(
        () => AppLogger.error(
          'Test error message',
          error: Exception('Test exception'),
        ),
        returnsNormally,
      );
    });

    test('should log error with stack trace', () {
      final stackTrace = StackTrace.current;
      expect(
        () => AppLogger.error(
          'Test error with stack trace',
          error: Exception('Test'),
          stackTrace: stackTrace,
        ),
        returnsNormally,
      );
    });

    test('should handle null error gracefully', () {
      expect(() => AppLogger.error('Message without error'), returnsNormally);
    });

    test('should handle long messages', () {
      final longMessage = 'A' * 1000;
      expect(() => AppLogger.info(longMessage), returnsNormally);
    });
  });
}
