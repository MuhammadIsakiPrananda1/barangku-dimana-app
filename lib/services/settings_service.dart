import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SettingsService {
  static const String keyUserName = 'user_name';
  static const String keyUserAvatar = 'user_avatar';

  static const String keyPinEnabled = 'pin_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keySavedPin = 'saved_pin';
  static const String keyWarrantyNotif = 'warranty_notif';

  static String userName = 'User-0000';
  static String userAvatar = '';

  static bool pinEnabled = false;
  static bool biometricEnabled = false;
  static String savedPin = '';
  static bool warrantyNotifEnabled = true;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? storedName = prefs.getString(keyUserName);
    if (storedName == null || storedName == 'Pengguna Barangku') {
      final randomId = Random().nextInt(90000) + 10000;
      storedName = 'User-$randomId';
      await prefs.setString(keyUserName, storedName);
    }
    userName = storedName;
    userAvatar = prefs.getString(keyUserAvatar) ?? '';

    pinEnabled = prefs.getBool(keyPinEnabled) ?? false;
    biometricEnabled = prefs.getBool(keyBiometricEnabled) ?? false;
    savedPin = prefs.getString(keySavedPin) ?? '';
    warrantyNotifEnabled = prefs.getBool(keyWarrantyNotif) ?? true;
  }

  static Future<void> updateUserName(String name) async {
    userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserName, name);
  }



  static Future<void> togglePinLock(bool value, {String pin = ''}) async {
    pinEnabled = value;
    savedPin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyPinEnabled, value);
    await prefs.setString(keySavedPin, pin);
  }

  static Future<void> toggleBiometricLock(bool value) async {
    biometricEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyBiometricEnabled, value);
  }

  static Future<void> toggleWarrantyNotif(bool value) async {
    warrantyNotifEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyWarrantyNotif, value);
  }
}
