import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

import '../../medical/presentation/medical_access_check.dart';
import '../../pending_actions/providers/pending_actions_providers.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../../../shared/presentation/financial_feedback.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/pending_action.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/income_activation_period.dart';
import '../../../core/services/income_activation_service.dart';
import '../../../core/services/income_receipt_ledger.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/income_source_providers.dart';
import 'income_confirmation.dart';

/// How many income sources are shown before the "load more" button appears.
const int _pageSize = 20;

class IncomeSourcesScreen extends ConsumerStatefulWidget {
  const IncomeSourcesScreen(
      {super.key,
      this.focusedBillId,
      this.activationGuid,
      this.activationPeriod});
  final int? focusedBillId;

  /// Set when a Pending Action routes directly to one source's setup.
  final String? activationGuid;
  final String? activationPeriod;

  @override
  ConsumerState<IncomeSourcesScreen> createState() =>
      _IncomeSourcesScreenState();
}

class _IncomeSourcesScreenState extends ConsumerState<IncomeSourcesScreen> {
  /// How many rows are currently revealed (T112).
  int _visibleCount = _pageSize;
  bool _activationHandled = false;

  void _showMore(int total) {
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(incomeSourcesProvider);
    final isShared = ref.watch(budgetContextProvider).isShared;
    final contextCurrency = isShared
        ? (ref.watch(activeSpaceProvider).value?.currency.code ??
            CurrencyCode.huf)
        : (ref.watch(activeProfileProvider).value?.primaryCurrency.code ??
            CurrencyCode.huf);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final displayCurrency =
        resolveDisplayCurrency(month: budget, profile: profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Income Sources')),
      body: sources.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No income sources yet.'));
          }
          final requested = widget.activationGuid;
          if (requested != null && !_activationHandled) {
            IncomeSource? target;
            for (final item in items) {
              if (item.syncGuid == requested) {
                target = item;
                break;
              }
            }
            if (target != null) {
              _activationHandled = true;
              final period = widget.activationPeriod ??
                  periodKeyFor(target, DateTime.parse('$yearMonth-01'));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                openIncomeActivation(context, ref, target!, periodKey: period);
              });
            }
          }
          final visible = items.take(_visibleCount).toList();
          final hasMore = items.length > visible.length;
          return ListView.builder(
            itemCount: visible.length + (hasMore ? 1 : 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.focusedBillId != null)
                            const Text(
                                'Medical refunds are recorded in the Medical bill. Confirm salary here only for the salary bank credit.'),
                        ]));
              }
              index--;
              if (hasMore && index == visible.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    onPressed: () => _showMore(items.length),
                    child: Text(
                        'Show more (${items.length - visible.length} left)'),
                  ),
                );
              }
              final source = visible[index];
              final sourceCurrency = CurrencyCode.tryParse(source.currency);
              final converted = sourceCurrency == null
                  ? null
                  : convertAndFormat(
                      source.amount,
                      sourceCurrency,
                      displayCurrency,
                      table,
                    );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(source.name,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog(
                              context,
                              ref,
                              source,
                              contextCurrency,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await runFinancialAction(context,
                                  action: () => ref
                                      .read(incomeSourceActionsProvider)
                                      .delete(source.id),
                                  success: 'Income source deleted',
                                  failure:
                                      'Income source could not be deleted. Please retry.');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_label(source.type)} • ${_label(source.frequency)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      if (converted == null)
                        Text(
                            '${source.amount} ${source.currency} · Rate unavailable')
                      else
                        ConvertedAmountText(
                          text: converted.text,
                          originalText: converted.originalText,
                        ),
                      _IncomeCycleSummary(
                          source: source, currency: sourceCurrency),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, contextCurrency, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _label(Object value) {
    final raw = value
        .toString()
        .split('.')
        .last
        .replaceAllMapped(
          RegExp('([A-Z])'),
          (m) => ' ${m.group(1)!.toLowerCase()}',
        )
        .replaceAll('_', ' ')
        .trim();
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    CurrencyCode contextCurrency,
    IncomeSource? existing,
  ) async {
    final hostContext = context;
    final isShared = ref.read(budgetContextProvider).isShared;
    final existingSchedule = existing != null && !isShared
        ? await ref.read(incomeActivationServiceProvider).scheduleFor(existing)
        : null;
    var nominalDay = existingSchedule?.nominalDay ?? 25;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController(
      text: existing == null
          ? ''
          : (existing.amount / contextCurrency.minorUnitsPerMajor)
              .toStringAsFixed(contextCurrency.exponent),
    );
    var type = existing?.type ?? IncomeSourceType.salary;
    var frequency = existing?.frequency ?? IncomeFrequency.monthly;
    var currency = existing == null
        ? contextCurrency
        : (CurrencyCode.tryParse(existing.currency) ?? contextCurrency);
    DateTime? startDate = existing?.startDate;
    DateTime? endDate = existing?.endDate;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null
                  ? 'Add Income Source'
                  : 'Edit Income Source'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount (${currency.code.toUpperCase()})',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: const [
                        ThousandsSeparatorInputFormatter()
                      ],
                    ),
                    DropdownButtonFormField<CurrencyCode>(
                      initialValue: currency,
                      items: CurrencyCode.values
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.code.toUpperCase()} '
                                  '(${c.displayName})')))
                          .toList(),
                      onChanged: (v) => setDialogState(() {
                        if (v != null) currency = v;
                      }),
                      decoration: const InputDecoration(labelText: 'Currency'),
                    ),
                    DropdownButtonFormField<IncomeSourceType>(
                      initialValue: type,
                      items: IncomeSourceType.values
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(_label(t))))
                          .toList(),
                      onChanged: (v) => setDialogState(() {
                        if (v != null) type = v;
                      }),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    DropdownButtonFormField<IncomeFrequency>(
                      initialValue: frequency,
                      items: IncomeFrequency.values
                          .map((f) => DropdownMenuItem(
                              value: f, child: Text(_label(f))))
                          .toList(),
                      onChanged: (v) => setDialogState(() {
                        if (v != null) frequency = v;
                      }),
                      decoration: const InputDecoration(labelText: 'Frequency'),
                    ),
                    if (frequency != IncomeFrequency.oneTime)
                      DropdownButtonFormField<int>(
                        initialValue: nominalDay,
                        items: [
                          for (var day = 1; day <= 31; day++)
                            DropdownMenuItem(value: day, child: Text('$day')),
                        ],
                        onChanged: (v) => setDialogState(() {
                          if (v != null) nominalDay = v;
                        }),
                        decoration: const InputDecoration(
                            labelText: 'Usual receipt day'),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(frequency == IncomeFrequency.oneTime
                          ? 'Receipt date'
                          : 'Next income period'),
                      subtitle: Text(startDate == null
                          ? 'Not set'
                          : startDate!.toIso8601String().split('T').first),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: startDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ends'),
                      subtitle: Text(endDate == null
                          ? 'Not set'
                          : endDate!.toIso8601String().split('T').first),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: endDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final value = parseMoneyInput(amountController.text) ?? 0;
                    final source = existing ?? IncomeSource();
                    source
                      ..name = name
                      ..type = type
                      ..frequency = frequency
                      ..amount = (value * currency.minorUnitsPerMajor).round()
                      ..currency = currency.code
                      ..startDate = startDate
                      ..endDate = endDate
                      ..createdAt = existing?.createdAt ?? DateTime.now()
                      ..updatedAt = DateTime.now();
                    String zone = 'UTC';
                    try {
                      zone =
                          (await FlutterTimezone.getLocalTimezone()).identifier;
                    } catch (_) {
                      // Keep UTC if the platform timezone cannot be read.
                    }
                    if (!context.mounted) return;
                    final saved = await runFinancialAction(context,
                        action: () => ref
                            .read(incomeSourceActionsProvider)
                            .save(source,
                                nominalDay: frequency == IncomeFrequency.oneTime
                                    ? null
                                    : nominalDay,
                                timezone: zone),
                        success: existing == null
                            ? 'Income source added'
                            : 'Income source updated',
                        failure:
                            'Income source could not be saved. Please retry.');
                    if (saved && context.mounted) {
                      Navigator.of(context).pop();
                      if (existing == null && hostContext.mounted) {
                        await _openActivation(hostContext, source);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openActivation(
      BuildContext context, IncomeSource source) async {
    final period = periodKeyFor(source, DateTime.now());
    await openIncomeActivation(context, ref, source, periodKey: period);
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    IncomeSource source,
    CurrencyCode contextCurrency,
  ) async {
    await _showAddDialog(context, ref, contextCurrency, source);
  }
}

/// Expected-vs-actual summary for the latest occurrence of one source.
class _IncomeCycleSummary extends ConsumerWidget {
  const _IncomeCycleSummary({required this.source, required this.currency});
  final IncomeSource source;
  final CurrencyCode? currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cash = currency;
    if (cash == null) return const SizedBox.shrink();
    final cycles = ref.watch(salaryCyclesProvider).valueOrNull;
    if (cycles == null) return const SizedBox.shrink();
    final sourceCycles = cycles
        .where((cycle) => cycle.sourceGuid == source.syncGuid)
        .toList()
      ..sort((a, b) => b.occurrenceMonth.compareTo(a.occurrenceMonth));
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final selectedPeriod =
        periodKeyFor(source, DateTime.parse('$selectedMonth-01'));
    SalaryCycle? selected;
    for (final cycle in sourceCycles) {
      if (cycle.occurrenceMonth == selectedPeriod) {
        selected = cycle;
        break;
      }
    }
    if (selected == null) {
      if (!isPeriodActive(source, selectedPeriod)) {
        return const SizedBox.shrink();
      }
      return _notConfigured(context, ref, source, cash, selectedMonth);
    }
    final latest = selected;
    final state =
        latest.confirmed || latest.state == IncomePeriodState.confirmed.name
            ? IncomePeriodState.confirmed
            : incomePeriodStateFromStored(latest.state);
    final ledger = ref.watch(actualIncomeLedgerProvider).valueOrNull;
    IncomeReceiptLedger? matched;
    for (final row in ledger?.groups ?? const <IncomeReceiptLedger>[]) {
      if (row.group.cycleGuid == latest.guid) {
        matched = row;
        break;
      }
    }
    final month = DateFormat.yMMMM()
        .format(DateTime.parse('${latest.occurrenceMonth}-01'));
    final received =
        matched == null ? 0 : matched.salaryMinor + matched.incomeMinor;
    final label = source.type == IncomeSourceType.salary ? 'salary' : 'income';
    final correction = matched == null || source.type != IncomeSourceType.salary
        ? 0
        : (ledger?.corrections ?? const <SalaryCorrection>[])
            .where((row) => row.groupGuid == matched!.group.guid)
            .fold<int>(0, (sum, row) => sum + row.amountMinor);
    final canEdit = source.profileId != null &&
        !ref.watch(budgetContextProvider).isShared &&
        ref.watch(activeContextCanEditProvider);

    String? cancelReason;
    if (state == IncomePeriodState.cancelled) {
      final actions = ref.watch(pendingActionsProvider).valueOrNull ??
          const <PendingAction>[];
      for (final action in actions) {
        if (action.recordRef != latest.guid ||
            action.expectedMonth != latest.occurrenceMonth ||
            action.status != 'cancelled') {
          continue;
        }
        final reason = action.dismissedReason?.trim();
        if (reason != null &&
            reason.isNotEmpty &&
            !const {
              'periodClosed',
              'startNextPeriod',
              'sourceMissing',
              'legacyAutoExpected',
            }.contains(reason)) {
          cancelReason = reason;
          break;
        }
      }
    }

    final status = switch (state) {
      IncomePeriodState.confirmed => matched == null
          ? 'Confirmed'
          : 'Received ${formatMinorUnits(received, cash)}',
      IncomePeriodState.pending => 'Not received yet',
      IncomePeriodState.skipped => 'Skipped · Starts next period',
      IncomePeriodState.cancelled =>
        cancelReason == null ? 'Cancelled' : 'Cancelled · $cancelReason',
      IncomePeriodState.needsActivation => 'Current period not configured',
    };
    final canConfirm = canEdit && state == IncomePeriodState.pending;
    final canSetUp = canEdit && state == IncomePeriodState.needsActivation;
    final canCancel = canEdit && state == IncomePeriodState.pending;

    return Padding(
      key: ValueKey('income-cycle-${source.syncGuid}'),
      padding: const EdgeInsets.only(top: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          '$month $label · Expected ${formatMinorUnits(latest.expectedAmountMinor, cash)} · $status',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (correction != 0)
          Text(
            'Correction ${correction > 0 ? '+' : '-'}'
            '${formatMinorUnits(correction.abs(), cash)} · originals retained',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (canConfirm) ...[
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: [
            FilledButton.tonalIcon(
              onPressed: () => _confirm(context, ref, latest),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Confirm received'),
            ),
            if (canCancel)
              TextButton(
                onPressed: () => _cancelExpected(context, ref, latest),
                child: const Text('Cancel expected income'),
              )
            else
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Kept as expected. You can confirm it from Pending Actions.')));
                },
                child: const Text('Not yet'),
              ),
          ]),
        ],
        if (canSetUp) ...[
          const SizedBox(height: 4),
          FilledButton.tonalIcon(
            key: Key('incomeSetup-${source.syncGuid}'),
            onPressed: () => openIncomeActivation(context, ref, source,
                periodKey: latest.occurrenceMonth),
            icon: const Icon(Icons.playlist_add_check, size: 18),
            label: const Text('Set up current period'),
          ),
        ],
        if (matched != null &&
            source.type == IncomeSourceType.salary &&
            source.profileId != null &&
            !ref.watch(budgetContextProvider).isShared)
          TextButton(
            onPressed: () => _correct(context, ref, matched!, cash),
            child: const Text('Correct salary'),
          ),
      ]),
    );
  }

  Widget _notConfigured(BuildContext context, WidgetRef ref,
      IncomeSource source, CurrencyCode cash, String selectedMonth) {
    final canEdit = source.profileId != null &&
        !ref.watch(budgetContextProvider).isShared &&
        ref.watch(activeContextCanEditProvider);
    final label = source.type == IncomeSourceType.salary ? 'salary' : 'income';
    final month =
        DateFormat.yMMMM().format(DateTime.parse('$selectedMonth-01'));
    return Padding(
      key: ValueKey('income-cycle-${source.syncGuid}'),
      padding: const EdgeInsets.only(top: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          '$month $label · Expected ${formatMinorUnits(source.amount, cash)} · Current period not configured',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (canEdit) ...[
          const SizedBox(height: 4),
          FilledButton.tonalIcon(
            key: Key('incomeSetup-${source.syncGuid}'),
            onPressed: () => openIncomeActivation(context, ref, source,
                periodKey:
                    periodKeyFor(source, DateTime.parse('$selectedMonth-01'))),
            icon: const Icon(Icons.playlist_add_check, size: 18),
            label: const Text('Set up current period'),
          ),
        ],
      ]),
    );
  }

  Future<void> _cancelExpected(
      BuildContext context, WidgetRef ref, SalaryCycle cycle) async {
    var reason = '';
    var canSubmit = false;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cancel expected income'),
          content: TextField(
            key: const Key('incomeCancelReason'),
            autofocus: true,
            onChanged: (value) => setDialogState(() {
              reason = value;
              canSubmit = value.trim().isNotEmpty;
            }),
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialog).pop(false),
                child: const Text('Keep')),
            TextButton(
                onPressed:
                    canSubmit ? () => Navigator.of(dialog).pop(true) : null,
                child: const Text('Cancel income')),
          ],
        ),
      ),
    );
    if (accepted == true && context.mounted) {
      await cancelExpectedIncome(
          context, ref, source, cycle.occurrenceMonth, reason.trim());
    }
  }

  Future<void> _confirm(
      BuildContext context, WidgetRef ref, SalaryCycle cycle) async {
    final confirmed =
        await confirmIncomeSource(context, ref, source, requestedCycle: cycle);
    if (confirmed && context.mounted) {
      ref.invalidate(actualIncomeLedgerProvider);
      ref.invalidate(salaryCyclesProvider);
    }
  }

  Future<void> _correct(BuildContext context, WidgetRef ref,
      IncomeReceiptLedger matched, CurrencyCode currency) async {
    final amount = TextEditingController(
        text: formatMinorUnitsInput(matched.salaryMinor, currency));
    final reason = TextEditingController();
    final operationKey = DateTime.now().microsecondsSinceEpoch.toString();
    final access = medicalAccessCheck(context, ref);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Correct salary receipt'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'The original receipt, cycle and assignment stay unchanged. Only the difference is recorded.'),
          const SizedBox(height: 8),
          TextField(
            controller: amount,
            decoration: InputDecoration(
              labelText: 'Corrected salary (${currency.code.toUpperCase()})',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [ThousandsSeparatorInputFormatter()],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reason,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final value = parseMoneyInput(amount.text) ?? 0;
              final newSalary = (value * currency.minorUnitsPerMajor).round();
              final delta = newSalary - matched.salaryMinor;
              if (delta == 0 || reason.text.trim().isEmpty) return;
              final saved = await runFinancialAction(context,
                  action: () => ref.read(salaryReceiptServiceProvider).correct(
                      actorId: source.profileId!,
                      groupGuid: matched.group.guid,
                      correctionMinor: delta,
                      reason: reason.text,
                      operationKey: operationKey,
                      isAccessCurrent: access),
                  success: 'Salary corrected',
                  failure:
                      'The correction could not be saved. Check the amount and reason.');
              if (saved) {
                ref.invalidate(actualIncomeLedgerProvider);
                ref.invalidate(salaryCyclesProvider);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Correct'),
          ),
        ],
      ),
    );
    amount.dispose();
    reason.dispose();
  }
}
