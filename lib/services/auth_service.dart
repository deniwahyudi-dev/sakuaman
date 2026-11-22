import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'database_service.dart';
import 'preferences_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  static const String _keyUserId = 'logged_in_user_id';

  // Trivial hash because "crypto gak usah" was requested
  String _hashPassword(String password) {
    return base64Encode(utf8.encode(password.split('').reversed.join('')));
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty) return 'Nama tidak boleh kosong';
    if (email.isEmpty || !email.contains('@')) return 'Email tidak valid';
    if (password.length < 8) return 'Password minimal 8 karakter';

    final existingUser = await DatabaseService.instance.getUserByEmail(email);
    if (existingUser != null) return 'Email sudah terdaftar';

    final id = const Uuid().v4();
    final user = UserModel(
      id: id,
      name: name,
      email: email,
      password: _hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseService.instance.insertUser(user.toJson());
    
    // Migrate old local data to first user
    await DatabaseService.instance.migrateTransactionsToUser(id);

    return null; // Success
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final userData = await DatabaseService.instance.getUserByEmail(email);
    if (userData == null) return 'Email tidak ditemukan';

    final user = UserModel.fromJson(userData);
    if (user.password != _hashPassword(password)) return 'Password salah';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    
    return null; // Success
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    if (userId == null) return null;

    final userData = await DatabaseService.instance.getUserById(userId);
    if (userData == null) return null;

    return UserModel.fromJson(userData);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }
}
