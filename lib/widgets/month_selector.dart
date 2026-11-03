import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/format.dart';

/// "‹  November 2026  ›" bar. Tap the label to jump to any month.
class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: p.previousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final picked = await _pickMonth(context, p.month);
              if (picked != null) p.setMonth(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    formatMonth(p.month),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: scheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: p.canGoNext ? p.nextMonth : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  Future<DateTime?> _pickMonth(BuildContext context, DateTime current) {
    final now = DateTime.now();
    return showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        var year = current.year;
        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => year--),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Text('${beYear(year)}',
                        style: Theme.of(ctx)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed:
                          year < now.year ? () => setState(() => year++) : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var m = 1; m <= 12; m++)
                      SizedBox(
                        width: 72,
                        child: ChoiceChip(
                          label: Center(child: Text(formatMonthShort(m))),
                          showCheckmark: false,
                          selected: year == current.year && m == current.month,
                          // can't pick months in the future
                          onSelected: DateTime(year, m)
                                  .isAfter(DateTime(now.year, now.month))
                              ? null
                              : (_) => Navigator.pop(ctx, DateTime(year, m)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
