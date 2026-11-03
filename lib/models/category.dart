import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class AppCategory {
  /// Stable key stored in the database (do not translate).
  final String name;

  /// Thai label shown in the UI.
  final String label;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const AppCategory(this.name, this.label, this.icon, this.color, this.type);
}

class Categories {
  static const expense = <AppCategory>[
    AppCategory('Food', 'อาหาร', Icons.restaurant_rounded, Color(0xFFFF8A65), TransactionType.expense),
    AppCategory('Travel', 'เดินทาง', Icons.flight_takeoff_rounded, Color(0xFF4FC3F7), TransactionType.expense),
    AppCategory('Shopping', 'ช้อปปิ้ง', Icons.shopping_bag_rounded, Color(0xFFBA68C8), TransactionType.expense),
    AppCategory('Bills', 'ค่าบิล', Icons.receipt_long_rounded, Color(0xFFFFB74D), TransactionType.expense),
    AppCategory('Health', 'สุขภาพ', Icons.favorite_rounded, Color(0xFFE57373), TransactionType.expense),
    AppCategory('Entertainment', 'บันเทิง', Icons.movie_rounded, Color(0xFF7986CB), TransactionType.expense),
    AppCategory('Other', 'อื่นๆ', Icons.more_horiz_rounded, Color(0xFF90A4AE), TransactionType.expense),
  ];

  static const income = <AppCategory>[
    AppCategory('Salary', 'เงินเดือน', Icons.payments_rounded, Color(0xFF66BB6A), TransactionType.income),
    AppCategory('Freelance', 'งานอิสระ', Icons.laptop_mac_rounded, Color(0xFF26A69A), TransactionType.income),
    AppCategory('Gift', 'ของขวัญ', Icons.card_giftcard_rounded, Color(0xFFF06292), TransactionType.income),
    AppCategory('Investment', 'การลงทุน', Icons.trending_up_rounded, Color(0xFF9CCC65), TransactionType.income),
    AppCategory('Other', 'อื่นๆ', Icons.more_horiz_rounded, Color(0xFF90A4AE), TransactionType.income),
  ];

  static List<AppCategory> forType(TransactionType t) =>
      t == TransactionType.income ? income : expense;

  static AppCategory find(String name, TransactionType type) {
    final list = forType(type);
    return list.firstWhere((c) => c.name == name, orElse: () => list.last);
  }
}
