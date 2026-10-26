import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/transfer.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/transfer_service.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../../shared/presentation/money_format.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/profile_providers.dart';
import '../providers/transfer_providers.dart';
import '../../settings/providers/app_settings_providers.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggle = ref.watch(transferToggleProvider);
    final transfers = ref.watch(transfersProvider);
    final profiles = ref.watch(budgetProfilesProvider).value ?? const [];
    // Inputs and actions stay in the context currency; read-only history is
    // shown in the display currency (T166).
    final currency = _currencyOf(ref);
    final displayCurrency = ref.watch(dashboardCurrencyProvider);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);

    if (!toggle) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transfers')),
        body: const Center(
          child: Text('Transfers are disabled in Settings.'),
        ),
      );
    }

    final namesById = {for (final p in profiles) p.id: p.name};

    return Scaffold(
      appBar: AppBar(title: const Text('Transfers')),
      body: transfers.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No transfers yet.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final t = items[index];
              final transferCurrency =
                  CurrencyCode.tryParse(t.currency) ?? currency;
              final source = namesById[t.sourceProfileId] ??
                  'Profile ${t.sourceProfileId}';
              final destination = namesById[t.destinationProfileId] ??
                  'Profile ${t.destinationProfileId}';
              // T166: history is read-only, so it reads in the display
              // currency; long-press reveals the stored transfer amount. The
              // entry dialog and the saved amount stay in the context currency.
              final converted = convertAndFormat(
                t.amount,
                transferCurrency,
                displayCurrency,
                table,
              );
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConvertedAmountText(
                      text: converted.text,
                      originalText: converted.originalText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$source → $destination'),
                  ],
                ),
                subtitle: Text([
                  if ((t.reason ?? '').trim().isNotEmpty) t.reason!.trim(),
                  _dateLabel(t.date),
                ].join(' • ')),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _dateLabel(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());

  CurrencyCode _currencyOf(WidgetRef ref) {
    final isShared = ref.read(budgetContextProvider).isShared;
    if (isShared) {
      return ref.read(activeSpaceProvider).value?.currency.code ??
          CurrencyCode.huf;
    }
    return ref.read(activeProfileProvider).value?.primaryCurrency.code ??
        CurrencyCode.huf;
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final profiles = ref.read(budgetProfilesProvider).value ?? [];
    final currency = _currencyOf(ref);
    if (profiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least two budget profiles.')),
      );
      return;
    }
    BudgetProfile? source = profiles.first;
    BudgetProfile? destination = profiles[1];
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    // Read-only hint: shown in the display currency, while the amount field
    // below stays in the context currency it saves in (T166).
    final displayCurrency = ref.read(dashboardCurrencyProvider);
    final table = ref
        .read(rateRegistryProvider)
        .tableFor(ref.read(selectedYearMonthProvider));

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Transfer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<BudgetProfile>(
                      initialValue: source,
                      items: profiles
                          .map((p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => source = v),
                      decoration: const InputDecoration(labelText: 'Source'),
                    ),
                    DropdownButtonFormField<BudgetProfile>(
                      initialValue: destination,
                      items: profiles
                          .map((p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => destination = v),
                      decoration:
                          const InputDecoration(labelText: 'Destination'),
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
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason'),
                    ),
                    if (source != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Available in ${source!.name}: '
                          '${convertAndFormat(source!.allocation, currency, displayCurrency, table).text}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
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
                  onPressed: () => _submit(context, ref, source, destination,
                      amountController, reasonController, currency),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Validates the transfer, asks the user to confirm, then saves it.
  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    BudgetProfile? source,
    BudgetProfile? destination,
    TextEditingController amountController,
    TextEditingController reasonController,
    CurrencyCode currency,
  ) async {
    // The field shows thousands separators, so it is read with the shared
    // money parser — a plain number parse would fail on "1,000".
    final value = parseMoneyInput(amountController.text) ?? 0;
    final amount = (value * currency.minorUnitsPerMajor).round();

    const service = TransferService();
    final refusal = service.refusalReason(
      source: source,
      destination: destination,
      amount: amount,
    );
    if (refusal != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(refusal)),
      );
      return;
    }

    // Confirmation step: the user sees exactly what will move.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Text(
          'Move ${formatMinorUnits(amount, currency)} from '
          '${source!.name} to ${destination!.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Local copies so the two profiles are known to be present from here on.
    final from = source;
    final to = destination;
    if (from == null || to == null) return;

    final transfer = Transfer()
      ..sourceProfileId = from.id
      ..destinationProfileId = to.id
      ..amount = amount
      ..currency = currency.code
      ..reason = reasonController.text.trim()
      ..date = DateTime.now()
      ..createdAt = DateTime.now();
    try {
      await ref.read(transferActionsProvider).saveWithAudit(
            transfer,
            sourceName: from.name,
            destinationName: to.name,
          );
    } catch (error) {
      if (context.mounted) {
        showFinancialFeedback(
            context,
            error is StateError
                ? error.message.toString()
                : 'The transfer could not be saved. Please try again.',
            kind: FinancialFeedbackKind.error);
      }
      return;
    }

    if (context.mounted) {
      showFinancialFeedback(context,
          'Moved ${formatMinorUnits(amount, currency)} from ${from.name} to ${to.name}.');
      Navigator.of(context).pop();
    }
  }
}
