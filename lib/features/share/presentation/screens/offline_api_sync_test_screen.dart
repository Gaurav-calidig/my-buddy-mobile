import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/core/utils/utils.dart';
import 'package:flutter/material.dart';

/// Allows manual API calls plus retrying queued requests to verify the offline sync service.
class OfflineApiSyncTestScreen extends StatefulWidget {
  const OfflineApiSyncTestScreen({super.key});

  @override
  State<OfflineApiSyncTestScreen> createState() =>
      _OfflineApiSyncTestScreenState();
}

/// Tracks connectivity, dispatches test requests, and flushes pending offline queue operations.
class _OfflineApiSyncTestScreenState extends State<OfflineApiSyncTestScreen> {
  final TextEditingController _endpointController = TextEditingController(
    text: ApiRoutes.cartAdd,
  );
  final TextEditingController _payloadController = TextEditingController(
    text: '{"userId":"offline-user","productId":"sku-101","quantity":1}',
  );

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isLoading = false;
  int _pendingCount = 0;
  String _result = 'Ready';

  bool _wasOffline = false;

  ApiService get _apiService => sl<ApiService>();

  @override
  void initState() {
    super.initState();
    _refreshPendingCount();
    _initializeConnectivityState();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _endpointController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  Future<void> _initializeConnectivityState() async {
    final results = await Connectivity().checkConnectivity();
    _wasOffline = results.contains(ConnectivityResult.none);
    _listenForReconnect();
  }

  void _listenForReconnect() {
    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen(
      (results) async {
        final isOnline = !results.contains(ConnectivityResult.none);
        if (!isOnline) {
          _wasOffline = true;
          return;
        }
        if (!_wasOffline || _isLoading) {
          return;
        }

        _wasOffline = false;
        await _refreshPendingCount();
        if (_pendingCount <= 0) {
          return;
        }

        log(
          'Connectivity restored. Starting offline sync for $_pendingCount pending request(s).',
          name: 'OfflineApiSyncTestScreen',
        );
        AppUtils.showToast('Syncing $_pendingCount pending request(s)...');
        await _flushQueue(triggeredByReconnect: true);
      },
    );
  }

  Future<void> _refreshPendingCount() async {
    final count = await _apiService.pendingOfflineRequestCount();
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingCount = count;
    });
  }

  Future<void> _sendTestRequest() async {
    final endpoint = _endpointController.text.trim();
    if (endpoint.isEmpty) {
      setState(() => _result = 'Endpoint is required.');
      return;
    }

    final stopwatch = Stopwatch()..start();
    log('Manual API test started for $endpoint', name: 'OfflineApiSyncTestScreen');

    setState(() {
      _isLoading = true;
      _result = 'Calling API...';
    });

    try {
      await _apiService.post(endpoint, <String, dynamic>{
        'source': 'offline_api_sync_test',
        'payload': _payloadController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      stopwatch.stop();
      log(
        'Manual API test succeeded in ${stopwatch.elapsedMilliseconds} ms.',
        name: 'OfflineApiSyncTestScreen',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _result =
            'API call succeeded immediately in ${stopwatch.elapsedMilliseconds} ms.';
      });
    } catch (e) {
      stopwatch.stop();
      log(
        'Manual API test failed after ${stopwatch.elapsedMilliseconds} ms. Error: $e',
        name: 'OfflineApiSyncTestScreen',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _result =
            'API call failed after ${stopwatch.elapsedMilliseconds} ms. If it was a network issue, it has been queued for retry.\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      await _refreshPendingCount();
    }
  }

  Future<void> _flushQueue({bool triggeredByReconnect = false}) async {
    final stopwatch = Stopwatch()..start();
    final syncSource = triggeredByReconnect ? 'Reconnect sync' : 'Manual sync';

    log(
      '$syncSource started with $_pendingCount pending request(s).',
      name: 'OfflineApiSyncTestScreen',
    );

    if (triggeredByReconnect) {
      AppUtils.showToast('Sync started...');
    }

    setState(() {
      _isLoading = true;
      _result = 'Retrying pending API requests...';
    });

    try {
      await _apiService.retryPendingRequests();
      stopwatch.stop();
      log(
        '$syncSource completed in ${stopwatch.elapsedMilliseconds} ms.',
        name: 'OfflineApiSyncTestScreen',
      );
      if (triggeredByReconnect) {
        AppUtils.showToast(
          'Sync completed in ${stopwatch.elapsedMilliseconds} ms',
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _result =
            'Pending API retry finished in ${stopwatch.elapsedMilliseconds} ms.';
      });
    } catch (e) {
      stopwatch.stop();
      log(
        '$syncSource failed after ${stopwatch.elapsedMilliseconds} ms. Error: $e',
        name: 'OfflineApiSyncTestScreen',
      );
      if (triggeredByReconnect) {
        AppUtils.showToast(
          'Sync failed after ${stopwatch.elapsedMilliseconds} ms',
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _result = 'Retry failed after ${stopwatch.elapsedMilliseconds} ms: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      await _refreshPendingCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline API Sync Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Pending offline requests: $_pendingCount'),
            const SizedBox(height: 12),
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(labelText: 'Endpoint'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _payloadController,
              decoration: const InputDecoration(labelText: 'Payload'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendTestRequest,
                    child: const Text('Call API'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _flushQueue,
                    child: const Text('Retry Pending'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
