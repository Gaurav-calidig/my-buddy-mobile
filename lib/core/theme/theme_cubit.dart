import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages preferred app theme and persists the choice securely.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeKey = "theme_mode";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeCubit() : super(ThemeMode.dark) {
    _loadTheme();
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    if (state == ThemeMode.light) {
      updateTheme(ThemeMode.dark);
    } else {
      updateTheme(ThemeMode.light);
    }
  }

  /// Update theme to a specific mode
  void updateTheme(ThemeMode mode) {
    emit(mode);
    _saveTheme(mode);
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
