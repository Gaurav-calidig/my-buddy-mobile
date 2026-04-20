import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';

/// Ensures Firebase default app is initialized exactly once per isolate.
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    try {
      await Firebase.initializeApp();
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'duplicate-app') {
        log("Duplicate Firebase app init");
        return;
      }
      log('Firebase initialize failed: $error', stackTrace: stackTrace);
      rethrow;
    }
  }
}
