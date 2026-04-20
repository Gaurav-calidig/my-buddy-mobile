# Flutter-Accelerations

A reusable Flutter template for building scalable and maintainable apps.

## Overview

This project provides a boilerplate for Flutter applications, ensuring:

- A consistent and organized project structure
- Standardized API handling
- Ready-to-use dependency injection setup
- Common utilities, validators, and formatters
- Theming and localization support
- Base implementation for Cubit/Bloc state management
- Read this file to better understand the purpose, importance and flow of this architecture
  [text](https://docs.google.com/document/d/1vkstPNjna0vx1DUBAlwgs_EY5htqzru-FczyWzIL15s/edit?usp=sharing)

## Features

Clean folder structure (features, core, data, domain, common)

- Dependency injection using [get_it]
- Common utilities and validators
- API layer setup with error handling
- Theming and localization support
- Sample Cubit/Bloc implementations
- Local + remote data handling examples
- `go_router` navigation with deep-link support

## Folder Structure

lib/
├── core/ # Common classes, constants, error handling
├── data/ # Remote & local data sources, models
├── domain/ # Repositories, use-cases
├── features/ # Feature-based structure
│ └── <feature_name>/
│ ├── data/
│ ├── domain/
│ └── presentation/
├── common/ # Widgets, utils, validators
└── main.dart

## Documentation Index

- App library overview: [`lib/README.md`](lib/README.md)
- Core overview: [`lib/core/README.md`](lib/core/README.md)
- DI overview: [`lib/core/dependency_injection/README.md`](lib/core/dependency_injection/README.md)
- DI modules: [`lib/core/dependency_injection/modules/README.md`](lib/core/dependency_injection/modules/README.md)
- Notification core: [`lib/core/notification/README.md`](lib/core/notification/README.md)
- Notification inbox (detailed): [`lib/core/notification/README_notification_inbox.md`](lib/core/notification/README_notification_inbox.md)
- Features overview: [`lib/features/README.md`](lib/features/README.md)
- Auth feature: [`lib/features/auth/README.md`](lib/features/auth/README.md)
- Payment feature: [`lib/features/payment/README.md`](lib/features/payment/README.md)
- Share feature: [`lib/features/share/README.md`](lib/features/share/README.md)
- Splash feature: [`lib/features/splash/README.md`](lib/features/splash/README.md)
- Force update (detailed): [`lib/features/splash/README_force_update.md`](lib/features/splash/README_force_update.md)
- Remote config (detailed): [`lib/core/services/README_remote_config.md`](lib/core/services/README_remote_config.md)

## Getting Started

- Clone the repository
  git clone https://github.com/<your-org>/flutter-base-architecture.git
  cd flutter-base-architecture
- Install dependencies
  flutter pub get
- Run the app
  flutter run

## Module Flags

The template starts with optional integrations disabled by default.

- `ENABLE_FIREBASE` (default: `false`)
- `ENABLE_AUTH` (default: `false`, requires `ENABLE_FIREBASE=true`)
- `ENABLE_PAYMENTS` (default: `false`)
- `ENABLE_PUSH_NOTIFICATIONS` (default: `false`, requires `ENABLE_FIREBASE=true`)

Example:

```bash
flutter run \
  --dart-define=ENABLE_FIREBASE=true \
  --dart-define=ENABLE_AUTH=true \
  --dart-define=ENABLE_PAYMENTS=true \
  --dart-define=ENABLE_PUSH_NOTIFICATIONS=true
```

## Disabling & Removing Features

Each optional capability is gated through `lib/core/config/feature_flags.dart`. Use `--dart-define=FLAG=false` for temporary builds or edit the constants for a permanent removal.

Permanent removal checklist:

1. Flip the flag(s) in `lib/core/config/feature_flags.dart`.
2. Stop registering the module in `lib/core/dependency_injection/injection_container.dart` (e.g., remove `registerAuthModule(sl);`).
3. Remove the matching `GoRoute`s in `lib/core/navigation/app_router.dart` and drop the constants from `lib/core/navigation/app_routes.dart`.
4. Delete or archive the folder under `lib/features/<feature>` and its docs/tests.

### Feature cleanup details

- **Auth**
  - Flags: `ENABLE_AUTH` (requires `ENABLE_FIREBASE=true`).
  - DI: remove `lib/core/dependency_injection/modules/auth_module.dart` from `injection_container.dart`.
  - Router: drop the `GoRoute`s using `AppRoutes.login`, `AppRoutes.signUp`, and `AppRoutes.phoneAuthTest` in `lib/core/navigation/app_router.dart` and remove the constants in `lib/core/navigation/app_routes.dart`.
  - Extras: prune `lib/features/auth/` and its helper READMEs.

- **Payments**
  - Flag: `ENABLE_PAYMENTS`.
  - DI: stop calling `registerPaymentsModule(sl);`.
  - Router: remove `AppRoutes.payment`, `AppRoutes.paymentConfirmation`, and `AppRoutes.paymentTest` from the router and the constants file.
  - Extras: delete `lib/features/payment/` when the whole module is unnecessary.

- **Cart**
  - Flag: `ENABLE_CART`.
  - DI: remove `registerCartModule(sl);`.
  - Router: remove `AppRoutes.cart` from both `lib/core/navigation/app_router.dart` and `lib/core/navigation/app_routes.dart`.
  - Extras: prune `lib/features/cart/`.

- **Chat**
  - Flag: `ENABLE_CHAT`.
  - DI: remove `registerChatModule(sl);`.
  - Router: remove the `GoRoute` for `AppRoutes.chat`.
  - Extras: remove `lib/features/chat/`.

- **Workmanager**
  - Flag: `ENABLE_WORKMANAGER`.
  - DI: the service is conditional; remove the flag and delete `lib/features/workmanager/` when background tasks are not required.
  - Router: drop `AppRoutes.workmanagerTest` and any references to `WorkmanagerService`.
  - Extras: remove `workmanagerCallbackDispatcher` and related files if the feature is gone.

- **Share & helper demos (no dedicated flag)**
  - Router: remove the share/localization/image-compress test routes (`AppRoutes.shareTest`, `AppRoutes.offlineApiSyncTest`, `AppRoutes.cachedImageTest`, `AppRoutes.localizationTest`, `AppRoutes.imageCompress`) from the router and constants.
  - Extras: delete `lib/features/share/` if these utilities are no longer needed.

After removing routes or modules, run `dart analyze` to catch stale imports and update this README if the project structure shifts.

## Dependency Injection Modules

DI is split into registrars for better modularity and optional onboarding:

- Core: `lib/core/dependency_injection/modules/core_module.dart`
- Firebase: `lib/core/dependency_injection/modules/firebase_module.dart`
- Auth: `lib/core/dependency_injection/modules/auth_module.dart`
- Payments: `lib/core/dependency_injection/modules/payments_module.dart`

Entrypoint orchestrator: `lib/core/dependency_injection/injection_container.dart`

## Security Notes

- Never commit `.env`, Firebase config files, or service account keys.
- Stripe secret key must stay on backend only.
- FCM sending must be done from backend (Firebase Admin SDK), not from mobile app.

## CI and Tests

- GitHub Actions workflow: `.github/workflows/flutter_ci.yml`
- Current baseline test: `test/smoke_test.dart`
- CI runs:
  - `flutter analyze`
  - `flutter test`

## Dependencies

- Flutter >= 3.x
- [Cubit/Bloc] for state management
- [dio/http] for network requests
- [get_it] for dependency injection
- [flutter_localizations] for multi-language support
- [flutter_stripe] for Stripe integration

# Stripe Payment Integration

This project includes a ready-to-use **Stripe payment module** following clean architecture principles.  
It supports **manual capture**, allowing authorization first and capture or cancellation later.

---

## Payment Flow

### 1. Create Payment Intent

- The backend (via Stripe API) creates a **PaymentIntent** with manual capture.
- Returns a **client secret** and **payment intent ID**.

### 2. Confirm Payment (Authorization)

- User enters card details through Stripe’s **CardField** widget.
- Payment is confirmed, placing a **hold on the customer’s funds**.

### 3. Capture or Cancel

- **Capture**: Funds are charged at a later point (e.g., after a booking is completed).
- **Cancel**: The hold is released, and the customer is **not charged**.

---

## Architecture Integration

### Data Layer

- Handles Stripe API calls to **create, capture, and cancel** payment intents.

### Domain Layer

- Exposes **repositories** and **use cases** for payment-related actions.

### Presentation Layer (Bloc)

- Handles payment **events** and **states**:
  - Creating intents
  - Processing payments
  - Success/failure handling

### UI Layer

- Provides screens for:
  - Card entry
  - Initiating payments
  - Confirming results

---

## User Flow

1. User navigates to the **payment screen**.
2. Card details are entered and validated.
3. A **PaymentIntent** is created and confirmed (funds are authorized).
4. Payment can be **captured** or **canceled** later based on business logic.
5. Confirmation screen shows the **status** of the transaction:

- Authorized
- Captured
- Failed

---

## Usage

1. Create a new feature under `features/`.
2. Implement **data, domain, and presentation layers** per feature.
3. Use **dependency injection** to inject repositories and use cases.
4. Use **Cubit/Bloc** for state management.
5. Utilize common **utilities, validators, and theming** for consistency.
6. Use the integrated **Stripe Payment module** for payment flows.

---

## Usage

- Create a new feature under features/
- Implement data, domain, presentation layers per feature
- Use DI to inject repositories and use-cases
- Use Cubit/Bloc for state management
- Use common utilities, validators, and theme for consistency

## Navigation and Deep Linking

- Router entrypoint: `lib/core/navigation/app_router.dart`
- Route constants + deep-link URL builders: `lib/core/navigation/app_routes.dart`
- Custom-scheme deep links are enabled by default:
  - Android intent filter: `commonmodule://app/...`
  - iOS URL scheme: `commonmodule://...`
- Template examples:
  - Login: `commonmodule://app/login`
  - Payment: `commonmodule://app/payment?amount=10.00&currency=USD&email=test@example.com`
  - Payment confirmation: `commonmodule://app/payment/confirmation?isSuccess=true&message=Payment%20processed&amount=10.00&currency=USD`
- For production apps, replace `commonmodule` / `example.com` with your app-specific values.

## Contributing

- Fork the repository
- Create a feature branch: git checkout -b feature/my-feature
- Commit changes: git commit -m 'Add my feature'
- Push to branch: git push origin feature/my-feature
- Open a Pull Request
