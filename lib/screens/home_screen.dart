import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final loading = context.select<TransactionProvider, bool>((p) => p.loading);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _index == 0 ? 'แดชบอร์ด' : 'รายการ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'งบประมาณ',
            icon: const Icon(Icons.savings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BudgetScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _index,
              children: [
                DashboardScreen(onSeeAll: () => setState(() => _index = 1)),
                const TransactionsScreen(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่ม'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'แดชบอร์ด'),
          NavigationDestination(
              icon: Icon(Icons.list_alt_rounded),
              selectedIcon: Icon(Icons.list_alt_rounded),
              label: 'รายการ'),
        ],
      ),
    );
  }
}
