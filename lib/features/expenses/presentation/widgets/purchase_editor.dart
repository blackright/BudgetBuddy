import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/purchase_draft.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import 'bulk_expense_editor.dart';
import 'expense_evidence_editor.dart';

String purchaseMoney(PurchaseDraft p, int? amount) {
  final code = CurrencyCode.tryParse(p.header.currency);
  return amount == null || code == null
      ? 'Enter item amounts'
      : '${code.code.toUpperCase()} ${formatMinorUnits(amount, code)}';
}

class PurchaseEditor extends StatelessWidget {
  const PurchaseEditor(
      {super.key,
      required this.purchase,
      required this.month,
      required this.onChanged,
      required this.canAdd,
      this.editing = false});
  final PurchaseDraft purchase;
  final String month;
  final VoidCallback onChanged;
  final bool canAdd, editing;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String signature() => jsonEncode([
          purchase.header.merchant,
          purchase.header.currency,
          purchase.header.payment,
          purchase.header.date?.millisecondsSinceEpoch,
          purchase.header.status.name,
          purchase.receiptTotal,
          for (final item in purchase.items)
            [item.guid, item.amount, item.profileType, item.profileGuid]
        ]);
    final before = signature();
    void financialChanged() {
      if (signature() != before) {
        purchase.evidence.cashConfirmed = false;
        purchase.evidence.cashInvalidated = true;
        purchase.evidence.changed = true;
      }
      onChanged();
    }

    final code = CurrencyCode.tryParse(purchase.header.currency);
    String money(int? value) =>
        value == null || code == null ? '—' : formatMinorUnits(value, code);
    final difference =
        purchase.receiptMinor == null || purchase.totalMinor == null
            ? null
            : purchase.receiptMinor! - purchase.totalMinor!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('One receipt · one purchase',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      BulkExpenseEditor(
          row: purchase.header,
          month: month,
          purchaseHeader: true,
          onChanged: financialChanged),
      const SizedBox(height: 12),
      TextFormField(
          initialValue: purchase.receiptTotal,
          decoration: const InputDecoration(
              labelText: 'Receipt total',
              helperText:
                  'Required when Paid. Enter the total shown on the receipt.',
              border: OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [ThousandsSeparatorInputFormatter()],
          onChanged: (v) {
            purchase.receiptTotal = v;
            financialChanged();
          }),
      const SizedBox(height: 12),
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(18)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ITEMS ${purchase.items.length}',
                style: Theme.of(context).textTheme.labelLarge),
            Text(
                '${purchase.header.currency ?? ''} ${money(purchase.totalMinor)}',
                style: Theme.of(context).textTheme.headlineSmall),
            Text(
                'Receipt: ${money(purchase.receiptMinor)} · Difference: ${money(difference)}'),
            const Text('Only the items count as spending.')
          ])),
      const SizedBox(height: 12),
      if (!editing)
        ExpansionTile(
            title: const Text('Defaults for new items'),
            subtitle: const Text('Category and financial profile only'),
            children: [
              BulkExpenseEditor(
                  row: purchase.defaults,
                  month: month,
                  defaults: true,
                  purchaseItem: true,
                  onChanged: onChanged)
            ]),
      for (final (index, item) in purchase.items.indexed)
        Card.outlined(
            child: ExpansionTile(
                key: ValueKey(item.guid),
                leading: CircleAvatar(child: Text('${index + 1}')),
                title:
                    Text(item.title.isEmpty ? 'Item ${index + 1}' : item.title),
                subtitle: Text(item.amount.isEmpty
                    ? 'Enter item details'
                    : '${purchase.header.currency ?? ''} ${item.amount}'),
                childrenPadding: const EdgeInsets.all(12),
                children: [
              BulkExpenseEditor(
                  row: item,
                  month: month,
                  purchaseItem: true,
                  onChanged: financialChanged),
              if (!editing)
                TextButton.icon(
                    onPressed: () {
                      purchase.items.remove(item);
                      financialChanged();
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Remove item'))
            ])),
      if (!editing)
        OutlinedButton.icon(
            onPressed: canAdd
                ? () {
                    purchase.addItem();
                    financialChanged();
                  }
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add item to this purchase')),
      const SizedBox(height: 12),
      ExpenseEvidenceEditor(
          draft: purchase.evidence,
          status: purchase.header.status,
          payment: purchase.header.payment,
          onChanged: onChanged),
      if (purchase.error != null)
        Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(purchase.error!, style: TextStyle(color: colors.error))),
    ]);
  }
}
