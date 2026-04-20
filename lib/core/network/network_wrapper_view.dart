import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core/widgets/app_progress_indicator.dart';
import 'package:flutter/material.dart';

/// Wraps UI to show an offline placeholder when connectivity is lost.
class NetworkWrapper extends StatefulWidget {
  const NetworkWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;
  bool _isCheckingConnection = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialConnection();
    });

    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isOffline = result.contains(ConnectivityResult.none);
      });
    });
  }

  /// Checks current connectivity status and updates state.
  Future<void> _checkInitialConnection() async {
    if (!mounted) {
      return;
    }

    AppProgressIndicator.show(context, message: 'Checking connection...');
    setState(() {
      _isCheckingConnection = true;
    });

    try {
      final results = await _connectivity.checkConnectivity();
      if (!mounted) {
        return;
      }

      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });
    } finally {
      if (mounted) {
        AppProgressIndicator.dismiss(context);
        setState(() {
          _isCheckingConnection = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Builds either a loader, the offline placeholder, or the wrapped child.
  @override
  Widget build(BuildContext context) {
    if (_isCheckingConnection) {
      return Scaffold(
        body: Center(child: AppProgressIndicator.loader(size: 32)),
      );
    }

    if (_isOffline) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _checkInitialConnection,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
