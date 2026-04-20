# ObjectBox Local DB

## Overview
`objectbox` is an object-oriented local database focused on speed and simplicity.  
Use it when you want object persistence with efficient queries and relations.

## Current Project Mapping
- Enum: `LocalDbMethod.objectBox`
- Repository file: `lib/core/local_db/objectbox/object_box_local_db_repository.dart`
- Selector: `lib/core/local_db/local_db_repository_impl.dart`

## Best For
- Fast object CRUD
- Domain-driven entity storage
- Offline data with relation support

## Package Setup
Add dependencies in `pubspec.yaml`:

```yaml
dependencies:
  objectbox: ^4.1.0
  objectbox_flutter_libs: ^4.1.0
```

Code generation:

```yaml
dev_dependencies:
  objectbox_generator: ^4.1.0
  build_runner: ^2.5.4
```

## Initialization Pattern
Typical startup flow:
1. Define `@Entity` models.
2. Run code generation.
3. Build/open ObjectBox `Store`.
4. Inject store-backed repository implementation.

## Notes
- Generated code is required.
- Excellent speed for object operations.
- Keep entity IDs and migration strategy stable.

