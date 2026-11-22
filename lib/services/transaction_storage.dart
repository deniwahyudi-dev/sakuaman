import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class TransactionStorage {
  static const _key = 'transactions';

  static Future<void> saveTransaction(TransactionModel tx) async {
    final transactions = await loadTransactions();
    
    transactions.removeWhere((t) => t.id == tx.id);
    transactions.add(tx);
    
    await _saveToPrefs(transactions);
  }

  static Future<void> saveAll(List<TransactionModel> transactions) async {
    await _saveToPrefs(transactions);
  }

  static Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      final list = jsonList
          .map((json) => TransactionModel.fromJson(json))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final transactions = await loadTransactions();
    
    transactions.removeWhere((tx) => tx.id == id);
    
    await _saveToPrefs(transactions);
  }

  static Future<void> _saveToPrefs(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    
    final jsonList = transactions.map((tx) => tx.toJson()).toList();
    final String jsonString = json.encode(jsonList);
    
    await prefs.setString(_key, jsonString);
  }
}