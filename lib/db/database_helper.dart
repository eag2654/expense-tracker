import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_item.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _table = 'transactions';
  static const _budgetTable = 'budgets';
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            date INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_date ON $_table(date DESC)');
        await _createBudgets(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createBudgets(db);
      },
    );
  }

  Future<void> _createBudgets(Database db) => db.execute('''
        CREATE TABLE $_budgetTable (
          category TEXT PRIMARY KEY,
          amount REAL NOT NULL
        )
      ''');

  // ---- Transactions ----
  Future<List<TransactionItem>> getAll() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'date DESC, id DESC');
    return rows.map(TransactionItem.fromMap).toList();
  }

  Future<int> insert(TransactionItem t) async {
    final db = await database;
    final map = t.toMap()..remove('id');
    return db.insert(_table, map);
  }

  Future<void> update(TransactionItem t) async {
    final db = await database;
    await db.update(_table, t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // ---- Budgets (monthly limit per expense category) ----
  Future<Map<String, double>> getBudgets() async {
    final db = await database;
    final rows = await db.query(_budgetTable);
    return {
      for (final r in rows) r['category'] as String: (r['amount'] as num).toDouble()
    };
  }

  Future<void> setBudget(String category, double amount) async {
    final db = await database;
    await db.insert(
      _budgetTable,
      {'category': category, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBudget(String category) async {
    final db = await database;
    await db.delete(_budgetTable, where: 'category = ?', whereArgs: [category]);
  }
}
