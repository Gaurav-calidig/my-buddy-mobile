import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized error handler
class ErrorHandler {
  /// Report error to Crashlytics & console
  static Future<void> handleError(
      dynamic error, {
        StackTrace? stackTrace,
        String? reason,
        bool fatal = false,
      }) async {
    final stack = stackTrace ?? StackTrace.current;

    // Log locally
    log("⚠️ Error: $error", error: error, stackTrace: stack);

    // Record the same error message in Crashlytics log (if Firebase is ready).
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseCrashlytics.instance.log("⚠️ Error: $error");
        if (reason != null) {
          await FirebaseCrashlytics.instance.log("Reason: $reason");
        }
        await FirebaseCrashlytics.instance.log("StackTrace: $stack");

        // Record the error itself in Crashlytics
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: reason,
          fatal: fatal,
        );
      } else {
        log('Crashlytics skipped: Firebase not initialized yet.');
      }
    } catch (e, s) {
      log('Crashlytics logging failed: $e', stackTrace: s);
    }
  }

  /// Convenience method for catching exceptions
  static Future<void> capture(Future<void> Function() function) async {
    try {
      await function();
    } catch (e, s) {
      handleError(e, stackTrace: s);
    }
  }
}
