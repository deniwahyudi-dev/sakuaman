import 'package:shared_preferences/shared_preferences.dart';

/// Service Cache & Preferensi Lokal Saku
/// Menyimpan status tema (Dark / Light) dan riwayat onboarding tanpa overengineering.
class PreferencesService {
  static const String _keyIsDark = 'saku_is_dark_theme';
  static const String _keyHasSeenOnboarding = 'saku_has_seen_onboarding';
  static const String _keyIsMigrated = 'saku_is_migrated_to_sql';

  /// Ambil status Tema (Default: True = Dark Mode)
  static Future<bool> isDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsDark) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Simpan status Tema
  static Future<void> setDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsDark, isDark);
    } catch (_) {}
  }

  /// Cek apakah data sudah dimigrasi ke SQLite
  static Future<bool> isMigrated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsMigrated) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Tandai migrasi selesai
  static Future<void> setMigrated(bool migrated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsMigrated, migrated);
    } catch (_) {}
  }

  /// Cek apakah pengguna sudah pernah melihat layar sambutan/onboarding
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSeenOnboarding) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Tandai onboarding telah selesai
  static Future<void> setOnboardingSeen(bool seen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboarding, seen);
    } catch (_) {}
  }
}
