import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

/// App-level wrapper that enables showing a modal HUD from any descendant context.
class AppProgressHud extends StatelessWidget {
  const AppProgressHud({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      indicatorColor: Colors.white,
      backgroundColor: Colors.black87,
      barrierColor: Colors.black26,
      child: child,
    );
  }
}

/// Reusable progress utility that standardizes loader visuals and HUD operations.
class AppProgressIndicator {
  const AppProgressIndicator._();

  static void show(BuildContext context, {String? message}) {
    final progress = ProgressHUD.of(context);
    if (progress == null) {
      return;
    }

    if (message == null || message.isEmpty) {
      progress.show();
      return;
    }

    progress.showWithText(message);
  }

  static void dismiss(BuildContext context) {
    final progress = ProgressHUD.of(context);
    progress?.dismiss();
  }

  static Widget loader({double size = 24}) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 2.4),
    );
  }
}
