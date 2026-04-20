import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocketClient {
  final String url;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final List<String> _pending = [];

  ChatWebSocketClient({required this.url});

  Stream<Map<String, dynamic>> get messages {
    _ensureConnected();
    return _messagesController.stream;
  }

  bool get isConnected => _channel != null;

  void send(Map<String, dynamic> data) {
    final payload = jsonEncode(data);
    if (_channel == null) {
      _pending.add(payload);
      _ensureConnected();
      return;
    }
    _channel!.sink.add(payload);
  }

  void _ensureConnected() {
    if (_channel != null) return;

    final rawUrl = url.trim();
    if (rawUrl.isEmpty) {
      throw Exception('CHAT_WS_URL is not set.');
    }

    final parsed = Uri.tryParse(rawUrl);
    if (parsed == null || !parsed.hasScheme) {
      throw Exception('CHAT_WS_URL is invalid: "$rawUrl"');
    }
    if (parsed.scheme != 'ws' && parsed.scheme != 'wss') {
      throw Exception('CHAT_WS_URL must start with ws:// or wss://');
    }

    final resolved = _resolvePlatformUrl(parsed);
    final channel = WebSocketChannel.connect(resolved);
    _channel = channel;
    _subscription = channel.stream.listen(
      _handleEvent,
      onError: _handleError,
      onDone: _handleDone,
    );

    if (_pending.isNotEmpty) {
      for (final payload in _pending) {
        channel.sink.add(payload);
      }
      _pending.clear();
    }
  }

  Uri _resolvePlatformUrl(Uri uri) {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      // Android emulators cannot reach host machine via localhost.
      return uri.replace(host: '10.0.2.2');
    }
    return uri;
  }

  void _handleEvent(dynamic event) {
    Map<String, dynamic>? payload;
    if (event is String) {
      payload = _decode(event);
    } else if (event is List<int>) {
      payload = _decode(utf8.decode(event));
    } else if (event is Map) {
      payload = event.cast<String, dynamic>();
    }
    if (payload != null) {
      _messagesController.add(payload);
    }
  }

  Map<String, dynamic>? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _messagesController.addError(error, stackTrace);
  }

  void _handleDone() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
  }

  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
}
