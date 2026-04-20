enum LocalDbMethod {
  sqflite,
  hive,
  isar,
  objectBox,
}

/// Global local DB method toggle.
/// Change this in one place to switch local DB implementation.
const LocalDbMethod kLocalDbMethod = LocalDbMethod.sqflite;
