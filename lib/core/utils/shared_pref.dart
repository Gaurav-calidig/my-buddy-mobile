import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A helper class to handle secure local storage using flutter_secure_storage
/// Provides utility methods for saving, reading, deleting, and managing data.
class SharedPref {
  // Singleton instance
  static final SharedPref _instance = SharedPref._internal();

  factory SharedPref() => _instance;

  SharedPref._internal();

  // Flutter Secure Storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ------------------- WRITE DATA -------------------

  /// Save a simple key-value string
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Save JSON object as string
  Future<void> writeJson(String key, Map<String, dynamic> data) async {
    await _storage.write(key: key, value: jsonEncode(data));
  }

  /// Save a boolean value
  Future<void> writeBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  /// Save an integer value
  Future<void> writeInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  // ------------------- READ DATA -------------------

  /// Read value by key
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Read JSON object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final data = await _storage.read(key: key);
    if (data == null) return null;
    return jsonDecode(data);
  }

  /// Read a boolean value
  Future<bool?> readBool(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  /// Read an integer value
  Future<int?> readInt(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  // ------------------- DELETE DATA -------------------

  /// Delete value by key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all values
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // ------------------- EXTRA UTILITIES -------------------

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    final all = await _storage.readAll();
    return all.containsKey(key);
  }

  /// Get all stored key-value pairs
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  /// Update existing value (same as write, but adds intent)
  Future<void> update(String key, String value) async {
    await write(key, value);
  }
}
