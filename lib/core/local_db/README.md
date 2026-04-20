# Local DB Layer

This module uses an enum-based strategy to switch local database engines:

- `LocalDbMethod.sqflite`
- `LocalDbMethod.hive`
- `LocalDbMethod.isar`
- `LocalDbMethod.objectBox`

Config file:
- `lib/core/config/local_db_method.dart`

Resolver file:
- `lib/core/local_db/local_db_repository_impl.dart`

## Database-Specific Docs
- Sqflite: `lib/core/local_db/sqflite/README.md`
- Hive: `lib/core/local_db/hive/README.md`
- Isar: `lib/core/local_db/isar/README.md`
- ObjectBox: `lib/core/local_db/objectbox/README.md`

## How To Switch DB
Change one line:

```dart
const LocalDbMethod kLocalDbMethod = LocalDbMethod.sqflite;
```

in `lib/core/config/local_db_method.dart`.
