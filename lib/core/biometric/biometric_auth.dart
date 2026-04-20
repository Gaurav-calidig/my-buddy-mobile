import 'dart:developer';

import 'package:local_auth/local_auth.dart';

/// Wraps LocalAuthentication to surface biometric auth flows.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if biometric hardware is available and enrolled.
  Future<bool> canCheckBiometrics() async {
    return _auth.canCheckBiometrics;
  }

  /// Prompts the user for biometric authentication with localized messaging.
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'Biometric authentication failed: $error',
        name: 'BiometricService',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
