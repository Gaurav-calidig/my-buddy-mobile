import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:core/core/utils/custom_overlay_toast.dart';
import 'package:core/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

/// A service to capture screenshots of the entire app or specific widgets.

class ScreenshotService {
  /// Global key to capture the entire app.
  /// This should wrap the topmost widget in the app's builder.
  static final GlobalKey rootKey = GlobalKey();

  /// Captures the widget associated with the [rootKey] and returns it as [Uint8List].
  static Future<Uint8List?> capture() async {
    try {
      final RenderRepaintBoundary? boundary =
          rootKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        debugPrint('ScreenshotService: Boundary is null. Ensure the rootKey is attached to a RepaintBoundary.');
        return null;
      }

      // Small delay to ensure any pending frames are rendered
      await Future.delayed(const Duration(milliseconds: 20));

      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(rootKey.currentContext!).devicePixelRatio,
      );
      
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('ScreenshotService capture error: $e');
      return null;
    }
  }

  /// Captures the screenshot and saves it to a temporary file.
  static Future<File?> captureAndSave() async {
    final Uint8List? imageBytes = await capture();
    if (imageBytes == null) return null;

    try {
      final directory = await getTemporaryDirectory();
      final String path = '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(path);
      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('ScreenshotService save error: $e');
      return null;
    }
  }

  /// Captures the screenshot and shares it using the platform's share dialog.
  static Future<void> captureAndShare({String? text, String? subject}) async {
    final File? file = await captureAndSave();
    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      );
    }
  }

  /// Captures the screenshot and saves it to the device's gallery.
  static Future<bool> saveToGallery() async {
    try {
      final File? file = await captureAndSave();
      if (file == null) return false;
      
      await Gal.putImage(file.path);
      ToastOverlayManager.show("Screenshot saved to gallery", toastType: ToastType.info);
      return true;
    } catch (e) {
      debugPrint('ScreenshotService gallery save error: $e');
      return false;
    }
  }
}
