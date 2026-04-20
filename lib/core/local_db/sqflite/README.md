# Sqflite Local DB

## Overview
`sqflite` is a relational SQLite database for Flutter.  
Use it when you need SQL queries, joins, indexes, and structured schemas.

## Current Project Mapping
- Enum: `LocalDbMethod.sqflite`
- Repository file: `lib/core/local_db/sqflite/sqflite_local_db_repository.dart`
- Selector: `lib/core/local_db/local_db_repository_impl.dart`

## Best For
- Complex filtering/search with SQL
- Multi-table relationships
- Apps already modeled around relational data

## Package Setup
Add dependencies in `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.4.1
  path: ^1.9.1
```

## Initialization Pattern
Typical startup flow:
1. Build/open SQLite database.
2. Run `onCreate`/migrations.
3. Provide DB instance to `SqfliteLocalDbRepository`.

## Notes
- Keep schema versions and migrations explicit.
- Use transactions for multi-step writes.
- Create indexes for frequently filtered columns.

