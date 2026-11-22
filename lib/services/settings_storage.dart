import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _keyIsDark = 'is_dark';

  static Future<bool> loadIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDark) ?? true;
  }

  static Future<void> saveIsDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, value);
  }
}
