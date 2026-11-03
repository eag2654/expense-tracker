import 'package:flutter/material.dart';

import '../models/category.dart';
import '../utils/format.dart';

/// Category row with spent / limit and a coloured progress bar.
class BudgetBar extends StatelessWidget {
  final String category;
  final double spent;
  final double? limit; // null = no budget set
  final VoidCallback? onTap;

  const BudgetBar({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat = Categories.find(category, TransactionType.expense);
    final hasLimit = limit != null && limit! > 0;
    final ratio = hasLimit ? spent / limit! : 0.0;
    final over = hasLimit && spent > limit!;

    final barColor = over
        ? const Color(0xFFE05252)
        : ratio >= 0.8
            ? const Color(0xFFF2A33A)
            : const Color(0xFF4CAF82);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cat.color.withValues(alpha: 0.15),
                  child: Icon(cat.icon, size: 18, color: cat.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(cat.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(
                  hasLimit
                      ? '${formatCompact(spent)} / ${formatCompact(limit!)}'
                      : spent > 0
                          ? '${formatCompact(spent)} · ไม่มีงบ'
                          : 'ตั้งงบ',
                  style: TextStyle(
                    fontSize: 13,
                    color: over
                        ? barColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: over ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (hasLimit) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  color: barColor,
                  backgroundColor: barColor.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  over
                      ? 'เกินงบ ${formatMoney(spent - limit!)}'
                      : 'เหลืออีก ${formatMoney(limit! - spent)}',
                  style: TextStyle(fontSize: 11, color: barColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
