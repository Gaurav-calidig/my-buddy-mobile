# Isar Local DB

## Overview
`isar` is a high-performance object database for Flutter with query support.  
Use it when you need strong local performance with object-based modeling.

## Current Project Mapping
- Enum: `LocalDbMethod.isar`
- Repository file: `lib/core/local_db/isar/isar_local_db_repository.dart`
- Selector: `lib/core/local_db/local_db_repository_impl.dart`

## Best For
- High-performance offline-first apps
- Rich local queries on object models
- Reactive data listeners

## Package Setup
Add dependencies in `pubspec.yaml`:

```yaml
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
```

Code generation:

```yaml
dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: ^2.5.4
```

## Initialization Pattern
Typical startup flow:
1. Define `@collection` models.
2. Run code generation.
3. Open Isar with schemas.
4. Inject instance into `IsarLocalDbRepository`.

## Notes
- Requires generated schema code.
- Very good query/write performance.
- Plan collection schemas early for cleaner migrations.

