import 'package:flutter/material.dart';

import '../utils/format.dart';

class BalanceCard extends StatelessWidget {
  final String label;
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    this.label = 'ยอดคงเหลือ',
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B3FD6), Color(0xFF9B6BF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EFF).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _mini(Icons.arrow_downward_rounded, 'รายรับ', income,
                    const Color(0xFF8CF2B5)),
              ),
              Expanded(
                child: _mini(Icons.arrow_upward_rounded, 'รายจ่าย', expense,
                    const Color(0xFFFFA8A8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(IconData icon, String label, double value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatMoney(value),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
