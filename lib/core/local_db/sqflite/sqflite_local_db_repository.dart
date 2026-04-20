import 'package:core/core/local_db/local_db_memory_datasource.dart';
import 'package:core/core/local_db/local_db_repository.dart';

class SqfliteLocalDbRepository implements LocalDbRepository {
  final LocalDbMemoryDatasource datasource;

  SqfliteLocalDbRepository({required this.datasource});

  @override
  Future<void> init() => datasource.init();

  @override
  Future<void> write({
    required String box,
    required String key,
    required dynamic value,
  }) => datasource.write(box: box, key: key, value: value);

  @override
  Future<T?> read<T>({
    required String box,
    required String key,
  }) => datasource.read<T>(box: box, key: key);

  @override
  Future<void> delete({
    required String box,
    required String key,
  }) => datasource.delete(box: box, key: key);

  @override
  Future<void> clearBox(String box) => datasource.clearBox(box);
}
