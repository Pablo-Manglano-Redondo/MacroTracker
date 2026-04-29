import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';

class ThemeModeProvider extends ChangeNotifier {
  AppThemeEntity appTheme;
  Locale? _locale;

  ThemeModeProvider({required this.appTheme, Locale? locale}) : _locale = locale;

  get themeMode => appTheme.toThemeMode();
  Locale? get locale => _locale;

  void updateTheme(AppThemeEntity appTheme) {
    this.appTheme = appTheme;
    notifyListeners();
  }

  void updateLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }
}
