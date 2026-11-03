import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/transaction_item.dart';
import '../utils/format.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = Categories.find(item.category, item.type);
    final amountColor =
        item.isIncome ? const Color(0xFF2E9E6B) : const Color(0xFFD95555);

    return Card(
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: cat.color.withValues(alpha: 0.15),
          child: Icon(cat.icon, color: cat.color),
        ),
        title: Text(cat.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          item.note.isEmpty
              ? formatDate(item.date)
              : '${item.note} • ${formatDate(item.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${item.isIncome ? '+' : '-'}${formatMoney(item.amount)}',
          style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
