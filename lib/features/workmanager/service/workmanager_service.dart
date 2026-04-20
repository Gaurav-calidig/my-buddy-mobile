import 'dart:developer';
import 'dart:ui';

import 'package:core/core/config/feature_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

const String kWorkmanagerOneOffTask = 'sample_one_off_task';
const String kWorkmanagerPeriodicTask = 'sample_periodic_task';
const String kWorkmanagerIosPeriodicTaskIdentifier =
    'com.example.commonModule.backgroundLocationTask';
const String _lastLocationKey = 'workmanager_last_location';
const String _lastLocationTimeKey = 'workmanager_last_location_time';
const String _lastLocationStatusKey = 'workmanager_last_location_status';

@pragma('vm:entry-point')
/// Entry point executed by Workmanager to capture and store the current location snapshot.
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (task == kWorkmanagerOneOffTask ||
        task == kWorkmanagerPeriodicTask ||
        task == kWorkmanagerIosPeriodicTaskIdentifier ||
        task == Workmanager.iOSBackgroundTask) {
      await WorkmanagerService.captureCurrentLocation(taskName: task);
    }

    return true;
  });
}

/// Wraps Workmanager scheduling, background permission validation, and log tracking for location tasks.
class WorkmanagerService {
  WorkmanagerService();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  final ValueNotifier<List<String>> taskLogs = ValueNotifier<List<String>>(
    const <String>[],
  );

  bool _initialized = false;

  /// Initializes Workmanager once and logs the result.
  Future<void> initialize() async {
    if (!FeatureFlags.enableWorkmanager) {
      _appendLog('Workmanager is disabled by feature flag.');
      return;
    }

    if (_initialized) {
      _appendLog('Workmanager already initialized.');
      return;
    }

    await Workmanager().initialize(workmanagerCallbackDispatcher);
    _initialized = true;
    _appendLog('Workmanager initialized.');
  }

  /// Schedules a one-off background location fetch.
  Future<void> registerOneOffTask() async {
    _ensureFeatureEnabled();
    await _ensureInitialized();
    await _ensureBackgroundLocationReady();
    await Workmanager().registerOneOffTask(
      'one-off-${DateTime.now().millisecondsSinceEpoch}',
      kWorkmanagerOneOffTask,
      inputData: <String, dynamic>{
        'requestedAt': DateTime.now().toIso8601String(),
      },
    );
    _appendLog('One-off task scheduled.');
  }

  /// Schedules the repeating background location task (15 min default).
  Future<void> registerPeriodicTask() async {
    _ensureFeatureEnabled();
    await _ensureInitialized();
    await _ensureBackgroundLocationReady();
    await Workmanager().registerPeriodicTask(
      kDebugMode ? 'debug-$kWorkmanagerPeriodicTask' : kWorkmanagerPeriodicTask,
      defaultTargetPlatform == TargetPlatform.iOS
          ? kWorkmanagerIosPeriodicTaskIdentifier
          : kWorkmanagerPeriodicTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      inputData: <String, dynamic>{
        'requestedAt': DateTime.now().toIso8601String(),
      },
    );
    _appendLog('Periodic background-location task scheduled (15 min).');
  }

  /// Cancels every registered Workmanager task.
  Future<void> cancelAllTasks() async {
    _ensureFeatureEnabled();
    await _ensureInitialized();
    await Workmanager().cancelAll();
    _appendLog('All scheduled tasks cancelled.');
  }

