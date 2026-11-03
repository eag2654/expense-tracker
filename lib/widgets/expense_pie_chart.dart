import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../utils/format.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> data;
  const ExpensePieChart({super.key, required this.data});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('ยังไม่มีรายจ่าย')),
      );
    }
    final entries = widget.data.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 52,
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) {
                  setState(() {
                    _touched = (!event.isInterestedForInteractions ||
                            resp?.touchedSection == null)
                        ? -1
                        : resp!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: Categories.find(entries[i].key, TransactionType.expense).color,
                    radius: i == _touched ? 38 : 30,
                    title: i == _touched
                        ? '${(entries[i].value / total * 100).toStringAsFixed(0)}%'
                        : '',
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            for (final e in entries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Categories.find(e.key, TransactionType.expense).color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${Categories.find(e.key, TransactionType.expense).label}  ${formatCompact(e.value)}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
