import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/money.dart';
import '../../../../core/providers/active_budget_provider.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/category_provider.dart';
import 'widgets/amount_conversion_hint.dart';
import 'widgets/emotion_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  static const _currencies = ['USD', 'EUR', 'HUF', 'CAD'];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  /// Null until the user picks a currency explicitly; the form then defaults to
  /// the profile's main currency (T056) instead of hardcoded USD, so a HUF
  /// expense can never be silently recorded as USD.
  String? _currency;
  String _categoryId = Expense.defaultCategoryId;
  ExpenseStatus _status = ExpenseStatus.paid;
  bool _isReimbursable = false;
  GuiltLevel _guiltLevel = GuiltLevel.essential;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so the live conversion hint below the Amount
    // field tracks the input (T056).
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  static double? _parseAmount(String? raw) =>
      double.tryParse((raw ?? '').replaceAll(RegExp(r'[,\s]'), ''));

  /// The currency the form records in: the user's pick, or the profile's main
  /// currency until the user picks (T056).
  String get _effectiveCurrency =>
      _currency ?? ref.read(mainCurrencyProvider).code.toUpperCase();

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = _parseAmount(_amountController.text) ?? 0.0;
      final profile = ref.read(activeProfileProvider).value;
      final budget = ref.read(activeBudgetProvider).value;

      if (profile == null || budget == null) return;

      final code =
          CurrencyCode.tryParse(_effectiveCurrency) ?? CurrencyCode.huf;
      final expense = Expense(
        profileId: profile.id,
        yearMonth: budget.yearMonth,
        title: _titleController.text,
        amount: Money.fromMajor(amount, code).minorUnits,
        currency: code.code.toUpperCase(),
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
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final main = ref.watch(mainCurrencyProvider);
    final display = resolveDisplayCurrency(month: budget, profile: profile);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);

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
                        final v = _parseAmount(value);
                        if (v == null) return 'Invalid amount';
                        if (v <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_effectiveCurrency),
                      initialValue: _effectiveCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies
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
              AmountConversionHint(
                amount: _parseAmount(_amountController.text),
                currency: CurrencyCode.tryParse(_effectiveCurrency),
                display: display,
                main: main,
                table: table,
              ),
              const SizedBox(height: 16),
              ref.watch(categoriesProvider).when(
                    data: (categories) => DropdownButtonFormField<String>(
                      initialValue: _categoryId,
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
