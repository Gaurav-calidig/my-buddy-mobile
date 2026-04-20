# Features

This folder contains business capabilities organized by feature.

## Structure Convention

Each feature should prefer this layout:

- `data/`: DTO/models, remote/local datasources, repository implementations.
- `domain/`: entities, repository contracts, use cases.
- `presentation/`: bloc/cubit, screens, UI states/events.

## Existing Features

- `auth/`
- `calendar/`
- `cart/`
- `payment/`
- `share/`
- `splash/`
- `workmanager/`
- `video_call/`

## Feature Development Rules

- Keep feature internals encapsulated.
- Depend on abstractions from `domain` inside presentation logic.
- Reuse shared infra from `core` instead of duplicating helpers.

## Optional Feature Flags

The feature flags live in lib/core/config/feature_flags.dart. If you no longer need one of the capabilities listed below, disable its flag, drop the registrar from lib/core/dependency_injection/injection_container.dart, remove the matching GoRoute in lib/core/navigation/app_router.dart, and delete the lib/features/<feature> folder.

See the root README.md section _Disabling & Removing Features_ for a full cleanup guide.
