import 'package:flutter/foundation.dart';

/// Universal debug utility class for production-ready logging
class DebugUtils {
  /// Log messages only in debug mode
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$tagPrefix$message');
    }
  }

  /// Log API requests only in debug mode
  static void logAPI(String endpoint, {String? method, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      debugPrint('🔗 API ${method ?? 'REQUEST'}: $endpoint');
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  /// Log authentication events only in debug mode
  static void logAuth(String message) {
    if (kDebugMode) {
      debugPrint('🔐 AUTH: $message');
    }
  }

  /// Log ride provider events only in debug mode
  static void logRide(String message) {
    if (kDebugMode) {
      debugPrint('🚗 RIDE: $message');
    }
  }

  /// Log errors (always logged for debugging purposes)
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack: $stackTrace');
      }
    }
  }

  /// Disable all debug output (for production)
  static void disableDebugOutput() {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
}
