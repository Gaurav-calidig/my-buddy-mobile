import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling device permissions across Android & iOS.
///
/// Handles lower API devices, permanent denials, and background location on Android 10+.
class Permissions {
  Permissions._(); // Prevent instantiation

  /// Request location permission.
  ///
  /// Returns true if the app has at least foreground location permission.
  /// Handles permanently denied, restricted, and Android 10+ background cases.
  static Future<bool> location({bool requestBackground = false}) async {
    LocationPermission permission = await Geolocator.checkPermission();

    // Foreground request if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    // Permanently denied or restricted
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return false;
    }

    // Android 10+ background location handling
    if (requestBackground && permission == LocationPermission.whileInUse) {
      // Request background permission via permission_handler
      final bgStatus = await Permission.locationAlways.status;
      if (!bgStatus.isGranted) {
        final result = await Permission.locationAlways.request();
        return result.isGranted;
      }
    }

    return true;
  }

  /// Request camera permission
  static Future<bool> camera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Request storage permission (legacy Android & iOS)
  static Future<bool> storage() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    final result = await Permission.storage.request();
    return result.isGranted;
  }

  /// Generic permission request
  ///
  /// Example: `Permissions.request(Permission.microphone)`
  static Future<bool> request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    final result = await permission.request();
    return result.isGranted;
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}
