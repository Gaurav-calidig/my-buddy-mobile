import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:secure_application/secure_application.dart';

/// A service to handle application security features like screenshot prevention.
class SecurityService {
  static final SecureApplicationController controller =
      SecureApplicationController(
    SecureApplicationState(secured: false),
  );

  static const MethodChannel _androidChannel = MethodChannel(
    'core/screen_protection',
  );

  /// Enables screenshot prevention and content protection.
  static Future<void> enableProtection() async {
    controller.secure();

    // `secure_application` prevents screenshots in Flutter views, but some native
    // SDK screens (e.g. Stripe PaymentSheet) may use their own Activity.
    // On Android, also set FLAG_SECURE for all activities via the native bridge.
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod<void>('enable');
      } catch (e) {
        debugPrint('SecurityService: Android enableProtection failed: $e');
      }
    }

    debugPrint('SecurityService: Protection enabled');
  }

  /// Disables screenshot prevention and content protection.
  static Future<void> disableProtection() async {
    controller.open();

    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod<void>('disable');
      } catch (e) {
        debugPrint('SecurityService: Android disableProtection failed: $e');
      }
    }

    debugPrint('SecurityService: Protection disabled');
  }

  /// Toggles the protection state.
  static Future<void> toggleProtection() async {
    if (controller.secured) {
      await disableProtection();
    } else {
      await enableProtection();
    }
  }

  /// Returns true if protection is currently enabled.
  static bool get isProtected => controller.secured;
}

