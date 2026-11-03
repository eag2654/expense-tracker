import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/format.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<({DateTime day, double income, double expense})> data;
  const WeeklyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .fold(0.0, (a, b) => a > b ? a : b);
    if (maxY == 0) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('ไม่มีรายการใน 7 วันที่ผ่านมา')),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final d = data[v.toInt()].day;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(formatWeekday(d),
                        style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                formatCompact(rod.toY),
                const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: data[i].income,
                    width: 8,
                    color: const Color(0xFF4CAF82),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: data[i].expense,
                    width: 8,
                    color: const Color(0xFFEF6B6B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
