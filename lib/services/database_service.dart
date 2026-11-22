import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sakuaman.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  title $textType,
  amount $doubleType,
  type $boolType,
  category $textType,
  date $textType,
  source $textType,
  note TEXT,
  user_id TEXT
)
''');

    await db.execute('''
CREATE TABLE users (
  id $idType,
  name $textType,
  email $textType UNIQUE,
  password $textType,
  created_at $textType
)
''');
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN user_id TEXT');
      await db.execute('''
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''');
    }
  }

  Future<void> insertTransaction(TransactionModel tx) async {
    final db = await instance.database;
    await db.insert(
      'transactions',
      tx.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<TransactionModel> txs) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var tx in txs) {
      batch.insert(
        'transactions',
        tx.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByRange(String userId, DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll(String userId) async {
    final db = await instance.database;
    await db.delete(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<double> getTotalIncome(String userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, TransactionType.income.index],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense(String userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, TransactionType.expense.index],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // User methods
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> migrateTransactionsToUser(String userId) async {
    final db = await instance.database;
    await db.update(
      'transactions',
      {'user_id': userId},
      where: 'user_id IS NULL',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
