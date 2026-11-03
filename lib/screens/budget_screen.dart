import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../utils/format.dart';
import '../widgets/budget_bar.dart';
import '../widgets/month_selector.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final cats = Categories.expense;

    final totalBudget = p.budgets.values.fold(0.0, (a, b) => a + b);
    final totalSpentOnBudgeted = p.budgets.keys
        .fold(0.0, (s, c) => s + p.spentFor(c));

    return Scaffold(
      appBar: AppBar(
        title: const Text('งบประมาณ',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const MonthSelector(),
          const SizedBox(height: 16),
          if (p.budgets.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('งบรวมเดือนนี้'),
                    const SizedBox(height: 4),
                    Text(
                      '${formatMoney(totalSpentOnBudgeted)} / ${formatMoney(totalBudget)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < cats.length; i++) ...[
                    BudgetBar(
                      category: cats[i].name,
                      spent: p.spentFor(cats[i].name),
                      limit: p.budgetFor(cats[i].name),
                      onTap: () => _editBudget(context, cats[i].name),
                    ),
                    if (i < cats.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'งบประมาณเป็นวงเงินรายเดือน แตะที่หมวดหมู่เพื่อตั้งหรือแก้ไข',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editBudget(BuildContext context, String category) async {
    final p = context.read<TransactionProvider>();
    final existing = p.budgetFor(category);
    final ctrl = TextEditingController(
        text: existing == null ? '' : existing.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('งบรายเดือน: ${Categories.find(category, TransactionType.expense).label}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(labelText: 'วงเงิน', prefixText: '฿ '),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              return (n == null || n <= 0) ? 'กรุณากรอกจำนวนเงินที่มากกว่า 0' : null;
            },
          ),
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () {
                p.removeBudget(category);
                Navigator.pop(ctx);
              },
              child: const Text('ลบงบ'),
            ),
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              p.setBudget(category, double.parse(ctrl.text));
              Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }
}
