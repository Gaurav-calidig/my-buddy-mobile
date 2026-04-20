# Deep Linking Integration

This template uses `go_router` for app navigation and deep-link handling.

## Flutter Integration Included

1. Router integration
- `MaterialApp.router` is configured in `lib/main.dart`.
- `GoRouter` is configured in `lib/core/navigation/app_router.dart`.
- Deep links are resolved directly to route paths:
  - `/`
  - `/login`
  - `/payment`
  - `/payment/add-card`
  - `/payment/saved-cards`
  - `/subscription`
  - `/payment/confirmation`

2. Route + deep-link helpers
- `lib/core/navigation/app_routes.dart` includes:
  - in-app location builders (`paymentLocation`, `paymentConfirmationLocation`)
  - deep-link builders (`toDeepLink`, `loginDeepLink`, `paymentDeepLink`, `paymentConfirmationDeepLink`)

3. Android manifest integration
- `android/app/src/main/AndroidManifest.xml` includes:
  - custom scheme filter: `commonmodule://app/...`
  - HTTPS app-link template filter for `https://example.com/...`

4. iOS plist integration
- `ios/Runner/Info.plist` includes URL scheme registration:
  - `commonmodule://...`

## Deep-Link URL Format

1. Custom scheme deep links
- Login: `commonmodule://app/login`
- Payment:
  `commonmodule://app/payment?amount=10.00&currency=USD&email=test@example.com&gateway=stripe`
- Add card:
  `commonmodule://app/payment/add-card`
- Saved cards:
  `commonmodule://app/payment/saved-cards`
- Subscriptions:
  `commonmodule://app/subscription`
- Payment confirmation:
  `commonmodule://app/payment/confirmation?status=success&message=Payment%20processed&amount=10.00&currency=USD&gateway=Stripe&referenceId=pi_123`

2. HTTPS links (App Links / Universal Links target)
- `https://example.com/login`
- `https://example.com/payment?...`
- `https://example.com/payment/confirmation?...`

## Required Steps Outside Flutter Code

1. Replace template identifiers
- Replace `commonmodule` scheme and `app` host with product values.
- Replace `example.com` with your real domain.

2. Android App Links verification
- Host this file on your domain:
  - `https://<your-domain>/.well-known/assetlinks.json`
- Include your app package name and SHA-256 signing certificate fingerprint.
- Keep `android:autoVerify="true"` in the intent filter.

3. iOS Universal Links setup
- Enable `Associated Domains` capability in Xcode.
- Add:
  - `applinks:<your-domain>`
- Host:
  - `https://<your-domain>/.well-known/apple-app-site-association`
- Include your Team ID + bundle identifier in the association file.

4. Environment-specific domains
- Use different app identifiers/domains for dev, staging, prod.
- Make sure each environment serves valid `assetlinks.json` and `apple-app-site-association`.

## Test Commands

1. Android (custom scheme)
```bash
adb shell am start -a android.intent.action.VIEW -d "commonmodule://app/login"
```

2. Android (HTTPS app link)
```bash
adb shell am start -a android.intent.action.VIEW -d "https://example.com/payment?amount=10.00&currency=USD&email=test@example.com"
```

3. iOS simulator
```bash
xcrun simctl openurl booted "commonmodule://app/payment?amount=10.00&currency=USD&email=test@example.com"
```

## Notes

- For `/payment`, the app expects query params:
  - `amount`
  - `currency`
  - `email` (optional for current flow, but recommended)
  - `gateway` (optional, defaults to `stripe`)
- For `/payment/confirmation`, expected query params:
  - `status`
  - `message`
  - `amount`
  - `currency`
  - `gateway`
  - `referenceId` (optional)
