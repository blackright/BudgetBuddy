import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/services/filter_service.dart';
import '../../../../core/services/merchant_service.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_search_provider.dart';

class ExpenseSearchControls extends ConsumerStatefulWidget {
  const ExpenseSearchControls({super.key});
  @override
  ConsumerState<ExpenseSearchControls> createState() =>
      _ExpenseSearchControlsState();
}

class _ExpenseSearchControlsState extends ConsumerState<ExpenseSearchControls> {
  late final TextEditingController text;
  @override
  void initState() {
    super.initState();
    text =
        TextEditingController(text: ref.read(expenseSearchStateProvider).query);
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseSearchStateProvider);
    ref.listen(expenseSearchStateProvider, (previous, next) {
      if (next.query.isEmpty &&
          text.text.isNotEmpty &&
          (next.query != previous?.query ||
              next.resetToken != previous?.resetToken)) {
        text.clear();
      }
    });
    final actions = ref.read(expenseSearchStateProvider.notifier);
    final merchants =
        ref.watch(expenseSearchMerchantsProvider).asData?.value ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final profiles =
        ref.watch(expenseSearchProfileNamesProvider).asData?.value ?? {};
    final labels = {...state.filters.labels};
    if (state.savedBatch != null) labels['savedBatch'] = 'Saved batch';
    if (state.filters.merchant != null && state.filters.merchant != 'unknown') {
      labels['merchant'] =
          'Merchant: ${merchants.where((m) => m.syncGuid == state.filters.merchant).firstOrNull?.canonicalName ?? 'Not available'}';
    }
    if (state.filters.category != null) {
      labels['category'] =
          'Category: ${categories.where((c) => c.categoryId == state.filters.category).firstOrNull?.name ?? 'Not available'}';
    }
    if (state.filters.financialProfile != null) {
      labels['profile'] =
          profiles[state.filters.financialProfile] ?? 'Needs profile review';
    }
    if (state.filters.paymentMethod != null) {
      labels['payment'] =
          'Payment: ${expensePaymentMethods[state.filters.paymentMethod] ?? 'Not recorded'}';
    }
    if (state.filters.minimum != null || state.filters.maximum != null) {
      final code = CurrencyCode.tryParse(state.filters.currency);
      if (code != null) {
        labels['amount'] =
            '${state.filters.minimum == null ? 'Any' : formatMinorUnits(state.filters.minimum!, code)} to ${state.filters.maximum == null ? 'Any' : formatMinorUnits(state.filters.maximum!, code)}';
      }
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: text,
              onChanged: actions.type,
              decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        text.clear();
                        actions.type('');
                      }))),
          Row(children: [
            TextButton.icon(
                onPressed: () async {
                  ref.invalidate(expenseSearchProfileNamesProvider);
                  await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const ExpenseFiltersSheet());
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filters')),
            const Spacer(),
            TextButton(
                onPressed: () {
                  actions.clear();
                  text.clear();
                },
                child: const Text('Clear all'))
          ]),
          if (labels.isNotEmpty)
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 96),
                child: SingleChildScrollView(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(spacing: 6, runSpacing: 0, children: [
                          for (final entry in labels.entries)
                            InputChip(
                                label: Text(entry.value),
                                onDeleted: () => entry.key == 'savedBatch'
                                    ? actions.clearSavedBatch()
                                    : actions.apply(
                                        state.filters.without(entry.key)))
                        ])))),
        ]));
  }
}

class ExpenseFiltersSheet extends ConsumerStatefulWidget {
  const ExpenseFiltersSheet({super.key});
  @override
  ConsumerState<ExpenseFiltersSheet> createState() =>
      _ExpenseFiltersSheetState();
}

class _ExpenseFiltersSheetState extends ConsumerState<ExpenseFiltersSheet> {
  late ExpenseDateScope scope;
  DateTime? start, end;
  String? merchant, profile, category, currency, payment;
  ExpenseStatus? status;
  final minimum = TextEditingController(), maximum = TextEditingController();
  String? error;
  @override
  void initState() {
    super.initState();
    final f = ref.read(expenseSearchStateProvider).filters;
    scope = f.scope;
    start = f.start;
    end = f.end;
    merchant = f.merchant;
    profile = f.financialProfile;
    category = f.category;
    currency = f.currency;
    payment = f.paymentMethod;
    status = f.status;
    final code = CurrencyCode.tryParse(currency);
    if (code != null) {
      if (f.minimum != null) {
        minimum.text = formatMinorUnitsInput(f.minimum!, code);
      }
      if (f.maximum != null) {
        maximum.text = formatMinorUnitsInput(f.maximum!, code);
      }
    }
  }

