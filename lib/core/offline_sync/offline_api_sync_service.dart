import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/offline_sync/offline_api_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

typedef OfflineApiExecutor =
    Future<Response<dynamic>> Function(OfflineApiRequest request);

class OfflineApiSyncService {
  OfflineApiSyncService(
    this._connectivity, {
    FlutterSecureStorage? storage,
    Logger? logger,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _logger = logger ?? Logger();

  final Connectivity _connectivity;
  final FlutterSecureStorage _storage;
  final Logger _logger;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  OfflineApiExecutor? _executor;
  bool _isFlushing = false;

  Future<void> init() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final hasInternet = !results.contains(ConnectivityResult.none);
      if (hasInternet) {
        unawaited(flushPendingRequests());
      }
    });
  }

  void attachExecutor(OfflineApiExecutor executor) {
    _executor = executor;
  }

  Future<int> pendingCount() async {
    final pending = await getPendingRequests();
    return pending.length;
  }

  Future<List<OfflineApiRequest>> getPendingRequests() async {
    final raw = await _storage.read(key: PrefKeys.pendingApiRequests);
    if (raw == null || raw.isEmpty) {
      return <OfflineApiRequest>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <OfflineApiRequest>[];
    }

    return decoded
        .whereType<Map>()
        .map((item) => OfflineApiRequest.fromMap(item.cast<String, dynamic>()))
        .toList();
  }

  Future<void> queueRequest(OfflineApiRequest request) async {
    final pending = await getPendingRequests();
    if (pending.any((item) => item.id == request.id)) {
      return;
    }

    pending.add(request);
    await _persistPendingRequests(pending);
    _logger.w('Queued offline API request: ${request.method} ${request.endpoint}');
  }

  Future<void> flushPendingRequests() async {
    if (_isFlushing || _executor == null) {
      return;
    }

    final connectivityResults = await _connectivity.checkConnectivity();
    final hasInternet = !connectivityResults.contains(ConnectivityResult.none);
    if (!hasInternet) {
      return;
    }

    _isFlushing = true;
    try {
      final pending = await getPendingRequests();
      if (pending.isEmpty) {
        return;
      }

      final remaining = <OfflineApiRequest>[];
      for (final request in pending) {
        try {
          await _executor!.call(request);
          _logger.i(
            'Replayed offline API request: ${request.method} ${request.endpoint}',
          );
        } catch (_) {
          remaining.add(request.copyWith(retryCount: request.retryCount + 1));
        }
      }

      await _persistPendingRequests(remaining);
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _persistPendingRequests(List<OfflineApiRequest> requests) async {
    final payload = jsonEncode(requests.map((item) => item.toMap()).toList());
    await _storage.write(key: PrefKeys.pendingApiRequests, value: payload);
  }
}

