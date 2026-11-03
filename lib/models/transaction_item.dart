import 'category.dart';

class TransactionItem {
  final int? id;
  final double amount;
  final TransactionType type;
  final String category;
  final String note;
  final DateTime date;

  const TransactionItem({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.note = '',
    required this.date,
  });

  bool get isIncome => type == TransactionType.income;

  Map<String, Object?> toMap() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'category': category,
        'note': note,
        'date': date.millisecondsSinceEpoch,
      };

  factory TransactionItem.fromMap(Map<String, Object?> m) => TransactionItem(
        id: m['id'] as int?,
        amount: (m['amount'] as num).toDouble(),
        type: TransactionType.values.byName(m['type'] as String),
        category: m['category'] as String,
        note: (m['note'] as String?) ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      );
}
