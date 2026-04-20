# Remote Config (Implemented)

This document covers the current Firebase Remote Config integration and how it is used in this project.

## Scope

Remote Config is currently used for app version/build metadata used by the force-update check.

- Service: `lib/core/services/remote_config.dart`
- Consumer: `lib/features/splash/presentation/bloc/splash_bloc.dart`
- Startup logs: `lib/main.dart` (debug logging of android build fields)

## Service API

Class: `RemoteConfigService`

Public methods and getters:

- `Future<void> init()`
- `String get androidBuildNumber`
- `String get androidBuildVersion`
- `String get iosBuildNumber`
- `String get iosBuildVersion`

## Defaults Set in Code

During `init()`, defaults are applied:

- `android_build_number = '1'`
- `android_build_version = '1.0.0'`
- `ios_build_number = '1'`
- `ios_build_version = '1.0.0'`

These are fallback values used when server values are absent.

## Fetch Configuration

`RemoteConfigSettings` currently uses:

- `fetchTimeout: 10 seconds`
- `minimumFetchInterval: Duration.zero`

`minimumFetchInterval = 0` is ideal for testing/dev but usually should be increased in production to reduce fetch frequency.

## Activation Flow

`init()` calls `fetchAndActivate()`.

That means each init cycle:

1. Fetches latest values from server (subject to settings)
2. Activates fetched values for immediate reads

## How It Is Used

### 1) Force Update

Splash reads remote build number and compares it with installed build number.

- Android key used on Android
- iOS key used on iOS

### 2) Startup Logging

`main.dart` currently logs Android build version/number after init (useful during setup).

## Required Runtime Conditions

- Firebase must be initialized (`FirebaseInitializer.ensureInitialized()` used in startup and background isolate paths).
- `FeatureFlags.enableFirebase` should be true where Remote Config is used.

## Firebase Console Key Setup

Create/update these Remote Config parameter keys:

- `android_build_number` (string integer)
- `android_build_version` (string)
- `ios_build_number` (string integer)
- `ios_build_version` (string)

Example:

- `android_build_number = 24`
- `android_build_version = 2.4.0`
- `ios_build_number = 30`
- `ios_build_version = 3.0.0`

## Failure Handling

- Errors in force-update path are caught in `SplashBloc`.
- On error, update check returns false and app continues.
- Code uses integer parse fallback (`int.tryParse(... ) ?? 0`).

## Testing Guide

1. Set remote keys in Firebase Console.
2. Run app.
3. Verify logs print expected build keys in startup.
4. Set remote build above installed build and restart app.
5. Confirm update screen is shown.

## Production Recommendations

- Increase `minimumFetchInterval` in release builds.
- Consider environment-specific key naming or namespaces.
- Add analytics/logging around update-check outcomes.
- Remove verbose startup logging once stable.

## Related Files

- `lib/core/services/remote_config.dart`
- `lib/features/splash/presentation/bloc/splash_bloc.dart`
- `lib/features/splash/presentation/screens/update_required_screen.dart`
- `lib/core/config/feature_flags.dart`
