# Forgot Password

This document describes the **Forgot Password / Reset Password** flow supported by the Auth feature.

The implementation is **selectable**:

- `AuthMethod.firebase` (default): uses Firebase Auth `sendPasswordResetEmail`
- `AuthMethod.api`: calls the backend endpoint `POST /auth/forgot-password`

The active implementation is selected by `kAuthMethod` in `lib/core/config/auth_method.dart`.

## Entry Point (Domain)

- Use case: `ForgotPasswordUseCase` (`lib/features/auth/domain/usecases/forgot_password_usecase.dart`)
- Contract: `AuthRepository.forgotPassword(String email)` (`lib/features/auth/domain/repositories/auth_repository.dart`)
- Router: `AuthRepositoryImpl` delegates to API/Firebase (`lib/features/auth/data/auth_repository_impl.dart`)

## Firebase Flow (`AuthMethod.firebase`)

Code path:

- `ForgotPasswordUseCase.execute(email)`
- `AuthRepositoryImpl.forgotPassword(email)`
- `FirebaseAuthRepository.forgotPassword(email)` (`lib/features/auth/data/firebase_auth_repository.dart`)
- `AuthRemoteDatasource.firebaseAuth.sendPasswordResetEmail(email: email)`

Behavior:

- Firebase sends a password reset email to the user (if the email exists in Firebase Auth).
- The app does **not** receive the reset link; the user completes the reset in email/browser.
- Recommended UX: always show a generic success message (avoid account enumeration).

Prerequisites:

- `FeatureFlags.enableAuth == true` and Firebase initialized (see `FeatureFlags.enableFirebase`).
- Firebase Auth Email/Password provider enabled in Firebase Console.
- Dynamic links are **not** required for `sendPasswordResetEmail` unless you customize redirect behavior.

Error handling (typical FirebaseAuthException codes):

- `invalid-email`
- `user-not-found` (treat as success in UI)
- `too-many-requests`
- `network-request-failed`

## API Flow (`AuthMethod.api`)

Code path:

- `ForgotPasswordUseCase.execute(email)`
- `AuthRepositoryImpl.forgotPassword(email)`
- `ApiAuthRepository.forgotPassword(email)` (`lib/features/auth/data/api_auth_repository.dart`)
- `AuthRemoteDatasource.forgotPassword(email)` (`lib/features/auth/data/datasources/auth_remote_datasource.dart`)
- `ApiService.post(ApiRoutes.forgotPassword, body)` (`lib/core/network/api_routes.dart`)

Endpoint:

- URL: `ApiRoutes.forgotPassword` => `POST {baseUrl}/auth/forgot-password`
- Body (current client implementation sends both keys):
  - `email`: string
  - `username`: string (same value as `email`)

Expected backend behavior (contract suggestion):

- Always respond with `200 OK` even if the account does not exist (avoid account enumeration).
- Rate-limit and audit requests per IP/email.
- Send email with reset link or OTP per backend design.

## Notes / Security

- Do not reveal whether an email is registered.
- Apply throttling to protect the endpoint and Firebase project.
- Ensure the reset link/OTP expires and is single-use (API flow).



