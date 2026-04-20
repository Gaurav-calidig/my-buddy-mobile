# DI Modules

This folder contains atomic dependency registrars.

## Modules

- `core_module.dart`
  - Registers always-needed dependencies (networking, connectivity, share service).
- `firebase_module.dart`
  - Registers Firebase-specific dependencies.
- `auth_module.dart`
  - Registers auth datasource/repository/use-cases/bloc.
- `payments_module.dart`
  - Registers payment datasource/repository/use-cases/bloc.
- `cart_module.dart`
  - Registers cart datasource/repository/use-cases.

## Guidelines

- Keep each file focused on one module.
- Do not include feature-flag checks inside module files.
- Feature enable/disable decisions belong to `injection_container.dart`.
