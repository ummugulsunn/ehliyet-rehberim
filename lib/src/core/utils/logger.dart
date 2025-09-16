import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app
/// Provides consistent logging across the application
class Logger {
  static const String _tag = '[EhliyetRehberim]';

  /// Log debug information (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_tag DEBUG: $message');
    }
  }

  /// Log information messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_tag INFO: $message');
    }
  }

  /// Log warning messages
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_tag WARNING: $message');
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_tag ERROR: $message');
      if (error != null) {
        debugPrint('$_tag ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_tag STACK TRACE: $stackTrace');
      }
    }
  }

  /// Log Firebase Auth specific errors
  static void authError(String operation, Object error) {
    Logger.error('Auth $operation failed: $error');
  }

  /// Log purchase related errors
  static void purchaseError(String operation, Object error) {
    Logger.error('Purchase $operation failed: $error');
  }
} 