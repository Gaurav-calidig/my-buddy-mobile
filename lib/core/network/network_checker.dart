import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core/utils/custom_overlay_toast.dart';

/// Observes connectivity and surfaces offline reminders.
class NetworkChecker {
  NetworkChecker(this._connectivity);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Checks current connectivity without altering state.
  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Listens for connectivity changes and reports offline status.
  void startListening() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final isOffline = results.contains(ConnectivityResult.none);
      if (isOffline) {
        ToastOverlayManager.show(
          'No internet connection',
          position: OverlaySnackPosition.bottom,
          toastType: ToastType.error,
        );
      }
    });
  }

  /// Cleans up the connectivity subscription.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
