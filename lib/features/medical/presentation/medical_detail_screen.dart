import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:timezone/timezone.dart' as tz;
import 'package:add_2_calendar/add_2_calendar.dart' as a2c;

import '../../../core/models/medical_bill.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/widgets/degraded_amount_label.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../providers/medical_providers.dart';
import '../repositories/medical_repository.dart';
import 'medical_theme.dart';

import '../../expenses/presentation/widgets/reimbursement_entry_sheet.dart'
    as entry;
import '../../expenses/presentation/widgets/reimbursement_history_list.dart';
import '../../expenses/repositories/expense_repository.dart';
import 'reminder_picker_sheet.dart';

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
            _PaymentMethodSection(bill: bill),
            const SizedBox(height: 16),
            _BillStateSection(bill: bill),
            // A paid or finished claim has nothing left to chase, so the
            // reminder would only be noise.
            if (bill.state != MedicalBillState.paid &&
                bill.state != MedicalBillState.finished) ...[
              const SizedBox(height: 16),
              _FollowUpSection(bill: bill),
            ],
            if (bill.billPhotoPath != null ||
                bill.insurerReplyPath != null) ...[
              const SizedBox(height: 16),
              _DocumentsCard(bill: bill),
            ],
            if (bill.linkedExpenseId != null) ...[
              const SizedBox(height: 16),
              ReimbursementHistoryList(expenseId: bill.linkedExpenseId!),
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
    final currency = ref.read(medicalDisplayCurrencyProvider);

    // A reimbursed bill already moved budget history, so warn before removing.
    final isReimbursed = bill.reimbursedAmount > 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this bill?'),
        content: Text(
          isReimbursed
              ? 'This bill has a logged reimbursement of '
                  '${MedicalTheme.moneyMinor(bill.currencyCode ?? currency, bill.reimbursedAmount)}. Deleting it '
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
    final currency = ref.watch(medicalDisplayCurrencyProvider);
    final provider = directory.providerName(bill.providerId);
    final patient = directory.memberName(bill.familyMemberId);
    final stateColor = MedicalTheme.billStateColor(context, bill.state);

    return Card(
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: stateColor.withValues(alpha: 0.2),
              child: Icon(
                MedicalTheme.billStateIcon(bill.state),
                color: stateColor,
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
              MedicalTheme.moneyMinor(
                  bill.currencyCode ?? currency, bill.billedAmount),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // FR-042: state and payment method are the two labels that matter
            // now; the old single "Claim" chip conflated them.
            Chip(
              avatar: Icon(
                MedicalTheme.billStateIcon(bill.state),
                size: 18,
                color: stateColor,
              ),
              label: Text(bill.state.label),
              backgroundColor: stateColor.withValues(alpha: 0.15),
              side: BorderSide.none,
            ),
            const SizedBox(height: 8),
            Chip(
              avatar:
                  const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(bill.paymentMethod.label),
              backgroundColor:
                  MedicalTheme.subtleText(context).withValues(alpha: 0.15),
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
    final currency = ref.watch(medicalDisplayCurrencyProvider);
    final billCurrency = bill.currencyCode ?? currency;

    return _SectionCard(
      title: 'Insurance Breakdown',
      child: Column(
        children: [
          _MoneyRow(
            label: 'Billed amount',
            value: MedicalTheme.moneyMinor(billCurrency, bill.billedAmount),
          ),
          // FR-048: the user-facing share, with the insurer's complement shown
          // rather than a second percentage the user never entered.
          _MoneyRow(
            label: 'Insurer pays '
                '(${(100 - bill.patientSharePercent).toStringAsFixed(0)}%)',
            value:
                MedicalTheme.moneyMinor(billCurrency, bill.insurerPaidAmount),
            color: Colors.green,
          ),
          _MoneyRow(
            label: 'Your share '
                '(${bill.patientSharePercent.toStringAsFixed(0)}%)',
            value:
                MedicalTheme.moneyMinor(billCurrency, bill.patientShareAmount),
            color: Colors.orange,
          ),
          if (bill.reimbursedAmount > 0)
            _MoneyRow(
              label: 'Reimbursed',
              value:
                  '+${MedicalTheme.moneyMinor(billCurrency, bill.reimbursedAmount)}',
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
                MedicalTheme.moneyMinor(billCurrency, bill.netOutOfPocket),
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
// Payment method (FR-041)
// -----------------------------------------------------------------------------

/// Switching between insurer-paid and self-paid.
///
/// The method decides what the bill costs the budget, so changing it re-syncs
/// the linked expense through the repository rather than editing it locally.
class _PaymentMethodSection extends ConsumerWidget {
  const _PaymentMethodSection({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(medicalDisplayCurrencyProvider);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final insurerPaid = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;

    // The money-impact figure is quoted in the bill's own currency; when the
    // bill is foreign, show the converted budget figure with the original
    // beside it (FR-002, FR-016). A missing rate surfaces the original with an
    // explicit unavailable label rather than a fabricated value (FR-014).
    final impactOriginal =
        Money(bill.fundsImpact, bill.currencyCode ?? currency);
    final impactConversion = ref.watch(rateRegistryProvider).convert(
          amount: impactOriginal,
          to: currency,
          yearMonth: yearMonth,
        );

    return _SectionCard(
      title: 'Payment Method',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            insurerPaid
                ? 'The insurer was billed directly. Only your share affects '
                    'this month, and there is nothing to claim back.'
                : 'You paid in full, so the whole charge left your budget until a '
                    'reimbursement is recorded.',
            style: TextStyle(color: MedicalTheme.subtleText(context)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bill.paymentMethod.label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DegradedAmountLabel(
                      original: impactOriginal,
                      result: impactConversion,
                      style: TextStyle(
                        fontSize: 12,
                        color: MedicalTheme.subtleText(context),
                      ),
                    ),
                    Text(
                      ' left your budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: MedicalTheme.subtleText(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<MedicalPaymentMethod>(
            key: const Key('detailPaymentMethod'),
            segments: const [
              ButtonSegment(
                value: MedicalPaymentMethod.selfPaid,
                label: Text('Self-paid'),
              ),
              ButtonSegment(
                value: MedicalPaymentMethod.insurerPaid,
                label: Text('Insurer paid'),
              ),
            ],
            selected: {bill.paymentMethod},
            onSelectionChanged: (selection) =>
                _setMethod(context, ref, selection.first),
          ),
        ],
      ),
    );
  }

  Future<void> _setMethod(
    BuildContext context,
    WidgetRef ref,
    MedicalPaymentMethod method,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(medicalRepositoryProvider).setPaymentMethod(bill, method);
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Now marked ${method.label}')));
    } catch (error) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text('Could not change the payment method: $error')),
        );
    }
  }
}

// -----------------------------------------------------------------------------
// Bill state (FR-042 / FR-052)
// -----------------------------------------------------------------------------

class _BillStateSection extends ConsumerWidget {
  const _BillStateSection({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // R-1: an insurer-paid bill is settled with the provider, so it can never be
    // finished and can never be reimbursed.
    final selfPaid = bill.paymentMethod == MedicalPaymentMethod.selfPaid;
    final canFinish = selfPaid && bill.reimbursedAmount > 0;

    return _SectionCard(
      title: 'Bill Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final state in MedicalBillState.values)
                if (state != MedicalBillState.finished || canFinish)
                  OutlinedButton.icon(
                    key: Key('state-${state.name}'),
                    onPressed: () => _setState(context, ref, state),
                    icon: Icon(MedicalTheme.billStateIcon(state), size: 18),
                    label: Text(state.label),
                    style: bill.state == state
                        ? OutlinedButton.styleFrom(
                            backgroundColor:
                                MedicalTheme.billStateColor(context, state)
                                    .withValues(alpha: 0.18),
                          )
                        : null,
                  ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _stateHint(bill.state, selfPaid: selfPaid),
            style: TextStyle(
              fontSize: 12,
              color: MedicalTheme.subtleText(context),
            ),
          ),
          if (selfPaid && bill.linkedExpenseId != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('logReimbursementButton'),
              onPressed: () => _logReimbursement(context, ref),
              icon: const Icon(Icons.payments_outlined, size: 18),
              label: Text(
                bill.reimbursedAmount > 0
                    ? 'Update Reimbursement'
                    : 'Log Reimbursement',
              ),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  static String _stateHint(MedicalBillState state, {required bool selfPaid}) =>
      switch (state) {
        MedicalBillState.planned =>
          'A plan. Nothing leaves your budget until it actually happens.',
        MedicalBillState.waiting =>
          'In flight. Your budget already reflects what you owe.',
        MedicalBillState.paid =>
          'The provider has been paid and the claim is moving.',
        MedicalBillState.finished =>
          'Settled. A reimbursement has been recorded and added back.',
        MedicalBillState.rejected =>
          'Turned down, so the full charge stands and there is no payout to expect.',
      };

  Future<void> _setState(
    BuildContext context,
    WidgetRef ref,
    MedicalBillState state,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(medicalRepositoryProvider).setBillState(bill, state);
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Marked ${state.label}')));
    } on InvalidBillTransitionException catch (error) {
      // R-1 / D4: explain the rule rather than showing a raw failure.
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    } catch (error) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not update: $error')));
    }
  }

  /// FR-034: the payout is injected into the budget via a reimbursement row.
  Future<void> _logReimbursement(BuildContext context, WidgetRef ref) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) return;
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final expense = await expenseRepo.getExpense(expenseId);

    if (expense == null || !context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => entry.ReimbursementEntrySheet(
        expense: expense,
        medicalBill: bill,
      ),
    );
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
    final now = ref.watch(clockProvider);
    final hasFollowUp = bill.followUpDate != null;

    String statusText = 'No reminder set for this claim yet.';
    Color? statusColor = MedicalTheme.subtleText(context);
    bool isOverdue = false;

    if (hasFollowUp) {
      final diff = bill.followUpDate!.difference(now);
      if (diff.inHours < -1) {
        statusText =
            'Overdue since ${DateFormat.MMMd().format(bill.followUpDate!)}';
        statusColor = Colors.red;
        isOverdue = true;
      } else if (diff.isNegative || diff.inMinutes < 60) {
        statusText = 'Due now';
        statusColor = Theme.of(context).colorScheme.primary;
      } else if (diff.inHours < 24) {
        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;
        statusText = 'In ${hours}h ${mins}m';
        statusColor = Colors.orange;
      } else {
        statusText =
            'Check back ${DateFormat.MMMEd().format(bill.followUpDate!)} · ${DateFormat.jm().format(bill.followUpDate!)}';
      }
    }

    return _SectionCard(
      title: 'Follow-up Reminder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(context, ref),
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: Text(hasFollowUp
                      ? (isOverdue ? 'Reschedule' : 'Change time')
                      : 'Set reminder'),
                ),
              ),
              if (hasFollowUp) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Add to calendar',
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: () => _addToCalendar(context, ref),
                ),
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
    final picked =
        await ReminderPickerSheet.show(context, initialDate: bill.followUpDate);
    if (picked == null) return;
    await ref.read(medicalRepositoryProvider).setFollowUpDate(bill, picked);
  }

  Future<void> _addToCalendar(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final deviceCalendarPlugin = dc.DeviceCalendarPlugin();

    var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await deviceCalendarPlugin.requestPermissions();
    }

    if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
      final calendars = await deviceCalendarPlugin.retrieveCalendars();
      if (calendars.isSuccess &&
          calendars.data != null &&
          calendars.data!.isNotEmpty) {
        final defaultCalendar = calendars.data!.firstWhere(
          (c) => c.isDefault ?? false,
          orElse: () => calendars.data!.first,
        );

        final event = dc.Event(
          defaultCalendar.id,
          eventId: bill.calendarEventId,
          title: 'Claim Follow-up',
          description: 'Follow up on medical bill',
          start: tz.TZDateTime.from(bill.followUpDate!, tz.local),
          end: tz.TZDateTime.from(
              bill.followUpDate!.add(const Duration(minutes: 30)), tz.local),
        );

        final result = await deviceCalendarPlugin.createOrUpdateEvent(event);
        if (result?.isSuccess ?? false) {
          await ref
              .read(medicalRepositoryProvider)
              .setCalendarEventId(bill, result!.data);
          messenger
              .showSnackBar(const SnackBar(content: Text('Added to calendar')));
          return;
        }
      }
    }

    // Fallback to add_2_calendar
    final event = a2c.Event(
      title: 'Claim Follow-up',
      description: 'Follow up on medical bill',
      startDate: bill.followUpDate!,
      endDate: bill.followUpDate!.add(const Duration(minutes: 30)),
    );
    a2c.Add2Calendar.addEvent2Cal(event);
  }
}

// -----------------------------------------------------------------------------
// Documents (FR-047)
// -----------------------------------------------------------------------------

/// The two documents are listed separately because only a self-paid bill can
/// carry an insurer reply (D2).
class _DocumentsCard extends ConsumerWidget {
  const _DocumentsCard({required this.bill});

  final MedicalBill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insurerReply = bill.insurerReplyPath;
    return _SectionCard(
      title: 'Documents',
      child: Column(
        children: [
          if (bill.billPhotoPath != null)
            _DocumentRow(label: 'Bill photo', path: bill.billPhotoPath!),
          if (insurerReply != null)
            _DocumentRow(label: 'Insurer reply', path: insurerReply)
          else if (bill.paymentMethod == MedicalPaymentMethod.selfPaid)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.hourglass_empty),
              title: const Text('No insurer reply yet'),
              subtitle: Text(
                'Add one to keep what you need to claim this bill back.',
                style: TextStyle(color: MedicalTheme.subtleText(context)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.label, required this.path});

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.attach_file),
      title: Text(label),
      subtitle: Text(
        path.split(RegExp(r'[/\\]')).last,
        overflow: TextOverflow.ellipsis,
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
