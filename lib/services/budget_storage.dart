import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget.dart';

class BudgetStorage {
  static const _key = 'budgets';

  static Future<List<Budget>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);

    if (data == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      return jsonList.map((json) => Budget.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }
}
