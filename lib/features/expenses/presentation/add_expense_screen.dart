import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/providers/active_budget_provider.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/category_provider.dart';
import 'widgets/emotion_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _currency = 'USD';
  String _categoryId = Expense.defaultCategoryId;
  ExpenseStatus _status = ExpenseStatus.paid;
  bool _isReimbursable = false;
  GuiltLevel _guiltLevel = GuiltLevel.essential;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final profile = ref.read(activeProfileProvider).value;
      final budget = ref.read(activeBudgetProvider).value;

      if (profile == null || budget == null) return;

      final expense = Expense(
        profileId: profile.id,
        yearMonth: budget.yearMonth,
        title: _titleController.text,
        amount: amount,
        currency: _currency,
        categoryId: _categoryId,
        status: _status,
        isReimbursable: _isReimbursable,
        guiltLevel: _guiltLevel,
        date: DateTime.now(),
        budgetId: budget.id,
      );

      ref.read(expensesProvider.notifier).addExpense(expense);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'What did you buy?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null)
                          return 'Invalid amount';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: ['USD', 'EUR', 'GBP', 'HUF', 'CAD']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _currency = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ref.watch(categoriesProvider).when(
                    data: (categories) => DropdownButtonFormField<String>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.categoryId,
                                child: Text('${c.emoji} ${c.name}'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _categoryId = val);
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading categories'),
                  ),
              const SizedBox(height: 16),
              SegmentedButton<ExpenseStatus>(
                segments: const [
                  ButtonSegment(value: ExpenseStatus.paid, label: Text('Paid')),
                  ButtonSegment(
                      value: ExpenseStatus.planned, label: Text('Planned')),
                ],
                selected: {_status},
                onSelectionChanged: (Set<ExpenseStatus> newSelection) {
                  setState(() {
                    _status = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is this reimbursable?'),
                value: _isReimbursable,
                onChanged: (val) => setState(() => _isReimbursable = val),
              ),
              const SizedBox(height: 16),
              const Text('How did you feel about this?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              EmotionSelector(
                selectedLevel: _guiltLevel,
                onSelected: (level) => setState(() => _guiltLevel = level),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
