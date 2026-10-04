import 'package:flutter/material.dart';

class AddExpensePlaceholder extends StatelessWidget {
  const AddExpensePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: const Center(child: Text('Add Expense Dummy')),
    );
  }
}
