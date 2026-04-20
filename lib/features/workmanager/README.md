# Workmanager Feature

This feature groups the app's background task integration and its manual test UI in one place.

## Structure

- `service/`: Workmanager setup, task registration, permission checks, and background location capture.
- `screen/`: Manual test screen for initializing Workmanager, scheduling jobs, and inspecting saved task results.

## Files

- `service/workmanager_service.dart`: Owns Workmanager initialization, callback dispatcher wiring, and background location persistence.
- `screen/workmanager_test_screen.dart`: Debug screen for testing one-off and periodic background jobs.

## Notes

- The feature is gated by `FeatureFlags.enableWorkmanager`.
- Background jobs persist the last known location, status, and timestamp with `FlutterSecureStorage`.
- The periodic task uses a 15 minute interval, which is the minimum cadence commonly allowed by Workmanager.
