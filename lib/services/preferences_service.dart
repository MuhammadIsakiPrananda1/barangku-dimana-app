import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyFirstLaunch = 'first_launch';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Dark Mode
  static Future<bool> isDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDarkMode, value);
  }

  // First Launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await _prefs;
    final isFirst = prefs.getBool(_keyFirstLaunch) ?? true;
    if (isFirst) {
      await prefs.setBool(_keyFirstLaunch, false);
    }
    return isFirst;
  }

  // Clear all preferences
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
