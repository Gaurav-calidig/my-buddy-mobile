import 'dart:async';

import 'package:core/core/utils/custom_overlay_toast.dart';
import 'package:core/core/utils/screenshot_attempt_service.dart';
import 'package:core/core/utils/security_service.dart';
import 'package:flutter/material.dart';

/// Wrap any sensitive screen with this widget to prevent screenshots/recording.
///
/// - Android: screenshots are blocked via `secure_application`.
/// - iOS: screenshots are blocked, and we can also show a toast when the user
///   takes a screenshot (iOS only).
class SensitiveScreenProtection extends StatefulWidget {
  final Widget child;
  final String screenshotToastMessage;
  final ToastType screenshotToastType;
  final bool showToastOnScreenshot;

  const SensitiveScreenProtection({
    super.key,
    required this.child,
    this.screenshotToastMessage = 'Screenshots are disabled on this screen.',
    this.screenshotToastType = ToastType.warning,
    this.showToastOnScreenshot = true,
  });

  @override
  State<SensitiveScreenProtection> createState() =>
      _SensitiveScreenProtectionState();
}

class _SensitiveScreenProtectionState extends State<SensitiveScreenProtection> {
  StreamSubscription<void>? _screenshotSub;

  @override
  void initState() {
    super.initState();
    unawaited(SecurityService.enableProtection());

    if (widget.showToastOnScreenshot) {
      _screenshotSub = ScreenshotAttemptService.instance.events.listen((_) {
        ToastOverlayManager.show(
          widget.screenshotToastMessage,
          toastType: widget.screenshotToastType,
        );
      });
    }
  }

  @override
  void dispose() {
    _screenshotSub?.cancel();
    unawaited(SecurityService.disableProtection());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

