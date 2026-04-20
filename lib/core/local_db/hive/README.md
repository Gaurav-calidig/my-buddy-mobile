# Hive Local DB

## Overview
`hive` is a fast key-value NoSQL database for Flutter.  
Use it when you need simple local persistence with low overhead.

## Current Project Mapping
- Enum: `LocalDbMethod.hive`
- Repository file: `lib/core/local_db/hive/hive_local_db_repository.dart`
- Selector: `lib/core/local_db/local_db_repository_impl.dart`

## Best For
- Caching API responses
- User preferences/session data
- Lightweight offline storage

## Package Setup
Add dependencies in `pubspec.yaml`:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

Optional (for typed adapters):

```yaml
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.5.4
```

## Initialization Pattern
Typical startup flow:
1. `Hive.initFlutter()`
2. Register adapters (if using typed objects)
3. Open required boxes
4. Provide access through `HiveLocalDbRepository`

## Notes
- Great speed for key-value operations.
- No SQL joins; model relations manually.
- Keep box naming/versioning consistent.

