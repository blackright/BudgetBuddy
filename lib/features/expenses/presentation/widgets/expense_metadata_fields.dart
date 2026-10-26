import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_search_provider.dart';
import 'expense_evidence_editor.dart';
import '../../../../core/services/expense_evidence_draft.dart';
import '../../../../core/services/expense_evidence.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/services/merchant_service.dart';

class ExpenseMetadataDraft {
  ExpenseMetadataDraft([Expense? expense])
      : merchant = TextEditingController(text: expense?.merchantName),
        tags = TextEditingController(text: expense?.tags.join(', ')),
        notes = TextEditingController(text: expense?.notes),
        payment = expense?.paymentMethod,
        evidence = ExpenseEvidenceDraft(expense);
  final ExpenseEvidenceDraft evidence;
  final TextEditingController merchant, tags, notes;
  String? payment;
  void apply(Expense expense) {
    if (merchant.text != (expense.merchantName ?? '')) {
      final name = merchantDisplayName(merchant.text);
      expense.merchantSyncGuid = null;
      expense.merchantName = name.isEmpty ? null : name;
    }
    expense.tags = normalizeExpenseTags(tags.text.split(','));
    expense.notes = notes.text.trim().isEmpty ? null : notes.text.trim();
    expense.paymentMethod = payment;
  }

  void dispose() {
    evidence.dispose();
    merchant.dispose();
    tags.dispose();
    notes.dispose();
  }
}

class ExpenseMetadataFields extends ConsumerStatefulWidget {
  const ExpenseMetadataFields(
      {super.key,
      required this.draft,
      this.status = ExpenseStatus.planned,
      this.showEvidence = true,
      this.requiredMetadata = false});
  final ExpenseMetadataDraft draft;
  final ExpenseStatus status;
  final bool requiredMetadata;
  final bool showEvidence;
  @override
  ConsumerState<ExpenseMetadataFields> createState() =>
      _ExpenseMetadataFieldsState();
}

class _ExpenseMetadataFieldsState extends ConsumerState<ExpenseMetadataFields> {
  final merchantFocus = FocusNode();
  @override
  void dispose() {
    merchantFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(expenseSearchMerchantsProvider);
    return Column(children: [
      const SizedBox(height: 16),
      RawAutocomplete<String>(
          onSelected: (_) =>
              setState(() => widget.draft.evidence.cashConfirmed = false),
          textEditingController: widget.draft.merchant,
          focusNode: merchantFocus,
          optionsBuilder: (value) =>
              (ref.read(expenseSearchMerchantsProvider).asData?.value ?? const [])
                  .map((m) => m.canonicalName)
                  .where((name) =>
                      value.text.trim().isNotEmpty &&
                      name
                          .toLowerCase()
                          .contains(value.text.trim().toLowerCase()))
                  .take(6),
          fieldViewBuilder: (context, controller, focus, submit) => TextFormField(
              controller: controller,
              focusNode: focus,
              maxLength: 200,
              onChanged: (_) =>
                  setState(() => widget.draft.evidence.cashConfirmed = false),
              validator: (value) =>
                  widget.requiredMetadata && (value?.trim().isEmpty ?? true)
                      ? 'Enter a merchant.'
                      : null,
              decoration:
                  InputDecoration(labelText: widget.requiredMetadata ? 'Merchant *' : 'Merchant')),
          optionsViewBuilder: (context, select, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 240),
                      child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(8), children: [
                        for (final option in options)
                          ListTile(
                              title: Text(option), onTap: () => select(option))
                      ]))))),
      TextFormField(
          controller: widget.draft.tags,
          decoration: const InputDecoration(
              labelText: 'Tags (optional)',
              helperText: 'Separate tags with commas')),
      DropdownButtonFormField<String>(
          initialValue: widget.draft.payment ?? '',
          decoration: const InputDecoration(labelText: 'Payment method'),
          items: [
            const DropdownMenuItem(value: '', child: Text('Not recorded')),
            for (final e in expensePaymentMethods.entries)
              if (!isPaidExpenseStatus(widget.status) ||
                  e.key != 'other' ||
                  widget.draft.payment == 'other')
                DropdownMenuItem(
                    value: e.key,
                    enabled:
                        !isPaidExpenseStatus(widget.status) || e.key != 'other',
                    child: Text(e.value)),
            if (widget.draft.payment != null &&
                !expensePaymentMethods.containsKey(widget.draft.payment))
              DropdownMenuItem(
                  value: widget.draft.payment,
                  child: const Text('Other recorded method'))
          ],
          onChanged: (value) => setState(() {
                widget.draft.evidence.cashConfirmed = false;
                widget.draft.payment = value == '' ? null : value;
              })),
      TextFormField(
          controller: widget.draft.notes,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Notes (optional)')),
      if (widget.showEvidence)
        ExpenseEvidenceEditor(
            draft: widget.draft.evidence,
            status: widget.status,
            payment: widget.draft.payment),
    ]);
  }
}
