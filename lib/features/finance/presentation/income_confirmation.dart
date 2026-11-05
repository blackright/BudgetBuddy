import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/income_source.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/income_activation_period.dart';
import '../../../core/services/income_activation_service.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../../medical/presentation/medical_access_check.dart';
import '../../medical/presentation/medical_bill_review_dialog.dart';
import '../../medical/providers/medical_receipt_provider.dart';
import '../providers/income_source_providers.dart';
import 'income_activation_sheet.dart';
import 'income_receipt_sheet.dart';
import 'receipt_errors.dart';
import 'salary_receipt_sheet.dart';

/// Opens the shared current-period choice and routes the selected outcome.
///
/// Used by normal Income Sources and by the onboarding activation stage. The
/// caller supplies the period so onboarding can target its chosen month.
Future<void> openIncomeActivation(
  BuildContext context,
  WidgetRef ref,
  IncomeSource source, {
  required String periodKey,
}) async {
  final currentMonth = _monthKey(DateTime.now());
  final startsInFuture = !isPeriodActive(source, periodKey) ||
      periodKey.compareTo(currentMonth) > 0;
  DateTime? expectedDate;
  if (!startsInFuture) {
    try {
      expectedDate = await ref
          .read(incomeActivationServiceProvider)
          .expectedDateFor(source, periodKey);
    } catch (_) {
      // The sheet still opens; the chosen action reports any real error.
      expectedDate = null;
    }
  }
  if (!context.mounted) return;
  final choice = await showModalBottomSheet<IncomeActivationChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheet) => IncomeActivationSheet(
      source: source,
      periodKey: periodKey,
      startsInFuture: startsInFuture,
      expectedDate: expectedDate,
      onChoice: (choice) => Navigator.of(sheet).pop(choice),
      onClose: () => Navigator.of(sheet).pop(),
    ),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case IncomeActivationChoice.alreadyReceived:
      await confirmIncomeSource(context, ref, source,
          activationPeriodKey: periodKey);
    case IncomeActivationChoice.expectLater:
      await chooseExpectedIncomeLater(context, ref, source, periodKey);
    case IncomeActivationChoice.startNext:
      await chooseStartNextPeriod(context, ref, source, periodKey);
  }
}

String _monthKey(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}';

/// Keeps an activation receipt in the period whose opening review exists.
///
/// When the period is not the current month, the usual receipt day is used so
/// the cash month matches the activated lifecycle instead of defaulting to
/// today in a different month.
DateTime _activationReceiptDate(
    String periodKey, SalaryCycle cycle, DateTime now) {
  if (_monthKey(now) == periodKey) return now;
  final parts = periodKey.split('-').map(int.parse).toList();
  final lastDay = DateTime(parts[0], parts[1] + 1, 0).day;
  final day = cycle.adjustedPayday.day.clamp(1, lastDay);
  final candidate = DateTime(parts[0], parts[1], day, now.hour, now.minute);
  if (candidate.isAfter(now)) {
    return DateTime(parts[0], parts[1], lastDay, 12);
  }
  return candidate;
}

/// Opens the right confirmation flow for any personal income source.
///
/// Salary keeps its existing sheet; every other type uses the simpler income
/// receipt sheet. Returns true when an actual receipt was confirmed.
///
/// When [activationPeriodKey] is supplied, the current period is prepared for
/// the "I already received it" choice first. If the sheet closes without a
/// receipt, a due-now completion action is created. The receipt services still
/// own every money write.
Future<bool> confirmIncomeSource(
    BuildContext context, WidgetRef ref, IncomeSource source,
    {SalaryCycle? requestedCycle, String? activationPeriodKey}) async {
  assert(requestedCycle == null || activationPeriodKey == null);
  final access = medicalAccessCheck(context, ref);
  final owner = ref.read(budgetContextProvider);
  final actor = ref.read(actingProfileIdProvider);
  if (!access() ||
      owner.isShared ||
      actor != owner.profileId ||
      !ref.read(activeContextCanEditProvider)) {
    return false;
  }
  final activation = ref.read(incomeActivationServiceProvider);
  var activationStarted = false;
  try {
    final SalaryCycle? cycle;
    if (activationPeriodKey != null) {
      cycle =
          await activation.chooseAlreadyReceived(source, activationPeriodKey);
      activationStarted = true;
    } else if (requestedCycle != null &&
        requestedCycle.sourceGuid == source.syncGuid &&
        requestedCycle.profileId == actor &&
        !requestedCycle.confirmed) {
      cycle = requestedCycle;
    } else {
      // Confirmation needs an explicit lifecycle from the activation flow.
      cycle = null;
    }
    if (cycle == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('This income is not expected in the current month.')));
      }
      return false;
    }
    final selectedCycle = cycle;
    final preferredDate = activationPeriodKey == null
        ? null
        : _activationReceiptDate(
            activationPeriodKey, selectedCycle, DateTime.now());
    final zone = (await FlutterTimezone.getLocalTimezone()).identifier;
    if (!context.mounted || !access()) return false;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheet) => guardMedicalReview(
        sheet,
        access,
        () => source.type == IncomeSourceType.salary
            ? SalaryReceiptSheet(
                source: source,
                cycle: selectedCycle,
                isAccessCurrent: access,
                timezone: zone,
                initialDate: preferredDate,
                simplified: activationPeriodKey != null,
                onConfirm: (preview, operation) => ref
                    .read(salaryReceiptServiceProvider)
                    .confirm(
                        preview: preview,
                        bankTotalMinor: preview.totalMinor,
                        operationKey: operation,
                        isAccessCurrent: access),
              )
            : IncomeReceiptSheet(
                source: source,
                cycle: selectedCycle,
                isAccessCurrent: access,
                timezone: zone,
                onConfirm: (amountMinor, actualDate, note) async {
                  final service = ref.read(incomeReceiptServiceProvider);
                  final preview = await service.preview(
                      source: source,
                      cycle: selectedCycle,
                      amountMinor: amountMinor,
                      actualDate: actualDate,
                      timezone: zone,
                      note: note,
                      isAccessCurrent: access);
                  await service.confirm(
                      preview: preview,
                      operationKey:
                          DateTime.now().microsecondsSinceEpoch.toString(),
                      isAccessCurrent: access);
                },
              ),
      ),
    );
    if (confirmed == true) {
      ref.invalidate(actualIncomeLedgerProvider);
      ref.invalidate(salaryCyclesProvider);
      ref.invalidate(medicalBillViewBatchProvider);
      return true;
    }
  } on IncomeActivationException catch (error) {
    if (context.mounted && access()) {
      _showActivationError(context, error);
    }
  } catch (error) {
    if (context.mounted && access()) {
      await _showError(context, error);
    }
  }
  if (activationStarted && activationPeriodKey != null) {
    try {
      await activation.markConfirmationUnfinished(source, activationPeriodKey);
      ref.invalidate(salaryCyclesProvider);
    } on IncomeActivationException catch (error) {
      if (context.mounted && access()) {
        _showActivationError(context, error);
      }
    } catch (error) {
      if (context.mounted && access()) {
        await _showError(context, error);
      }
    }
  }
  return false;
}