  /// Ensures background location permission & services are available before scheduling tasks.
  Future<bool> requestBackgroundLocationPermission() async {
    if (!FeatureFlags.enableWorkmanager) {
      _appendLog('Workmanager permission request skipped. Feature disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // Step 1: Request basic permission.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Step 2: Handle denied forever.
    if (permission == LocationPermission.deniedForever) {
      _appendLog('Permission permanently denied.');
      await _openPermissionSettings();
      return false;
    }

    // Step 3: If only while-in-use, try upgrading to always.
    if (permission == LocationPermission.whileInUse) {
      _appendLog('Trying to upgrade to ALWAYS permission...');
      final PermissionStatus alwaysStatus = await Permission.locationAlways
          .request();

      if (alwaysStatus.isGranted) {
        permission = LocationPermission.always;
      } else {
        permission = await Geolocator.checkPermission();
      }

      // If still not always, send user to settings.
      if (permission != LocationPermission.always) {
        _appendLog('ALWAYS permission not granted. Redirecting to settings.');

        await _openPermissionSettings();
        return false;
      }
    }

    // Step 4: Final check.
    if (permission != LocationPermission.always) {
      _appendLog('Background location requires ALWAYS permission.');
      return false;
    }

    // Step 5: Check service.
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _appendLog('Location services are disabled on device.');
      return false;
    }

    _appendLog('Background location permission granted (ALWAYS).');
    return true;
  }

  /// Reads the latest saved location/status snapshot for display.
  Future<Map<String, String?>> readLastLocationSnapshot() async {
    return <String, String?>{
      'location': await _storage.read(key: _lastLocationKey),
      'timestamp': await _storage.read(key: _lastLocationTimeKey),
      'status': await _storage.read(key: _lastLocationStatusKey),
    };
  }

  /// Captures the current location and persists it for the provided task.
  static Future<void> captureCurrentLocation({required String taskName}) async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _persistLocationStatus(
          status: 'Location services disabled during $taskName',
        );
        return;
      }

      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        await _persistLocationStatus(
          status:
              'Location permission unavailable during $taskName: $permission',
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final String location = '${position.latitude}, ${position.longitude}';
      final String timestamp = DateTime.now().toIso8601String();

      await _storage.write(key: _lastLocationKey, value: location);
      await _storage.write(key: _lastLocationTimeKey, value: timestamp);
      await _persistLocationStatus(status: 'Fetched location from $taskName');

      log(
        'Workmanager location fetched: task=$taskName, location=$location',
        name: 'WorkmanagerService',
      );
    } catch (error, stackTrace) {
      await _persistLocationStatus(
        status: 'Location fetch failed in $taskName: $error',
      );
      log(
        'Workmanager location fetch failed: $error',
        name: 'WorkmanagerService',
        stackTrace: stackTrace,
      );
    }
  }

  /// Ensures initialization is only performed once.
  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await initialize();
  }

  /// Guards against scheduling when the feature flag is off.
  void _ensureFeatureEnabled() {
    if (!FeatureFlags.enableWorkmanager) {
      throw StateError('Workmanager is disabled by feature flag.');
    }
  }

  /// Validates background location permission before scheduling.
  Future<void> _ensureBackgroundLocationReady() async {
    final bool granted = await requestBackgroundLocationPermission();
    if (!granted) {
      throw StateError(
        'Background location permission is required before scheduling tasks.',
      );
    }
  }

  /// Logs status messages to secure storage.
  static Future<void> _persistLocationStatus({required String status}) async {
    await _storage.write(key: _lastLocationStatusKey, value: status);
    await _storage.write(
      key: _lastLocationTimeKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Appends messages to the log ValueNotifier.
  void _appendLog(String message) {
    final List<String> nextLogs = <String>[
      '${DateTime.now().toIso8601String()}  $message',
      ...taskLogs.value,
    ];
    taskLogs.value = nextLogs;
    log(message, name: 'WorkmanagerService');
  }

  /// Opens the most specific permission/settings screen available for location access.
  Future<void> _openPermissionSettings() async {
    bool opened = false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final String packageName = (await PackageInfo.fromPlatform()).packageName;

      // Try opening the app-permission screen first (works on many Android builds).
      final Uri permissionUri = Uri.parse(
        'intent:#Intent;action=android.settings.APP_PERMISSION_SETTINGS;'
        'S.android.intent.extra.PACKAGE_NAME=$packageName;end',
      );
      if (await canLaunchUrl(permissionUri)) {
        opened = await launchUrl(
          permissionUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // Fallback: app details settings page.
      if (!opened) {
        final Uri appDetailsUri = Uri.parse(
          'intent:#Intent;action=android.settings.APPLICATION_DETAILS_SETTINGS;'
          'data=package:$packageName;end',
        );
        if (await canLaunchUrl(appDetailsUri)) {
          opened = await launchUrl(
            appDetailsUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    }

    if (!opened) {
      opened = await openAppSettings();
    }

    if (!opened) {
      _appendLog('Unable to open app settings automatically.');
    }
  }
}
