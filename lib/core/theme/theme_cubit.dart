import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages preferred app theme and persists the choice securely.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeKey = "theme_mode";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
      _saveTheme(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
      _saveTheme(ThemeMode.light);
    }
  }

  /// Save theme securely
  Future<void> _saveTheme(ThemeMode mode) async {
    await _storage.write(key: _themeKey, value: mode.toString());
  }

  /// Load theme securely
  Future<void> _loadTheme() async {
    final stored = await _storage.read(key: _themeKey);

    if (stored != null) {
      if (stored.contains("dark")) {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    }
  }
}
