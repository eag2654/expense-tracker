import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_bar.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/weekly_bar_chart.dart';
import 'budget_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onSeeAll;
  const DashboardScreen({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final recent = p.monthItems.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        const MonthSelector(),
        const SizedBox(height: 16),
        BalanceCard(
          label: 'ยอดคงเหลือเดือนนี้',
          balance: p.balance,
          income: p.totalIncome,
          expense: p.totalExpense,
        ),
        const SizedBox(height: 24),
        _section(context, 'รายจ่ายตามหมวดหมู่',
            ExpensePieChart(data: p.expenseByCategory)),
        const SizedBox(height: 16),
        _budgetSection(context, p),
        const SizedBox(height: 16),
        _section(
          context,
          '7 วันล่าสุด',
          Column(
            children: [
              WeeklyBarChart(data: p.lastDays(7)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(Color(0xFF4CAF82), 'รายรับ'),
                  SizedBox(width: 16),
                  _Dot(Color(0xFFEF6B6B), 'รายจ่าย'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('รายการล่าสุด',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            TextButton(onPressed: onSeeAll, child: const Text('ดูทั้งหมด')),
          ],
        ),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('ไม่มีรายการในเดือนนี้')),
          )
        else
          for (final t in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TransactionTile(item: t),
            ),
      ],
    );
  }

  Widget _budgetSection(BuildContext context, TransactionProvider p) {
    final entries = p.budgets.entries.toList()
      ..sort((a, b) {
        final ra = p.spentFor(a.key) / a.value;
        final rb = p.spentFor(b.key) / b.value;
        return rb.compareTo(ra); // most used first
      });
    final shown = entries.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('งบประมาณ',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  ),
                  child: Text(p.budgets.isEmpty ? 'ตั้งค่า' : 'จัดการ'),
                ),
              ],
            ),
            if (shown.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8, right: 8),
                child: Text('ตั้งวงเงินรายเดือนของแต่ละหมวดเพื่อติดตามการใช้จ่าย'),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    for (final e in shown)
                      BudgetBar(
                        category: e.key,
                        spent: p.spentFor(e.key),
                        limit: e.value,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}
