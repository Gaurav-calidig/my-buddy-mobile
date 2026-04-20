# Force Update Flow (Implemented)

This document explains the force-update flow implemented via Splash + Remote Config build-number comparison.

## Scope

The app blocks normal entry and routes to an update screen when remote build number is greater than installed app build number.

- Decision logic: `lib/features/splash/presentation/bloc/splash_bloc.dart`
- Update screen: `lib/features/splash/presentation/screens/update_required_screen.dart`
- Route constants: `lib/core/navigation/app_routes.dart`
- Route wiring: `lib/core/navigation/app_router.dart` and `lib/main.dart`
- Config source: `lib/core/services/remote_config.dart`

## Core Decision Rule

`shouldForceUpdate = remoteBuildNumber > localBuildNumber`

- `localBuildNumber` from `PackageInfo.fromPlatform().buildNumber`
- `remoteBuildNumber` from Firebase Remote Config:
  - Android: `android_build_number`
  - iOS: `ios_build_number`

If true, Splash emits `SplashNavigateToUpdate`.

## Preconditions and Guards

In current implementation, update check returns `false` when:

- `FeatureFlags.enableFirebase == false`
- Platform is not Android or iOS
- Any exception occurs while fetching or parsing values

This makes update flow fail-open (app continues) instead of fail-closed.

## Execution Sequence

1. `AppStarted` event triggers in `SplashBloc`.
2. Splash emits `SplashLoading`.
3. A 2-second startup delay runs.
4. `_isUpdateRequired()` runs:
   - init remote config
   - get local build number
   - choose remote key by platform
   - compare integers
5. If required, emit `SplashNavigateToUpdate`; else emit `SplashNavigateToLogin`.

## Navigation Path

In `SplashScreen`:

- `SplashNavigateToUpdate` -> `_handleUpdateNavigation(context)`
- If GoRouter enabled: `context.go(AppRoutes.updateRequired)`
- Else: `NavigationService.pushReplacement(UpdateRequiredScreen)`

## Update Screen Behavior

`UpdateRequiredScreen` shows:

- icon
- brand-aware update title (`AppBranding.current.updateTitle`)
- brand-aware update message (`AppBranding.current.updateMessage`)
- `Update App` button placeholder (store deep link not yet wired)

## Dependencies

- `package_info_plus` for installed build number
- `firebase_remote_config` for remote values

## Remote Keys Used by Force Update

- `android_build_number`
- `ios_build_number`

Optional informational keys also present:

- `android_build_version`
- `ios_build_version`

## Recommended Firebase Console Setup

Set build numbers as string integers:

- `android_build_number = 12`
- `ios_build_number = 20`

Then bump when you want to force update.

## Testing Scenarios

1. Local build 1, remote build 1 -> no force update.
2. Local build 1, remote build 2 -> force update screen.
3. Local build 10, remote build 3 -> no force update.
4. Non-numeric remote value -> parse falls back to 0 -> no force update.
5. Firebase disabled flag -> no force update.

## Known Limitations

- `Update App` button does not yet open Play Store/App Store URL.
- No semver comparison; logic is strictly build-number integer comparison.
- Fail-open behavior means outages in Remote Config do not block entry.

## Extension Points

- Add optional force-update toggle key, e.g. `force_update_enabled`.
- Add minimum supported version message from remote config.
- Wire platform store URLs and use `url_launcher` in button handler.
