# Expense Tracker (Flutter)

A clean, minimalist personal expense tracker with local SQLite storage.

## Features
- **Dashboard** – balance, total income/expenses, spending pie chart, 7-day bar chart, recent items
- **Transactions** – grouped by day, filter All/Income/Expense, tap to edit, swipe to delete (with Undo)
- **Add / edit form** – amount, type, category, date, note
- **Local storage** – SQLite via `sqflite`; data persists across restarts

- **Month filter** – ‹ › arrows or tap the month to pick any past month; dashboard, charts and list follow it
- **Category budgets** – monthly limit per expense category (stored in SQLite), progress bars turn orange at 80% and red when over

## Run
```bash
flutter create . --platforms=android,ios   # generates android/ios folders (keeps lib/ and pubspec.yaml)
flutter pub get
flutter run
```

## Structure
```
lib/
├── main.dart
├── db/database_helper.dart
├── models/{category,transaction_item}.dart
├── providers/transaction_provider.dart
├── screens/{home,dashboard,transactions,add_transaction}_screen.dart
├── utils/format.dart
└── widgets/{balance_card,expense_pie_chart,weekly_bar_chart,transaction_tile}.dart
```

Currency symbol is set in `lib/utils/format.dart` (default `฿`) and in the amount field of `add_transaction_screen.dart`.
