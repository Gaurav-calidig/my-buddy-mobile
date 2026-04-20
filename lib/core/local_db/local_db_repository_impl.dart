import 'package:core/core/config/local_db_method.dart';
import 'package:core/core/local_db/local_db_memory_datasource.dart';
import 'package:core/core/local_db/local_db_repository.dart';
import 'package:core/core/local_db/hive/hive_local_db_repository.dart';
import 'package:core/core/local_db/isar/isar_local_db_repository.dart';
import 'package:core/core/local_db/objectbox/object_box_local_db_repository.dart';
import 'package:core/core/local_db/sqflite/sqflite_local_db_repository.dart';

class LocalDbRepositoryImpl implements LocalDbRepository {
  final LocalDbRepository _repository;
  final LocalDbMethod _localDbMethod;

  LocalDbRepositoryImpl({
    required LocalDbMemoryDatasource datasource,
    required LocalDbMethod localDbMethod,
  })  : _localDbMethod = localDbMethod,
        _repository = _resolveRepository(datasource, localDbMethod);

  String _scopedBox(String box) => '${_localDbMethod.name}::$box';

  static LocalDbRepository _resolveRepository(
    LocalDbMemoryDatasource datasource,
    LocalDbMethod localDbMethod,
  ) {
    switch (localDbMethod) {
      case LocalDbMethod.sqflite:
        return SqfliteLocalDbRepository(datasource: datasource);
      case LocalDbMethod.hive:
        return HiveLocalDbRepository(datasource: datasource);
      case LocalDbMethod.isar:
        return IsarLocalDbRepository(datasource: datasource);
      case LocalDbMethod.objectBox:
        return ObjectBoxLocalDbRepository(datasource: datasource);
    }
  }

  @override
  Future<void> init() => _repository.init();

  @override
  Future<void> write({
    required String box,
    required String key,
    required dynamic value,
  }) => _repository.write(box: _scopedBox(box), key: key, value: value);

  @override
  Future<T?> read<T>({
    required String box,
    required String key,
  }) => _repository.read<T>(box: _scopedBox(box), key: key);

  @override
  Future<void> delete({
    required String box,
    required String key,
  }) => _repository.delete(box: _scopedBox(box), key: key);

  @override
  Future<void> clearBox(String box) => _repository.clearBox(_scopedBox(box));
}
