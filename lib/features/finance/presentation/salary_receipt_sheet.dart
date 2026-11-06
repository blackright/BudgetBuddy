import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../shared/presentation/modals/app_date_picker.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../core/services/salary_receipt_service.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/time_picker_dialogs.dart';
import '../providers/income_source_providers.dart';
import 'balance_checkpoint_sheet.dart' show parseCheckpointAmount;
import 'receipt_boundary_review.dart';
import 'receipt_errors.dart';

/// Compact salary confirmation sheet. Income Sources records the salary bank
/// credit only; medical refunds are recorded in the Medical management flow.
class SalaryReceiptSheet extends ConsumerStatefulWidget {
  const SalaryReceiptSheet(
      {super.key,
      required this.source,
      required this.cycle,
      required this.onConfirm,
      this.isAccessCurrent,
      this.timezone = 'UTC',
      this.now,
      this.initialDate,
      this.simplified = false});
  final IncomeSource source;
  final SalaryCycle cycle;
  final bool Function()? isAccessCurrent;
  final String timezone;

  /// Injectable clock for deterministic widget tests.
  final DateTime? now;

  /// Activation uses a compact confirmation with the period date preselected.
  final DateTime? initialDate;
  final bool simplified;
  final Future<void> Function(SalaryReceiptPreview, String) onConfirm;
  @override
  ConsumerState<SalaryReceiptSheet> createState() => _SalaryReceiptSheetState();
}

