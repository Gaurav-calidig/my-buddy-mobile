import 'package:core/core/navigation/app_router.dart';
import 'package:flutter/material.dart';

/// Enum to define different toast notification styles.
enum ToastType { success, info, error, warning }

/// Enum to define where the overlay snackbar should appear.
enum OverlaySnackPosition { top, center, bottom }

/// Manager for displaying custom overlay toast messages.
///
/// Provides a customizable toast overlay that appears above other UI elements
/// with configurable styling and duration.
class ToastOverlayManager {
  /// Shows a toast message with customizable appearance and duration.
  ///
  /// [message] - The text to display in the toast
  /// [bottomMargin] - Distance from bottom of screen
  /// [toastType] - Type of toast (success, info, error, warning)
  /// [duration] - How long to show the toast
  static void show(
    String message, {
    double bottomMargin = 50,
    double horizontalMargin = 15,
    double offset = 0,
    ToastType toastType = ToastType.error,
    OverlaySnackPosition position = OverlaySnackPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = rootNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // Map toast type → background color
    final Map<ToastType, Color> toastColors = {
      ToastType.success: const Color(0xFF4CAF50), // green
      ToastType.info: const Color(0xFF2196F3), // blue
      ToastType.error: const Color(0xFFE53935), // red
      ToastType.warning: const Color(0xFFFFA000), // amber
    };

    final bgColor = toastColors[toastType]!;

    // Create the overlay entry with toast UI
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final keyboard = MediaQuery.of(context).viewInsets.bottom;
        final mq = MediaQuery.of(context);
        final topInset = mq.padding.top;
        final screenHeight = mq.size.height;

        final double? top;
        final double? bottom;
        switch (position) {
          case OverlaySnackPosition.top:
            top = topInset + offset;
            bottom = null;
            break;
          case OverlaySnackPosition.center:
            top = (screenHeight / 2) - 30 + offset;
            bottom = null;
            break;
          case OverlaySnackPosition.bottom:
            top = null;
            bottom = keyboard + bottomMargin + offset;
            break;
        }

        return Positioned(
          left: horizontalMargin,
          right: horizontalMargin,
          top: top,
          bottom: bottom,
          child: Material(
            color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => entry.remove(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Insert the overlay entry
    overlayState.insert(entry);

    // Schedule automatic removal after duration
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}
