import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../utils/format.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final items = p.monthItems
        .where((t) => _filter == null || t.type == _filter)
        .toList();

    // Group by day (items are already sorted newest first)
    final groups = <DateTime, List<TransactionItem>>{};
    for (final t in items) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(key, () => []).add(t);
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: MonthSelector(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _chip('ทั้งหมด', null),
              const SizedBox(width: 8),
              _chip('รายรับ', TransactionType.income),
              const SizedBox(width: 8),
              _chip('รายจ่าย', TransactionType.expense),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('ไม่มีรายการในเดือนนี้'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: [
                    for (final entry in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Text(
                          formatDayHeader(entry.key),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      for (final t in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              context.read<TransactionProvider>().remove(t.id!);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: const Text('ลบรายการแล้ว'),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'เลิกทำ',
                                    onPressed: () => context
                                        .read<TransactionProvider>()
                                        .add(TransactionItem(
                                          amount: t.amount,
                                          type: t.type,
                                          category: t.category,
                                          note: t.note,
                                          date: t.date,
                                        )),
                                  ),
                                ));
                            },
                            child: TransactionTile(
                              item: t,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddTransactionScreen(existing: t),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, TransactionType? type) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == type,
      onSelected: (_) => setState(() => _filter = type),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
