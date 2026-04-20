import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Emits events when the OS detects a user screenshot.
///
/// Notes:
/// - iOS supports `UIApplication.userDidTakeScreenshotNotification`.
/// - Android does not provide a reliable screenshot attempt callback, especially
///   when screenshots are blocked via `FLAG_SECURE`.
class ScreenshotAttemptService {
  ScreenshotAttemptService._();

  static final ScreenshotAttemptService instance = ScreenshotAttemptService._();

  static const MethodChannel _channel = MethodChannel('core/screenshot_attempt');

  final StreamController<void> _controller = StreamController<void>.broadcast();
  bool _initialized = false;

  Stream<void> get events {
    _ensureInitialized();
    return _controller.stream;
  }

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) return;
    if (!Platform.isIOS) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshot') {
        if (!_controller.isClosed) {
          _controller.add(null);
        }
      }
    });
  }

  Future<void> dispose() async {
    if (_controller.isClosed) return;
    await _controller.close();
  }
}
