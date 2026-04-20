abstract class LocalDbRepository {
  Future<void> init();

  Future<void> write({
    required String box,
    required String key,
    required dynamic value,
  });

  Future<T?> read<T>({
    required String box,
    required String key,
  });

  Future<void> delete({
    required String box,
    required String key,
  });

  Future<void> clearBox(String box);
}
