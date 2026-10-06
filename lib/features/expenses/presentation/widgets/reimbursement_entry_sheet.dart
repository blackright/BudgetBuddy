import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/expense.dart';
import '../../providers/reimbursement_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../models/reimbursement.dart';

import '../../../../core/models/medical_bill.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../../../medical/providers/medical_providers.dart';

class ReimbursementEntrySheet extends ConsumerStatefulWidget {
  final Expense expense;
  final MedicalBill? medicalBill;

  const ReimbursementEntrySheet({
    super.key,
    required this.expense,
    this.medicalBill,
  });

  @override
  ConsumerState<ReimbursementEntrySheet> createState() => _ReimbursementEntrySheetState();
}

class _ReimbursementEntrySheetState extends ConsumerState<ReimbursementEntrySheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  late String _currency;
  
  @override
  void initState() {
    super.initState();
    _currency = widget.expense.currency;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(double maxAllowed) async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    if (_currency == widget.expense.currency && amount > maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Amount cannot exceed ${NumberFormat('#,##0.00').format(maxAllowed)}')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reimbursement = Reimbursement(
        profileId: widget.expense.profileId,
        expenseId: widget.expense.id,
        originYearMonth: widget.expense.yearMonth,
        amount: amount,
        currency: _currency,
        date: DateTime.now(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      final repo = ref.read(reimbursementRepositoryProvider);
      final primaryCurrency = ref.read(activeProfileProvider).value?.primaryCurrency.name.toUpperCase() ?? 'USD';
      await repo.addReimbursement(reimbursement, primaryCurrency);

      // US2: Update status to partial or fully reimbursed
      final expenseRepo = ref.read(expenseRepositoryProvider);
      
      // If the new total (amount + previous total) is essentially equal to the expense amount
      // Due to double precision, we check with a small epsilon
      final isFullyReimbursed = (maxAllowed - amount).abs() < 0.01;
      
      widget.expense.status = isFullyReimbursed 
          ? ExpenseStatus.reimbursed 
          : ExpenseStatus.partiallyReimbursed;
          
      await expenseRepo.updateExpense(widget.expense, 'USD');

      if (widget.medicalBill != null) {
        final medicalRepo = ref.read(medicalRepositoryProvider);
        final allReimbursements = await repo.getReimbursementsForExpense(widget.expense.id);
        final newTotal = allReimbursements.fold(0.0, (sum, r) => sum + r.amount);
        
        await medicalRepo.updateMedicalBillReimbursement(
          widget.medicalBill!, 
          newTotal
        );
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reimbursementsAsync = ref.watch(reimbursementsByExpenseProvider(widget.expense.id));

    return reimbursementsAsync.when(
      data: (reimbursements) {
        double currentTotal = 0;
        for (final r in reimbursements) {
          currentTotal += r.amount;
        }
        
        double maxAllowed = widget.expense.amount - currentTotal;
        
        if (widget.medicalBill != null) {
           // For medical bills, max is the insurer's share (billed amount - patient share)
           // But since expense.amount is the full charge for self-paid,
           // the actual maximum expected reimbursement is the insurerPaidAmount.
           final maxExpected = widget.medicalBill!.insurerPaidAmount - currentTotal;
           // We cap at maxAllowed (which is the expense amount) but show expected.
           maxAllowed = maxExpected;
        }
        
        if (maxAllowed <= 0) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('This expense is already fully reimbursed.'),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Max: ${NumberFormat('#,##0.00').format(maxAllowed)} ${widget.expense.currency}',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (widget.medicalBill != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Insurer portion: ${NumberFormat('#,##0.00').format(widget.medicalBill!.insurerPaidAmount)}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      autofocus: true,
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
                      items: ['USD', 'EUR', 'GBP', 'HUF', 'CAD']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => SizedBox(height: 100, child: Center(child: Text('Error: $e'))),
    );
  }
}