/// Saves the "I expect it later" choice without opening a receipt.
///
/// It creates or reuses the pending lifecycle and one confirmation action.
/// No money is written.
Future<void> chooseExpectedIncomeLater(BuildContext context, WidgetRef ref,
    IncomeSource source, String periodKey) async {
  final access = medicalAccessCheck(context, ref);
  final owner = ref.read(budgetContextProvider);
  final actor = ref.read(actingProfileIdProvider);
  if (!access() ||
      owner.isShared ||
      actor != owner.profileId ||
      !ref.read(activeContextCanEditProvider)) {
    return;
  }
  try {
    final cycle = await ref
        .read(incomeActivationServiceProvider)
        .chooseExpectLater(source, periodKey);
    if (!context.mounted) return;
    ref.invalidate(salaryCyclesProvider);
    final date = DateFormat.yMMMd().format(cycle.adjustedPayday);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Expected income saved for $date. We will remind you.')));
  } on IncomeActivationException catch (error) {
    if (context.mounted && access()) {
      _showActivationError(context, error);
    }
  } catch (error) {
    if (context.mounted && access()) {
      await _showError(context, error);
    }
  }
}

/// Saves the "Start from the next period" choice.
///
/// The current period becomes skipped, any current task is cancelled and the
/// next applicable period is prepared. No money is written.
Future<void> chooseStartNextPeriod(BuildContext context, WidgetRef ref,
    IncomeSource source, String periodKey) async {
  final access = medicalAccessCheck(context, ref);
  final owner = ref.read(budgetContextProvider);
  final actor = ref.read(actingProfileIdProvider);
  if (!access() ||
      owner.isShared ||
      actor != owner.profileId ||
      !ref.read(activeContextCanEditProvider)) {
    return;
  }
  try {
    await ref
        .read(incomeActivationServiceProvider)
        .chooseStartNext(source, periodKey);
    if (!context.mounted) return;
    ref.invalidate(salaryCyclesProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Current period skipped. The next period will start normally.')));
  } on IncomeActivationException catch (error) {
    if (context.mounted && access()) {
      _showActivationError(context, error);
    }
  } catch (error) {
    if (context.mounted && access()) {
      await _showError(context, error);
    }
  }
}

/// Cancels an expected income period with a reason.
Future<void> cancelExpectedIncome(BuildContext context, WidgetRef ref,
    IncomeSource source, String periodKey, String reason) async {
  final access = medicalAccessCheck(context, ref);
  final owner = ref.read(budgetContextProvider);
  final actor = ref.read(actingProfileIdProvider);
  if (!access() ||
      owner.isShared ||
      actor != owner.profileId ||
      !ref.read(activeContextCanEditProvider)) {
    return;
  }
  try {
    await ref
        .read(incomeActivationServiceProvider)
        .cancelExpected(source, periodKey, reason);
    if (!context.mounted) return;
    ref.invalidate(salaryCyclesProvider);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expected income cancelled.')));
  } on IncomeActivationException catch (error) {
    if (context.mounted && access()) {
      _showActivationError(context, error);
    }
  } catch (error) {
    if (context.mounted && access()) {
      await _showError(context, error);
    }
  }
}

void _showActivationError(
    BuildContext context, IncomeActivationException error) {
  final message = switch (error.code) {
    'alreadyConfirmed' => 'This income period is already confirmed.',
    'periodClosed' =>
      'This income period was closed. Open Income Sources to review it.',
    'inactivePeriod' => 'This income period has not started yet.',
    'invalidSource' => 'Add a positive amount and a supported currency first.',
    _ => 'This income period cannot be updated right now.',
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _showError(BuildContext context, Object error) async {
  final message = receiptErrorMessage(error);
  final code = receiptErrorCode(error);
  final route = receiptBlockerRoute(code);
  final action = receiptBlockerActionLabel(code);
  if (route != null && action != null) {
    final review = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('This receipt is blocked'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: const Text('Later')),
          TextButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(action)),
        ],
      ),
    );
    if (review == true && context.mounted) {
      context.go(route);
    }
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
