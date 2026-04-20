# Auth Feature

Authentication flows and account session actions.

## Responsibilities

- Email/password login.
- Sign up.
- Google sign-in / sign-out.
- Apple sign-in.
- Phone auth (OTP) send/verify.
- Forgot password.
- Account deletion.

## Layers

- `data/`: remote datasource and repository implementations.
- `domain/`: entities, repository contract, and use cases.
- `presentation/`: `AuthBloc` + UI.

## Use cases (domain)

Single-responsibility use cases are preferred:

- `EmailPasswordLoginUseCase`
- `SignUpUseCase`
- `GoogleSignInUseCase`
- `GoogleSignOutUseCase`
- `LoginWithAppleUseCase`
- `ForgotPasswordUseCase`
- `SendOtpUseCase`
- `VerifyOtpUseCase`
- `DeleteAccountUseCase`

## Bloc ownership

UI should not call domain use cases directly.

- Dispatch events from UI: `lib/features/auth/presentation/bloc/auth_event.dart`
- Handle side effects in bloc: `lib/features/auth/presentation/bloc/auth_bloc.dart`
- Render states in UI: `lib/features/auth/presentation/bloc/auth_state.dart`

## Notes

- This feature is optional and controlled by feature flags.
- Firebase must be enabled for current auth integrations.
- Forgot password details: `lib/features/auth/README_forgot_password.md`
- Sign up details: `lib/features/auth/README_sign_up.md`
- Phone auth details: `lib/features/auth/README_phone_auth.md`
