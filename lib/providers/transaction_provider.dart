import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/transaction_item.dart';

class TransactionProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<TransactionItem> _items = [];
  Map<String, double> _budgets = {};
  bool _loading = true;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  bool get loading => _loading;

  /// All transactions (every month).
  List<TransactionItem> get items => List.unmodifiable(_items);

  // ---------- Month filter ----------
  DateTime get month => _month;

  bool get canGoNext {
    final now = DateTime.now();
    return _month.isBefore(DateTime(now.year, now.month));
  }

  void setMonth(DateTime d) {
    _month = DateTime(d.year, d.month);
    notifyListeners();
  }

  void previousMonth() => setMonth(DateTime(_month.year, _month.month - 1));
  void nextMonth() {
    if (canGoNext) setMonth(DateTime(_month.year, _month.month + 1));
  }

  /// Transactions of the selected month (newest first).
  List<TransactionItem> get monthItems => _items
      .where((t) => t.date.year == _month.year && t.date.month == _month.month)
      .toList();

  double get totalIncome =>
      monthItems.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get totalExpense =>
      monthItems.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Expense totals of the selected month grouped by category, largest first.
  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in monthItems.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  /// Income / expense totals for the last [days] days (oldest -> newest).
  List<({DateTime day, double income, double expense})> lastDays(int days) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    return List.generate(days, (i) {
      final day = start.add(Duration(days: i));
      double inc = 0, exp = 0;
      for (final t in _items) {
        if (t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day) {
          t.isIncome ? inc += t.amount : exp += t.amount;
        }
      }
      return (day: day, income: inc, expense: exp);
    });
  }

  // ---------- Budgets ----------
  Map<String, double> get budgets => Map.unmodifiable(_budgets);

  double? budgetFor(String category) => _budgets[category];

  double spentFor(String category) => expenseByCategory[category] ?? 0;

  Future<void> setBudget(String category, double amount) async {
    await _db.setBudget(category, amount);
    _budgets = await _db.getBudgets();
    notifyListeners();
  }

  Future<void> removeBudget(String category) async {
    await _db.deleteBudget(category);
    _budgets = await _db.getBudgets();
    notifyListeners();
  }

  // ---------- Persistence ----------
  Future<void> load() async {
    _items = await _db.getAll();
    _budgets = await _db.getBudgets();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(TransactionItem t) async {
    await _db.insert(t);
    await load();
  }

  Future<void> edit(TransactionItem t) async {
    await _db.update(t);
    await load();
  }

  Future<void> remove(int id) async {
    await _db.delete(id);
    await load();
  }
}
