import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/income_source_providers.dart';

/// How many income sources are shown before the "load more" button appears.
const int _pageSize = 20;

class IncomeSourcesScreen extends ConsumerStatefulWidget {
  const IncomeSourcesScreen({super.key});

  @override
  ConsumerState<IncomeSourcesScreen> createState() =>
      _IncomeSourcesScreenState();
}

class _IncomeSourcesScreenState extends ConsumerState<IncomeSourcesScreen> {
  /// How many rows are currently revealed (T112).
  int _visibleCount = _pageSize;

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
          final visible = items.take(_visibleCount).toList();
          final hasMore = items.length > visible.length;
          return ListView.builder(
            itemCount: visible.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
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
              return ListTile(
                title: Text(source.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_label(source.type)} • ${_label(source.frequency)}',
                    ),
                    // T164: the amount itself carries the long-press tooltip;
                    // the separate info icon is gone.
                    if (converted == null)
                      Text(
                          '${source.amount} ${source.currency} · Rate unavailable')
                    else
                      ConvertedAmountText(
                        text: converted.text,
                        originalText: converted.originalText,
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

  String _label(Object value) => value
      .toString()
      .split('.')
      .last
      .replaceAllMapped(
        RegExp('([A-Z])'),
        (m) => ' ${m.group(1)!.toLowerCase()}',
      )
      .replaceAll('_', ' ')
      .trim();

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    CurrencyCode contextCurrency,
    IncomeSource? existing,
  ) async {
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Starts'),
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
                    final saved = await runFinancialAction(context,
                        action: () =>
                            ref.read(incomeSourceActionsProvider).save(source),
                        success: existing == null
                            ? 'Income source added'
                            : 'Income source updated',
                        failure:
                            'Income source could not be saved. Please retry.');
                    if (saved && context.mounted) Navigator.of(context).pop();
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

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    IncomeSource source,
    CurrencyCode contextCurrency,
  ) async {
    await _showAddDialog(context, ref, contextCurrency, source);
  }
}
