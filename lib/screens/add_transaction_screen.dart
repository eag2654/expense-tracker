import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../utils/format.dart';

class AddTransactionScreen extends StatefulWidget {
  /// When provided, the form edits this transaction instead of creating one.
  final TransactionItem? existing;
  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late TransactionType _type;
  late String _category;
  late DateTime _date;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TransactionType.expense;
    _category = e?.category ?? Categories.forType(_type).first.name;
    _date = e?.date ?? DateTime.now();
    _amountCtrl = TextEditingController(
        text: e == null ? '' : e.amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = TransactionItem(
      id: widget.existing?.id,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      type: _type,
      category: _category,
      note: _noteCtrl.text.trim(),
      date: _date,
    );
    final provider = context.read<TransactionProvider>();
    final nav = Navigator.of(context);
    if (_editing) {
      await provider.edit(item);
    } else {
      await provider.add(item);
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categories = Categories.forType(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'แก้ไขรายการ' : 'เพิ่มรายการ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('รายจ่าย'),
                  icon: Icon(Icons.arrow_upward_rounded),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('รายรับ'),
                  icon: Icon(Icons.arrow_downward_rounded),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = Categories.forType(_type).first.name;
              }),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountCtrl,
              autofocus: !_editing,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                labelText: 'จำนวนเงิน',
                prefixText: '฿ ',
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', ''));
                if (n == null || n <= 0) return 'กรุณากรอกจำนวนเงินที่มากกว่า 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('หมวดหมู่',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  ChoiceChip(
                    avatar: Icon(c.icon,
                        size: 18,
                        color: _category == c.name ? scheme.onSecondaryContainer : c.color),
                    label: Text(c.label),
                    selected: _category == c.name,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = c.name),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'วันที่',
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
                child: Text(formatDate(_date)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'บันทึกเพิ่มเติม (ไม่บังคับ)'),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(_editing ? 'บันทึกการแก้ไข' : 'บันทึกรายการ'),
            ),
          ],
        ),
      ),
    );
  }
}
