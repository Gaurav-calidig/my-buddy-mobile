class LocalDbMemoryDatasource {
  final Map<String, Map<String, dynamic>> _store = {};

  Future<void> init() async {}

  Future<void> write({
    required String box,
    required String key,
    required dynamic value,
  }) async {
    _store.putIfAbsent(box, () => <String, dynamic>{})[key] = value;
  }

  Future<T?> read<T>({
    required String box,
    required String key,
  }) async {
    final value = _store[box]?[key];
    if (value is T) return value;
    return null;
  }

  Future<void> delete({
    required String box,
    required String key,
  }) async {
    _store[box]?.remove(key);
  }

  Future<void> clearBox(String box) async {
    _store[box]?.clear();
  }
}
