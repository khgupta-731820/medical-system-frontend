import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider with ChangeNotifier {
  final StorageService _storageService;
  AppThemeMode _themeMode = AppThemeMode.system;

  ThemeProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService() {
    _loadThemeMode();
  }

  AppThemeMode get themeMode => _themeMode;

  bool get isLight => _themeMode == AppThemeMode.light;
  bool get isDark => _themeMode == AppThemeMode.dark;
  bool get isSystem => _themeMode == AppThemeMode.system;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> _loadThemeMode() async {
    final savedMode = _storageService.getThemeMode();
    _themeMode = _parseThemeMode(savedMode);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _storageService.setThemeMode(mode.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == AppThemeMode.light) {
      await setThemeMode(AppThemeMode.dark);
    } else if (_themeMode == AppThemeMode.dark) {
      await setThemeMode(AppThemeMode.system);
    } else {
      await setThemeMode(AppThemeMode.light);
    }
  }

  AppThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}