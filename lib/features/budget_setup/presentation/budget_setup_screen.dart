import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_profile.dart';
import '../providers/budget_setup_provider.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill logic (T015)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(budgetSetupProvider.notifier).loadAutoFillData();
      final state = ref.read(budgetSetupProvider);
      if (state.amount != null) {
        _amountController.text = state.amount.toString();
      }
      if (state.yearMonth != null) {
        try {
          final parts = state.yearMonth!.split('-');
          if (parts.length == 2) {
            final month = int.parse(parts[1]);
            _monthController.text = '${monthNames[month - 1]} ${parts[0]}';
          } else {
            _monthController.text = state.yearMonth!;
          }
        } catch (_) {
          _monthController.text = state.yearMonth!;
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetSetupProvider);
    final notifier = ref.read(budgetSetupProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withValues(alpha: 0.1),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly Available Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null) {
                  notifier.setAmount(amount);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PrimaryCurrency>(
              decoration: const InputDecoration(
                labelText: 'Primary Currency',
                border: OutlineInputBorder(),
              ),
              initialValue: state.currency,
              items: PrimaryCurrency.values.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notifier.setCurrency(value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _monthController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Target Month',
                border: OutlineInputBorder(),
                hintText: 'Select a month',
                suffixIcon: Icon(Icons.calendar_month),
              ),
              onTap: () async {
                final now = DateTime.now();
                final initialDate = state.yearMonth != null
                    ? DateTime.tryParse('${state.yearMonth}-01') ?? now
                    : now;
                final date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final year = date.year.toString();
                  final month = date.month.toString().padLeft(2, '0');
                  final yearMonth = '$year-$month';

                  notifier.setYearMonth(yearMonth);

                  _monthController.text =
                      '${monthNames[date.month - 1]} ${date.year}';
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: state.isSaving
                  ? null
                  : () async {
                      final success = await notifier.saveBudget();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Budget saved successfully')),
                        );
                        context.go('/dashboard');
                      }
                    },
              child: state.isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
