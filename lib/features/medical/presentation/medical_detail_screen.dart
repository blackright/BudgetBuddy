import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/medical_bill.dart';
import '../providers/medical_providers.dart';
import '../repositories/medical_repository.dart';
import 'medical_theme.dart';

/// Detail + lifecycle view for a single medical bill (T017).
///
/// Everything that changes budget state lives here so the two lifecycles —
/// provider payment (`Expense.status`) and insurance claim ([ClaimStatus]) —
/// are never conflated (research.md §2).
class MedicalDetailScreen extends ConsumerWidget {
  const MedicalDetailScreen({super.key, required this.billId});

  final int billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(medicalBillProvider(billId));

    return billAsync.when(
      data: (bill) {
        if (bill == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Medical Bill')),
            body: const Center(
                child: Text('This medical bill no longer exists.')),
          );
        }
        return _DetailScaffold(bill: bill);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Medical Bill')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Medical Bill')),
        body: Center(child: Text('Could not load this bill: $error')),
      ),
    );
  }
}

class _DetailScaffold extends ConsumerWidget {
  const _DetailScaffold({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = MedicalTheme.background(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Medical Bill'),
        backgroundColor: background,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit_medical_bill', extra: bill.id),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(bill: bill),
            const SizedBox(height: 16),
            _InsuranceBreakdown(bill: bill),
            const SizedBox(height: 16),
            _ProviderPaymentSection(bill: bill),
            const SizedBox(height: 16),
            _ClaimStatusSection(bill: bill),
            const SizedBox(height: 16),
            _FollowUpSection(bill: bill),
            if (bill.attachmentPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              _AttachmentsCard(bill: bill),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(medicalRepositoryProvider);

    // A reimbursed bill already moved budget history, so warn before removing.
    final isReimbursed = bill.claimStatus == ClaimStatus.reimbursed;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this bill?'),
        content: Text(
          isReimbursed
              ? 'This bill has a logged reimbursement of '
                  '${bill.reimbursedAmount.toStringAsFixed(2)}. Deleting it '
                  'also removes that reimbursement from your available budget.'
              : 'The bill and its linked expense will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repo.deleteBill(bill.id, force: isReimbursed);
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Medical bill deleted')));
      if (router.canPop()) {
        router.pop();
      }
    } on ReimbursedBillDeletionException catch (error) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

class _HeaderSection extends ConsumerWidget {
  const _HeaderSection({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(medicalDirectoryProvider);
    final symbol = ref.watch(medicalCurrencySymbolProvider);
    final provider = directory.providerName(bill.providerId);
    final patient = directory.memberName(bill.familyMemberId);
    final statusColor =
        MedicalTheme.claimStatusColor(context, bill.claimStatus);

    return Card(
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(
                MedicalTheme.claimStatusIcon(bill.claimStatus),
                color: statusColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider ?? 'Medical Bill',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              <String>[
                if (patient != null) patient,
                if (bill.serviceDate != null)
                  DateFormat.yMMMd().format(bill.serviceDate!),
              ].join(' · '),
              style: TextStyle(color: MedicalTheme.subtleText(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              MedicalTheme.money(symbol, bill.billedAmount),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(
                MedicalTheme.claimStatusIcon(bill.claimStatus),
                size: 18,
                color: statusColor,
              ),
              label: Text('Claim: ${bill.claimStatus.label}'),
              backgroundColor: statusColor.withValues(alpha: 0.15),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Insurance breakdown
// -----------------------------------------------------------------------------

class _InsuranceBreakdown extends ConsumerWidget {
  const _InsuranceBreakdown({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(medicalCurrencySymbolProvider);

    return _SectionCard(
      title: 'Insurance Breakdown',
      child: Column(
        children: [
          _MoneyRow(
            label: 'Billed amount',
            value: MedicalTheme.money(symbol, bill.billedAmount),
          ),
          _MoneyRow(
            label: 'Insurance covered '
                '(${bill.insuranceCoveragePercent.toStringAsFixed(0)}%)',
            value: MedicalTheme.money(symbol, bill.insuranceCoveredAmount),
            color: Colors.green,
          ),
          _MoneyRow(
            label: 'Estimated out-of-pocket',
            value: MedicalTheme.money(symbol, bill.estimatedOutPocket),
            color: Colors.orange,
          ),
          if (bill.reimbursedAmount > 0)
            _MoneyRow(
              label: 'Reimbursed',
              value: '+${MedicalTheme.money(symbol, bill.reimbursedAmount)}',
              color: Colors.green,
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net cost to you',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MedicalTheme.subtleText(context),
                ),
              ),
              Text(
                MedicalTheme.money(symbol, bill.netOutOfPocket),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Provider payment (T018)
// -----------------------------------------------------------------------------

class _ProviderPaymentSection extends ConsumerWidget {
  const _ProviderPaymentSection({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(medicalExpenseStatusesProvider).value ??
        const <int, ExpenseStatus>{};
    final symbol = ref.watch(medicalCurrencySymbolProvider);
    final paid = isPaidToProvider(bill, statuses);

    return _SectionCard(
      title: 'Provider Payment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                paid ? 'Paid' : 'Planned',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: paid ? Colors.green : Colors.orange,
                ),
              ),
              Text(
                paid
                    ? '${MedicalTheme.money(symbol, bill.billedAmount)} left your account'
                    : 'Not counted against your budget yet',
                style: TextStyle(
                  fontSize: 12,
                  color: MedicalTheme.subtleText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _toggle(context, ref, paid: !paid),
            icon: Icon(paid ? Icons.schedule : Icons.check_circle),
            label: Text(
                paid ? 'Move back to Planned' : 'Mark as Paid to Provider'),
            style: FilledButton.styleFrom(
              backgroundColor: paid ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref, {
    required bool paid,
  }) async {
    final billContext = ref.read(medicalBillContextProvider);
    if (billContext == null) {
      _toast(context, 'No active budget, so this cannot change your balance.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final delta = await ref
          .read(medicalRepositoryProvider)
          .setBillPaidToProvider(bill, billContext, paid: paid);
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            paid
                ? 'Marked as paid. Available drops by '
                    '${delta.trueAvailableDelta.abs().toStringAsFixed(2)} 💸'
                : 'Moved back to planned. Available restored ✅',
          ),
        ));
    } catch (error) {
      if (!context.mounted) return;
      _toast(context, 'Could not update the payment: $error');
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// -----------------------------------------------------------------------------
// Claim status (T019 / T021)
// -----------------------------------------------------------------------------

class _ClaimStatusSection extends ConsumerWidget {
  const _ClaimStatusSection({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Insurance Claim',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (bill.claimStatus != ClaimStatus.processing)
                OutlinedButton.icon(
                  onPressed: () =>
                      _setStatus(context, ref, ClaimStatus.processing),
                  icon: const Icon(Icons.autorenew, size: 18),
                  label: const Text('Filed'),
                ),
              if (bill.claimStatus != ClaimStatus.denied)
                OutlinedButton.icon(
                  onPressed: () => _setStatus(context, ref, ClaimStatus.denied),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Denied'),
                ),
              FilledButton.icon(
                onPressed: () => _logReimbursement(context, ref),
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text(
                  bill.claimStatus == ClaimStatus.reimbursed
                      ? 'Update Reimbursement'
                      : 'Log Reimbursement',
                ),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _statusHint(bill.claimStatus),
            style: TextStyle(
              fontSize: 12,
              color: MedicalTheme.subtleText(context),
            ),
          ),
        ],
      ),
    );
  }

  static String _statusHint(ClaimStatus status) => switch (status) {
        ClaimStatus.unclaimed =>
          'Not submitted to insurance yet. Filing it does not change your budget.',
        ClaimStatus.processing =>
          'Insurance is reviewing this bill. Your budget stays as-is until a payout.',
        ClaimStatus.reimbursed =>
          'The payout is added back to your available budget.',
        ClaimStatus.denied =>
          'Insurance declined this bill, so there is no payout to expect.',
      };

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    ClaimStatus status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(medicalRepositoryProvider)
          .updateClaimStatus(bill, status: status);
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Claim marked ${status.label}')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the claim: $error')),
      );
    }
  }

  /// FR-005: the payout is injected into the budget via a reimbursement row.
  Future<void> _logReimbursement(BuildContext context, WidgetRef ref) async {
    final symbol = ref.read(medicalCurrencySymbolProvider);
    final controller = TextEditingController(
      text: bill.reimbursedAmount > 0
          ? bill.reimbursedAmount.toStringAsFixed(2)
          : bill.insuranceCoveredAmount.toStringAsFixed(2),
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Reimbursement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How much did insurance pay you? This amount is added back to your '
              'available budget.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$symbol ',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (amount == null || amount <= 0) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(medicalRepositoryProvider)
          .logReimbursement(bill, amount: amount);
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            'Reimbursement logged. Available up by '
            '${MedicalTheme.money(symbol, amount)} 💰',
          ),
        ));
    } catch (error) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not log it: $error')));
    }
  }
}

// -----------------------------------------------------------------------------
// Follow-up reminder (T020)
// -----------------------------------------------------------------------------

class _FollowUpSection extends ConsumerWidget {
  const _FollowUpSection({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFollowUp = bill.followUpDate != null;

    return _SectionCard(
      title: 'Follow-up Reminder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hasFollowUp
                ? 'Check back ${DateFormat.yMMMd().format(bill.followUpDate!)}.'
                : 'No reminder set for this claim yet.',
            style: TextStyle(color: MedicalTheme.subtleText(context)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(context, ref),
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: Text(hasFollowUp ? 'Change date' : 'Set reminder'),
                ),
              ),
              if (hasFollowUp) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear reminder',
                  icon: const Icon(Icons.close),
                  onPressed: () => ref
                      .read(medicalRepositoryProvider)
                      .setFollowUpDate(bill, null),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: bill.followUpDate ?? now.add(const Duration(days: 14)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    await ref.read(medicalRepositoryProvider).setFollowUpDate(bill, picked);
  }
}

// -----------------------------------------------------------------------------
// Attachments
// -----------------------------------------------------------------------------

class _AttachmentsCard extends ConsumerWidget {
  const _AttachmentsCard({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Attachments',
      child: Column(
        children: [
          for (final path in bill.attachmentPaths)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(
                path.split(RegExp(r'[/\\]')).last,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared shell
// -----------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
