import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/services/bulk_entry_service.dart';
import '../../../../core/services/merchant_service.dart';
import '../../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_search_provider.dart';
import '../../../finance/providers/profile_providers.dart';
import '../profile_picker_sheet.dart';
import 'expense_evidence_editor.dart';

class BulkExpenseEditor extends ConsumerWidget {
  const BulkExpenseEditor(
      {super.key,
      required this.row,
      required this.month,
      required this.onChanged,
      this.defaults = false,
      this.purchaseHeader = false,
      this.purchaseItem = false});
  final BulkExpenseDraft row;
  final String month;
  final VoidCallback onChanged;
  final bool defaults;
  final bool purchaseHeader, purchaseItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void changed() {
      row.evidence.cashConfirmed = false;
      onChanged();
    }

    final categories = ref.watch(categoriesProvider);
    final profileName = row.profileId == null
        ? 'Main'
        : row.profileType == FinancialProfileType.budget
            ? ref
                    .watch(budgetProfilesProvider)
                    .asData
                    ?.value
                    .where((p) => p.id == row.profileId)
                    .firstOrNull
                    ?.name ??
                row.profileName ??
                'Unavailable Budget profile'
            : ref
                    .watch(directExpenseProfilesProvider)
                    .asData
                    ?.value
                    .where((p) => p.id == row.profileId)
                    .firstOrNull
                    ?.name ??
                row.profileName ??
                'Unavailable Direct Expense profile';
    final merchantNames = defaults
        ? <String>[]
        : (ref.watch(expenseSearchMerchantsProvider).asData?.value ?? const [])
            .map((m) => m.canonicalName)
            .toList();
    Widget text(String label, String value, void Function(String) update,
            {String? error, bool amount = false}) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
                initialValue: value,
                decoration: InputDecoration(
                    labelText: label,
                    errorText: error,
                    border: const OutlineInputBorder()),
                keyboardType: amount
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : null,
                inputFormatters:
                    amount ? [const ThousandsSeparatorInputFormatter()] : null,
                onChanged: (value) {
                  update(value);
                  changed();
                }));
    Widget select<T>(String label, T? value, Map<T, String> choices,
            void Function(T?) update, {String? error}) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<T>(
                initialValue: choices.containsKey(value) ? value : null,
                isExpanded: true,
                decoration: InputDecoration(
                    labelText: label,
                    errorText: error,
                    border: const OutlineInputBorder()),
                items: choices.entries
                    .map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) {
                  update(value);
                  changed();
                }));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (row.errors['row'] != null)
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(row.errors['row']!,
                style: TextStyle(color: Theme.of(context).colorScheme.error))),
      if (!defaults && !purchaseHeader)
        text('Expense name', row.title, (v) => row.title = v,
            error: row.errors['name']),
      if (!defaults && !purchaseItem)
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RawAutocomplete<String>(
                initialValue: TextEditingValue(text: row.merchant),
                optionsBuilder: (value) => merchantNames
                    .where((name) =>
                        value.text.trim().isNotEmpty &&
                        name
                            .toLowerCase()
                            .contains(value.text.trim().toLowerCase()))
                    .take(6),
                fieldViewBuilder: (context, controller, focus, submit) =>
                    TextFormField(
                        controller: controller,
                        focusNode: focus,
                        maxLength: 200,
                        decoration: InputDecoration(
                            labelText: 'Merchant',
                            errorText: row.errors['merchant'],
                            border: const OutlineInputBorder()),
                        onChanged: (value) {
                          row.merchant = value;
                          changed();
                        }),
                onSelected: (value) {
                  row.merchant = value;
                  changed();
                },
                optionsViewBuilder: (context, select, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 300, maxHeight: 240),
                            child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                children: [
                                  for (final option in options)
                                    ListTile(
                                        title: Text(option),
                                        onTap: () => select(option))
                                ])))))),
      if (!purchaseItem)
        select(
            'Currency',
            row.currency,
            {
              for (final c in CurrencyCode.values)
                c.code.toUpperCase(): c.code.toUpperCase()
            },
            (v) => row.currency = v,
            error: row.errors['currency']),
      if (!defaults && !purchaseHeader)
        text('Amount', row.amount, (v) => row.amount = v,
            amount: true, error: row.errors['amount']),
      if (!purchaseHeader)
        select(
            'Category',
            row.category,
            {
              for (final c in categories.valueOrNull ?? []) c.categoryId: c.name
            },
            (v) => row.category = v,
            error: row.errors['category']),
      if (categories.hasError)
        const Text('Categories could not load. Reopen this screen to retry.'),
      if (!purchaseItem)
        select('Payment method', row.payment, expensePaymentMethods,
            (v) => row.payment = v,
            error: row.errors['payment']),
      if (!purchaseHeader)
        OutlinedButton.icon(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: Text(row.profileChosen
                ? 'Profile: $profileName'
                : 'Choose financial profile'),
            onPressed: () async {
              final result = await ProfilePickerSheet.show(context,
                  selectedProfileId: row.profileId,
                  selectedProfileType: row.profileType);
              if (result == null || !context.mounted) return;
              row
                ..profileChosen = true
                ..profileId = result.profileId
                ..profileType = result.profileType
                ..profileGuid = result.syncGuid;
              // The picker returns portable identity; names are resolved below.
              row.profileName = result.profileId == null
                  ? 'Main'
                  : result.profileType == FinancialProfileType.budget
                      ? ref
                              .read(budgetProfilesProvider)
                              .valueOrNull
                              ?.where((p) => p.id == result.profileId)
                              .firstOrNull
                              ?.name ??
                          'Unavailable Budget profile'
                      : ref
                              .read(directExpenseProfilesProvider)
                              .valueOrNull
                              ?.where((p) => p.id == result.profileId)
                              .firstOrNull
                              ?.name ??
                          'Unavailable Direct Expense profile';
              changed();
            }),
      if (row.errors['profile'] != null)
        Text(row.errors['profile']!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (!purchaseItem)
        OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(row.date == null
                ? 'Choose expense date'
                : 'Date: ${row.date!.year}-${row.date!.month.toString().padLeft(2, '0')}-${row.date!.day.toString().padLeft(2, '0')}'),
            onPressed: () async {
              final parts = month.split('-').map(int.parse).toList();
              final first = DateTime(parts[0], parts[1]);
              final last = DateTime(parts[0], parts[1] + 1, 0);
              final date = await showDatePicker(
                  context: context,
                  initialDate: row.date ?? first,
                  firstDate: first,
                  lastDate: last);
              if (date != null && context.mounted) {
                row.date = date;
                changed();
              }
            }),
      if (row.errors['date'] != null)
        Text(row.errors['date']!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (!defaults) ...[
        const SizedBox(height: 12),
        if (!purchaseItem)
          select(
              'Status',
              row.status,
              const {
                ExpenseStatus.planned: 'Planned',
                ExpenseStatus.paid: 'Paid'
              },
              (v) => row.status = v!),
        if (!purchaseHeader)
          text('Notes (optional)', row.notes, (v) => row.notes = v),
        if (!purchaseHeader && !purchaseItem)
          ExpenseEvidenceEditor(
              draft: row.evidence,
              status: row.status,
              payment: row.payment,
              onChanged: onChanged),
        if (row.errors['evidence'] != null)
          Text(row.errors['evidence']!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        if (!purchaseHeader)
          text('Tags (optional, separated by commas)', row.tags,
              (v) => row.tags = v),
        if (!purchaseHeader)
          CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reimbursable'),
              value: row.reimbursable,
              onChanged: (v) {
                row.reimbursable = v!;
                onChanged();
              }),
        if (!purchaseHeader)
          select(
              'Guilt level',
              row.guilt,
              const {
                GuiltLevel.essential: 'Essential',
                GuiltLevel.guiltFree: 'Guilt free',
                GuiltLevel.oops: 'Oops'
              },
              (v) => row.guilt = v!),
      ],
    ]);
  }
}
