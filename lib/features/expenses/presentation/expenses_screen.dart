import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Expenses Placeholder'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/expenses/add'),
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