  @override
  void dispose() {
    minimum.dispose();
    maximum.dispose();
    super.dispose();
  }

  Widget select(String label, String? value, Map<String, String> choices,
          void Function(String?) update) =>
      DropdownButtonFormField<String>(
          key: ValueKey('$label:$value'),
          initialValue: value ?? '',
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            const DropdownMenuItem(value: '', child: Text('All')),
            for (final e in choices.entries)
              DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, overflow: TextOverflow.ellipsis)),
            if (value != null && !choices.containsKey(value))
              DropdownMenuItem(
                  value: value, child: const Text('Previously selected'))
          ],
          onChanged: (v) => setState(() => update(v == '' ? null : v)));
  Future<void> pick(bool first) async {
    final date = await showDatePicker(
        context: context,
        initialDate: (first ? start : end) ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2200));
    if (date != null && mounted) {
      setState(() {
        if (first) {
          start = date;
        } else {
          end = date;
        }
      });
    }
  }

  void apply() {
    int? amount(String raw) =>
        parseSearchAmount(raw, CurrencyCode.tryParse(currency));

    try {
      final filters = ExpenseFilters(
          scope: scope,
          start: start,
          end: end,
          merchant: merchant,
          financialProfile: profile,
          category: category,
          currency: currency,
          paymentMethod: payment,
          status: status,
          minimum: amount(minimum.text),
          maximum: amount(maximum.text));
      if (filters.error != null) {
        setState(() => error = filters.error);
        return;
      }
      ref.read(expenseSearchStateProvider.notifier).apply(filters);
      Navigator.pop(context);
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows =
        ref.watch(expenseSearchRowsProvider).asData?.value ?? const <Expense>[];
    final merchants =
        ref.watch(expenseSearchMerchantsProvider).asData?.value ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final profiles = {
      ...?ref.watch(expenseSearchProfileNamesProvider).asData?.value
    };
    final used = rows.map(expenseFinancialKey).toSet();
    profiles.removeWhere((key, _) =>
        key != 'main' && key != 'unresolved' && !used.contains(key));
    for (final key in used) {
      profiles.putIfAbsent(key, () => 'Needs profile review');
    }
    return Padding(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
        child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .8,
            child: Column(children: [
              const Text('Filter expenses', style: TextStyle(fontSize: 20)),
              Expanded(
                  child: ListView(children: [
                DropdownButtonFormField<ExpenseDateScope>(
                    initialValue: scope,
                    decoration: const InputDecoration(labelText: 'Dates'),
                    items: const [
                      DropdownMenuItem(
                          value: ExpenseDateScope.month,
                          child: Text('Selected month')),
                      DropdownMenuItem(
                          value: ExpenseDateScope.range,
                          child: Text('Custom date range')),
                      DropdownMenuItem(
                          value: ExpenseDateScope.all,
                          child: Text('All months'))
                    ],
                    onChanged: (v) => setState(() => scope = v!)),
                if (scope == ExpenseDateScope.range)
                  Wrap(children: [
                    TextButton(
                        onPressed: () => pick(true),
                        child: Text(start == null
                            ? 'Start date'
                            : start.toString().split(' ').first)),
                    TextButton(
                        onPressed: () => pick(false),
                        child: Text(end == null
                            ? 'End date'
                            : end.toString().split(' ').first))
                  ]),
                select(
                    'Merchant',
                    merchant,
                    {
                      'unknown': 'Not recorded',
                      for (final m in merchants) m.syncGuid: m.canonicalName
                    },
                    (v) => merchant = v),
                select(
                    'Financial profile', profile, profiles, (v) => profile = v),
                select(
                    'Category',
                    category,
                    {for (final c in categories) c.categoryId: c.name},
                    (v) => category = v),
                select('Original currency', currency, {
                  for (final c in CurrencyCode.values)
                    c.code: c.code.toUpperCase()
                }, (v) {
                  currency = v;
                  minimum.clear();
                  maximum.clear();
                }),
                select(
                    'Payment method',
                    payment,
                    {'unknown': 'Not recorded', ...expensePaymentMethods},
                    (v) => payment = v),
                select(
                    'Status',
                    status?.name,
                    {
                      for (final s in ExpenseStatus.values)
                        s.name: s.name.replaceAll('Reimbursed', ' reimbursed')
                    },
                    (v) => status =
                        v == null ? null : ExpenseStatus.values.byName(v)),
                TextField(
                    controller: minimum,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    decoration:
                        const InputDecoration(labelText: 'Minimum amount')),
                TextField(
                    controller: maximum,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    decoration:
                        const InputDecoration(labelText: 'Maximum amount')),
                if (error != null)
                  Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
              ])),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(onPressed: apply, child: const Text('Apply'))
              ]),
            ])));
  }
}
