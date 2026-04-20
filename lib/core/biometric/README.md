# Biometric Authentication

This folder contains the biometric login helper used by the auth flow.

## File

- `biometric_auth.dart`: wraps the `local_auth` package behind `BiometricService`.

## What `BiometricService` does

`BiometricService` exposes two methods:

- `canCheckBiometrics()`
  - Returns whether the device reports biometric capability.
- `authenticate()`
  - Opens the system biometric prompt.
  - Uses `biometricOnly: true`, so PIN, pattern, or password fallback is not allowed.
  - Uses `stickyAuth: true`, so authentication can resume after short interruptions.

The prompt reason shown to the user is:

`Please authenticate to login`

## Current login flow

1. A user logs in or signs up with email and password.
2. The auth repository stores those credentials in secure storage under `PrefKeys.biometricLoginCredentials`.
3. In `login_screen.dart`, tapping the biometric button:
   - checks biometric availability,
   - requests biometric authentication,
   - reads the saved credentials from secure storage,
   - dispatches `LoginRequested` with the stored email and password.

## Storage details

Saved biometric login credentials are stored with `SharedPref`, which uses `flutter_secure_storage`.

Stored shape:

```json
{
  "email": "user@example.com",
  "password": "secret"
}
```

Storage key:

```dart
PrefKeys.biometricLoginCredentials
```

Current cleanup behavior:

- Deleted on account deletion.
- Deleted on Google sign-out.

## Important limitations

- `canCheckBiometrics()` only checks biometric capability. It does not verify that biometrics are enrolled.
- `authenticate()` catches all errors and returns `false`, so callers do not get specific failure reasons.
- The biometric button in the login screen currently assumes saved credentials exist after a successful biometric scan.
- Credentials are stored for biometric re-login, which may not match stricter security requirements in some apps.

## Related files

- `lib/core/biometric/biometric_auth.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/data/firebase_auth_repository.dart`
- `lib/features/auth/data/api_auth_repository.dart`
- `lib/core/utils/shared_pref.dart`
- `lib/core/constants/pref_keys.dart`
