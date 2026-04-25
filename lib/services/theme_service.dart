import 'package:flutter/material.dart';
import 'preferences_service.dart';

class ThemeService {
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  static Future<void> toggleTheme(bool isDark) async {
    isDarkModeNotifier.value = isDark;
    await PreferencesService.setDarkMode(isDark);
  }
}
