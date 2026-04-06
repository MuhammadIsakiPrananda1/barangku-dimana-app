import 'package:flutter/material.dart';

class ThemeService {
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  static void toggleTheme(bool isDark) {
    isDarkModeNotifier.value = isDark;
  }
}
