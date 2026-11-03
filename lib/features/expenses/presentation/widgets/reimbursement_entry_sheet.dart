import '../../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/money.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/widgets/money_field.dart';
import '../../providers/reimbursement_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../models/reimbursement.dart';

class ReimbursementEntrySheet extends ConsumerStatefulWidget {
  final Expense expense;

  const ReimbursementEntrySheet({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<ReimbursementEntrySheet> createState() =>
      _ReimbursementEntrySheetState();
}

class _ReimbursementEntrySheetState
    extends ConsumerState<ReimbursementEntrySheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  late String _currency;

  @override
  void initState() {
    super.initState();
    // Bill-sourced expenses store lowercase codes while the dropdown items are
    // uppercase; normalize so the seeded value always matches an item (T055-era
    // case handling exposed this as a `DropdownButtonFormField` assert).
    _currency =
        (CurrencyCode.tryParse(widget.expense.currency) ?? CurrencyCode.huf)
            .code
            .toUpperCase();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _medical => widget.expense.type == ExpenseType.medical;

  Future<void> _submit(int maxAllowed) async {
    if (_medical) return;
    final amount = parseMoneyInput(_amountController.text);
    if (amount == null || amount <= 0) return;

    final expenseCode =
        CurrencyCode.tryParse(widget.expense.currency) ?? CurrencyCode.huf;
    final enteredCode = CurrencyCode.tryParse(_currency) ?? expenseCode;
    final amountMinor = Money.fromMajor(amount, enteredCode).minorUnits;

    if (enteredCode == expenseCode && amountMinor > maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Amount cannot exceed ${formatMoney(Money(maxAllowed, expenseCode))}')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reimbursement = Reimbursement(
        profileId: widget.expense.profileId,
        sharedSpaceId: widget.expense.sharedSpaceId,
        expenseId: widget.expense.id,
        originYearMonth: widget.expense.yearMonth,
        amount: amountMinor,
        currency: _currency,
        date: DateTime.now(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      final repo = ref.read(reimbursementRepositoryProvider);
      await repo.addReimbursement(reimbursement);

      // US2: Update status to partial or fully reimbursed
      final expenseRepo = ref.read(expenseRepositoryProvider);

      final isFullyReimbursed = (maxAllowed - amountMinor).abs() <= 1;

      widget.expense.status = isFullyReimbursed
          ? ExpenseStatus.reimbursed
          : ExpenseStatus.partiallyReimbursed;

      await expenseRepo.updateExpense(widget.expense);

      if (mounted) {
        showFinancialFeedback(context, 'Reimbursement recorded');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        showFinancialFeedback(context,
            'Reimbursement could not finish. Review its current status before retrying.',
            kind: FinancialFeedbackKind.error);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_medical) {
      return const SafeArea(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'Record insurance refunds and salary deductions in the Medical bill. '
                  'This generic reimbursement form is only for non-medical expenses.')));
    }
    final reimbursementsAsync =
        ref.watch(reimbursementsByExpenseProvider(widget.expense.id));

    return reimbursementsAsync.when(
      data: (reimbursements) {
        final expenseCode =
            CurrencyCode.tryParse(widget.expense.currency) ?? CurrencyCode.huf;
        var currentTotal = 0;
        for (final r in reimbursements) {
          currentTotal += r.amount;
        }

        var maxAllowed = widget.expense.amount - currentTotal;

        if (maxAllowed <= 0) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('This expense is already fully reimbursed.'),
          );
        }

        return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Record Reimbursement',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Max: ${formatMoney(Money(maxAllowed, expenseCode))}',
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: MoneyField(
                          key: const Key('reimbursementAmountField'),
                          controller: _amountController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            border: OutlineInputBorder(),
                          ),
                          items: CurrencyCode.values
                              .map((c) => DropdownMenuItem(
                                  value: c.code.toUpperCase(),
                                  child: Text(c.code.toUpperCase())))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _currency = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submit(maxAllowed),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Save Reimbursement'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )));
      },
      loading: () => const SizedBox(
          height: 100, child: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          SizedBox(height: 100, child: Center(child: Text('Error: $e'))),
    );
  }
}