class _SalaryReceiptSheetState extends ConsumerState<SalaryReceiptSheet> {
  final form = GlobalKey<FormState>();
  late final salary = TextEditingController(
      text: formatMinorUnitsInput(widget.source.amount, currency));
  late DateTime date;
  bool busy = false, ack = false, included = false, checking = false;
  String? error;
  String? blocker;
  String? details;
  int checkToken = 0;
  String operation = DateTime.now().microsecondsSinceEpoch.toString();
  CurrencyCode get currency => CurrencyCode.tryParse(widget.source.currency)!;
  DateTime get today => widget.now ?? DateTime.now();
  String get cashMonth {
    try {
      return SalaryReceiptService.cashMonthFor(date, widget.timezone);
    } catch (_) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    }
  }

  String monthLabel(String month) =>
      DateFormat.yMMMM().format(DateTime.parse('$month-01'));
  int amount(String text) => parseCheckpointAmount(text, currency) ?? 0;
  String money(int minor) =>
      '${currency.code.toUpperCase()} ${formatMinorUnitsInput(minor, currency)}';

  @override
  void initState() {
    super.initState();
    date = widget.initialDate ?? today;
    Future.microtask(_check);
  }

  void change() {
    ack = false;
    error = null;
    details = null;
    operation = DateTime.now().microsecondsSinceEpoch.toString();
    Future.microtask(_check);
  }

  /// Reads the same receipt snapshot the confirmation will read, without
  /// writing anything, so the sheet can explain a blocker before the user
  /// fills the form.
  Future<void> _check() async {
    if (IsarHelper.maybeInstance == null) return;
    final token = ++checkToken;
    final access = widget.isAccessCurrent;
    if (access == null || !access()) {
      if (mounted) setState(() => blocker = null);
      return;
    }
    final planned = amount(salary.text);
    if (planned <= 0) {
      if (mounted) setState(() => blocker = null);
      return;
    }
    if (mounted) setState(() => checking = true);
    try {
      await ref.read(salaryReceiptServiceProvider).preview(
          actorId: widget.source.profileId!,
          sourceGuid: widget.source.syncGuid,
          cycleGuid: widget.cycle.guid,
          cycleDraft: widget.cycle,
          salaryMinor: planned,
          actualDate: date,
          timezone: widget.timezone,
          selectedClaimGuids: const [],
          alreadyIncluded: included,
          isAccessCurrent: access);
      if (!mounted || token != checkToken) return;
      setState(() {
        blocker = null;
        checking = false;
      });
    } catch (e) {
      if (!mounted || token != checkToken) return;
      final code = receiptErrorCode(e);
      setState(() {
        checking = false;
        blocker = receiptBlockerCodes.contains(code) ? code : null;
      });
    }
  }

  @override
  void dispose() {
    salary.dispose();
    super.dispose();
  }

  Future<void> confirm() async {
    if (busy || !ack || checking || blocker != null) return;
    if (!(form.currentState?.validate() ?? false)) return;
    final access = widget.isAccessCurrent;
    if (access == null || !access()) {
      setState(() =>
          error = 'Unlock the correct profile and reopen this confirmation.');
      return;
    }
    setState(() => busy = true);
    try {
      final preview = await ref.read(salaryReceiptServiceProvider).preview(
          actorId: widget.source.profileId!,
          sourceGuid: widget.source.syncGuid,
          cycleGuid: widget.cycle.guid,
          cycleDraft: widget.cycle,
          salaryMinor: amount(salary.text),
          actualDate: date,
          timezone: widget.timezone,
          selectedClaimGuids: const [],
          alreadyIncluded: included,
          isAccessCurrent: access);
      if (!mounted || !access()) return;
      await widget.onConfirm(preview, operation);
      if (mounted && access()) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Nothing was saved. ${receiptErrorMessage(e)}';
          details = receiptErrorDetails(e);
          final code = receiptErrorCode(e);
          if (receiptBlockerCodes.contains(code)) blocker = code;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  static const _openingBlockerCodes = {
    'missingOpeningCheckpoint',
    'movementNeedsReview',
    'openingReviewRequired',
  };

  Future<void> _reviewOpeningMoney() async {
    final actor = widget.source.profileId;
    if (actor == null) return;
    await reviewReceiptBoundary(context, ref,
        target: ContextRef.personal(profileId: actor, yearMonth: cashMonth));
    if (!mounted) return;
    await _check();
  }

  Widget _includedSwitch() => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('This salary is already inside my opening balance'),
      subtitle: const Text(
          'Turn on only if the balance you confirmed already includes this salary. Otherwise leave it off.'),
      value: included,
      onChanged: busy
          ? null
          : (value) => setState(() {
                included = value;
                change();
              }));

  @override
  Widget build(BuildContext context) => AppSheet(
      title: widget.simplified
          ? 'Confirm received salary'
          : 'Confirm salary received',
      bodyScrollable: false,
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
              key: form,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.simplified
                        ? 'We filled in the expected amount and salary period. Change them only if the bank credit was different.'
                        : 'Enter the salary bank credit. Medical refunds are recorded in the Medical bill.'),
                    if (blocker != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.block,
                                    color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(receiptErrorMessage(blocker!),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onErrorContainer))),
                              ]),
                              if (_openingBlockerCodes.contains(blocker))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonalIcon(
                                      key: const Key('salaryReviewOpening'),
                                      onPressed:
                                          busy ? null : _reviewOpeningMoney,
                                      icon: Icon(Icons.account_balance_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      label:
                                          const Text('Review opening balance'),
                                    ),
                                  ),
                                )
                              else if (receiptBlockerRoute(blocker!) != null)
                                TextButton(
                                  onPressed: () => context
                                      .go(receiptBlockerRoute(blocker!)!),
                                  child: Text(
                                      receiptBlockerActionLabel(blocker!) ??
                                          'Review'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (checking) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Counts in',
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                              Text(monthLabel(cashMonth),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ])),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Salary period',
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                              Text(monthLabel(widget.cycle.occurrenceMonth),
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ])),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: salary,
                        enabled: !busy,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: const [
                          ThousandsSeparatorInputFormatter()
                        ],
                        decoration: InputDecoration(
                            labelText: 'Amount received',
                            helperText:
                                'Expected ${money(widget.cycle.expectedAmountMinor)}',
                            prefixText: '${currency.code.toUpperCase()} '),
                        onChanged: (_) => setState(change),
                        validator: (_) => amount(salary.text) > 0
                            ? null
                            : 'Enter the actual salary, greater than zero.'),
                    const SizedBox(height: 12),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Received on'),
                        subtitle:
                            Text(DateFormat.yMMMd().add_jm().format(date)),
                        onTap: busy
                            ? null
                            : () async {
                                final day = await showAppDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime(1970),
                                    lastDate: today);
                                if (day != null && mounted) {
                                  setState(() {
                                    date = DateTime(day.year, day.month,
                                        day.day, date.hour, date.minute);
                                    change();
                                  });
                                }
                              }),
                    if (!widget.simplified)
                      TextButton(
                          onPressed: busy
                              ? null
                              : () async {
                                  final time = await showSafeTimePicker(
                                      context: context,
                                      initialTime:
                                          TimeOfDay.fromDateTime(date));
                                  if (time != null && mounted) {
                                    setState(() {
                                      date = DateTime(date.year, date.month,
                                          date.day, time.hour, time.minute);
                                      change();
                                    });
                                  }
                                },
                          child: const Text('Change time')),
                    if (widget.simplified)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Advanced options'),
                        children: [_includedSwitch()],
                      )
                    else
                      _includedSwitch(),
                    Text(
                        'Total that reached my bank: ${money(amount(salary.text))}',
                        style: Theme.of(context).textTheme.titleMedium),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'I checked this total against my bank statement.'),
                        value: ack,
                        onChanged: busy
                            ? null
                            : (value) => setState(() => ack = value == true)),
                    if (error != null)
                      Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    if (kDebugMode && details != null)
                      Text('Details: $details',
                          style: Theme.of(context).textTheme.bodySmall),
                    TextButton(
                        onPressed:
                            busy ? null : () => Navigator.pop(context, false),
                        child: const Text('Not received yet')),
                    FilledButton(
                        onPressed: busy || !ack || checking || blocker != null
                            ? null
                            : confirm,
                        child: Text(busy
                            ? 'Confirming...'
                            : 'Confirm salary received')),
                  ]))));
}

String receiptEntryMessage(Object error) => receiptErrorMessage(error);
