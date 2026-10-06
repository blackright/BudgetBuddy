import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/monthly_budget.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../repositories/month_finance_repository.dart';

class OpeningBalanceSheet extends ConsumerStatefulWidget {
  const OpeningBalanceSheet({super.key, this.initialBudget});

  final MonthlyBudget? initialBudget;

  @override
  ConsumerState<OpeningBalanceSheet> createState() =>
      _OpeningBalanceSheetState();
}

class _OpeningBalanceSheetState extends ConsumerState<OpeningBalanceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialBudget?.baseAvailableAmount ?? 0.0;
    _balanceController = TextEditingController(
      text: widget.initialBudget?.openingBalanceConfirmed == true
          ? initial.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Opening Balance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Money in the bank at the start of this month.'),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('openingBalanceField'),
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed < 0) return 'Cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_balanceController.text.trim());
    final yearMonth = ref.read(selectedYearMonthProvider);
    await ref
        .read(monthFinanceRepositoryProvider)
        .saveOpeningBalance(yearMonth, amount);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
