# Dependency Injection

This folder manages dependency registration using `GetIt`.

## Files

- `injection_container.dart`
  - Main orchestrator used by app startup (`init()`).
  - Reads feature flags and composes module registrars.
- `modules/`
  - Isolated registrars for optional and core modules.
  - Keeps setup modular and easy to extend.

## Current Registration Flow

1. Register core infrastructure.
2. Register Firebase module only when enabled.
3. Register Auth module only when Auth + Firebase are enabled.
4. Register Payments module only when enabled.
5. Register Cart module only when enabled.

## Adding a New Module

1. Create `modules/<name>_module.dart` with `register<Name>Module(GetIt sl)`.
2. Keep registrations idempotent using `sl.isRegistered<T>()` checks.
3. Wire the module in `injection_container.dart` with appropriate feature flags.
