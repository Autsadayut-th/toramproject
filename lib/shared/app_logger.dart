import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: kDebugMode,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void info(String message, {Object? data}) {
    _logger.i(_join(message, data));
  }

  static void warning(String message, {Object? data}) {
    _logger.w(_join(message, data));
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    final String content = _join(message, data);
    _logger.e(content, error: error, stackTrace: stackTrace);
    developer.log(
      content,
      name: 'ToramOnline',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static String _join(String message, Object? data) {
    if (data == null) {
      return message;
    }
    return '$message | data: $data';
  }
}
