import 'package:flutter/material.dart';
import 'app_translations.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  static AppSettings get instance => _instance;

  AppSettings._internal();

  ThemeMode _themeMode = ThemeMode.system;
  String _currentLanguage = 'en';

  ThemeMode get themeMode => _themeMode;
  String get currentLanguage => _currentLanguage;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setLanguage(String langCode) {
    if (AppTranslations.languageNames.containsKey(langCode) &&
        _currentLanguage != langCode) {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  String tr(String key) {
    return AppTranslations.get(key, lang: _currentLanguage);
  }
}
