# Screenshot Protection

This project supports "sensitive" screens where screenshots / screen recording should be blocked as much as the OS allows.

## What to use

- Widget wrapper: `lib/core/widgets/sensitive_screen_protection.dart`
- Service: `lib/core/utils/security_service.dart`

Wrap any sensitive screen:

- `SensitiveScreenProtection(child: YourScreen())`

## Platform behavior

### Android

- Screenshots are blocked using `FLAG_SECURE`.
- This applies to Flutter screens and native SDK screens (e.g. Stripe `PaymentSheet`) via the platform channel in `SecurityService` and the Android `Application` lifecycle hook.

### iOS

- iOS does **not** provide an API to block screenshots.
- We can only detect screenshots after they occur (via `UIApplication.userDidTakeScreenshotNotification`) and then:
  - show a toast (optional)
  - briefly obscure UI (optional)

Important: the already-captured screenshot cannot be made black; the OS captures before the notification.

## Where screenshot detection comes from (iOS)

- Dart stream: `lib/core/utils/screenshot_attempt_service.dart`
- iOS bridge: `ios/Runner/AppDelegate.swift`

## Test screen

- `lib/features/share/presentation/screens/screenshot_protection_test_screen.dart`
- Open from the drawer: **Screenshot Protection**
