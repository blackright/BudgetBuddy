import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/purchase_draft.dart';
import '../../../../core/services/bulk_entry_service.dart';
import '../../../../core/services/filter_service.dart';
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

String purchaseItemMoney(PurchaseDraft p, BulkExpenseDraft item) {
  final code = CurrencyCode.tryParse(p.header.currency);
  if (code == null) return 'Choose a currency';
  int? unit;
  try {
    unit = parseSearchAmount(item.unitAmount, code);
  } on FormatException {
    return 'Enter item details';
  }
  final total = item.lineTotalMinor;
  if (unit == null || unit <= 0 || total == null) {
    return 'Enter item details';
  }
  final unitText = formatMinorUnits(unit, code);
  final totalText = formatMinorUnits(total, code);
  return item.quantity == 1
      ? unitText
      : '${item.quantity} × $unitText = $totalText';
}

class PurchaseEditor extends StatefulWidget {
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
  State<PurchaseEditor> createState() => _PurchaseEditorState();
}

class _PurchaseEditorState extends State<PurchaseEditor> {
  String? _expandedItemGuid;
  final _tileControllers = <String, ExpansibleController>{};
  final _itemKeys = <String, GlobalKey>{};
  final _nameFocusNodes = <String, FocusNode>{};

  PurchaseDraft get purchase => widget.purchase;

  @override
  void initState() {
    super.initState();
    _resetExpansion(purchase);
  }

  @override
  void didUpdateWidget(covariant PurchaseEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.purchase, purchase) ||
        oldWidget.purchase.guid != purchase.guid) {
      _resetExpansion(purchase);
    }
  }

  @override
  void dispose() {
    for (final controller in _tileControllers.values) {
      controller.dispose();
    }
    _tileControllers.clear();
    for (final focus in _nameFocusNodes.values) {
      focus.dispose();
    }
    _nameFocusNodes.clear();
    _itemKeys.clear();
    super.dispose();
  }

  /// A different purchase starts with its first item open and no stale tile
  /// state from the previous purchase.
  void _resetExpansion(PurchaseDraft next) {
    for (final entry in _tileControllers.entries) {
      final controller = entry.value;
      final focus = _nameFocusNodes[entry.key];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
        focus?.dispose();
      });
    }
    _tileControllers.clear();
    _nameFocusNodes.clear();
    _itemKeys.clear();
    _expandedItemGuid = next.items.firstOrNull?.guid;
  }

  /// Removed items must not keep controllers or focus nodes alive. Disposal is
  /// deferred because the old tile is still attached during this build.
  void _pruneRemovedItems() {
    final guids = purchase.items.map((item) => item.guid).toSet();
    for (final guid in _tileControllers.keys.toList()) {
      if (guids.contains(guid)) continue;
      final controller = _tileControllers.remove(guid);
      final focus = _nameFocusNodes.remove(guid);
      _itemKeys.remove(guid);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller?.dispose();
        focus?.dispose();
      });
    }
    if (_expandedItemGuid != null && !guids.contains(_expandedItemGuid)) {
      _expandedItemGuid = null;
    }
  }

  ExpansibleController _controllerFor(String guid) =>
      _tileControllers.putIfAbsent(guid, ExpansibleController.new);

  GlobalKey _itemKeyFor(String guid) =>
      _itemKeys.putIfAbsent(guid, () => GlobalKey());

  FocusNode _focusNodeFor(String guid) =>
      _nameFocusNodes.putIfAbsent(guid, FocusNode.new);

  void _expandItem(String guid) {
    if (_expandedItemGuid == guid) return;
    final previous = _expandedItemGuid;
    setState(() => _expandedItemGuid = guid);
    if (previous != null) _tileControllers[previous]?.collapse();
    _revealItem(guid);
  }

  void _onItemExpansionChanged(String guid, bool expanded) {
    if (!expanded) {
      if (_expandedItemGuid == guid) {
        setState(() => _expandedItemGuid = null);
      }
      return;
    }
    _expandItem(guid);
  }

  void _addItem() {
    final item = purchase.addItem();
    final previous = _expandedItemGuid;
    _focusNodeFor(item.guid);
    setState(() => _expandedItemGuid = item.guid);
    if (previous != null) _tileControllers[previous]?.collapse();
    _revealItem(item.guid);
  }

  void _removeItem(BulkExpenseDraft item) {
    final wasExpanded = _expandedItemGuid == item.guid;
    setState(() {
      purchase.items.remove(item);
      if (wasExpanded) _expandedItemGuid = null;
    });
  }

  /// The newly active item must be visible and ready to type into. The focus
  /// request waits for the reveal animation so the expanding tile has its final
  /// height before the field asks to be on screen.
  void _revealItem(String guid) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _expandedItemGuid != guid) return;
      final itemContext = _itemKeys[guid]?.currentContext;
      if (itemContext != null) {
        await Scrollable.ensureVisible(
          itemContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
      if (!mounted || _expandedItemGuid != guid) return;
      _nameFocusNodes[guid]?.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    _pruneRemovedItems();
    final colors = Theme.of(context).colorScheme;
    String signature() => jsonEncode([
          purchase.header.merchant,
          purchase.header.currency,
          purchase.header.payment,
          purchase.header.date?.millisecondsSinceEpoch,
          purchase.header.status.name,
          purchase.receiptTotal,
          for (final item in purchase.items)
            [
              item.guid,
              item.unitAmount,
              item.quantity,
              item.needsQuantityCorrection,
              item.profileType,
              item.profileGuid
            ]
        ]);
    final before = signature();
    void financialChanged() {
      if (signature() != before) {
        purchase.evidence.cashConfirmed = false;
        purchase.evidence.cashInvalidated = true;
        purchase.evidence.changed = true;
      }
      widget.onChanged();
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
          month: widget.month,
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
      if (!widget.editing)
        ExpansionTile(
            title: const Text('Defaults for new items'),
            subtitle: const Text('Category and financial profile only'),
            children: [
              BulkExpenseEditor(
                  row: purchase.defaults,
                  month: widget.month,
                  defaults: true,
                  purchaseItem: true,
                  onChanged: widget.onChanged)
            ]),
      for (final (index, item) in purchase.items.indexed)
        Card.outlined(
            key: _itemKeyFor(item.guid),
            child: ExpansionTile(
                key: ValueKey(item.guid),
                controller: _controllerFor(item.guid),
                initiallyExpanded: item.guid == _expandedItemGuid,
                onExpansionChanged: (expanded) =>
                    _onItemExpansionChanged(item.guid, expanded),
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                    item.title.isEmpty ? 'Item ${index + 1}' : item.title,
                    key: Key('bulkItemTitle-${item.guid}')),
                subtitle: Text(item.needsQuantityCorrection
                    ? 'Review saved total'
                    : purchaseItemMoney(purchase, item)),
                childrenPadding: const EdgeInsets.all(12),
                children: [
                  BulkExpenseEditor(
                      row: item,
                      month: widget.month,
                      purchaseItem: true,
                      nameFocusNode: _focusNodeFor(item.guid),
                      onChanged: financialChanged),
                  if (!widget.editing)
                    TextButton.icon(
                        onPressed: () {
                          _removeItem(item);
                          financialChanged();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Remove item'))
                ])),
      if (!widget.editing)
        OutlinedButton.icon(
            onPressed: widget.canAdd
                ? () {
                    _addItem();
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
          onChanged: widget.onChanged),
      if (purchase.error != null)
        Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(purchase.error!, style: TextStyle(color: colors.error))),
    ]);
  }
}
