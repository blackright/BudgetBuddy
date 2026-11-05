import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/money.dart';
import '../../../core/services/medical_management_service.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/medical_providers.dart';
import 'medical_document_picker.dart';
import 'medical_management_drafts.dart';
import 'medical_money_row.dart';
import 'medical_sheet_header.dart';
import 'medical_theme.dart';

/// User-paid management sheets. Each returns `true` when a command succeeded.

class MedicalSubmitRequestSheet extends ConsumerStatefulWidget {
  const MedicalSubmitRequestSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalSubmitRequestSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalSubmitRequestSheet> createState() =>
      _MedicalSubmitRequestSheetState();
}

class _MedicalSubmitRequestSheetState
    extends ConsumerState<MedicalSubmitRequestSheet> {
  late final TextEditingController _amount = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'submitRequest', 'amount') ??
          formatMinorUnitsInput(
              widget.bill.billedAmount, _currencyOf(widget.bill)));
  late final _reference = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'submitRequest', 'reference') ??
          '');
  DateTime _paymentDate = DateTime.now();
  late DateTime _paymentMonth = DateTime(_paymentDate.year, _paymentDate.month);
  late List<String> _documents;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'submitRequest');
    final savedDate =
        MedicalManagementDrafts.date(widget.bill.id, 'submitRequest', 'date');
    if (savedDate != null) _paymentDate = savedDate;
    final savedMonth =
        MedicalManagementDrafts.text(widget.bill.id, 'submitRequest', 'month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _paymentMonth = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    _amount.addListener(_saveTextDraft);
    _reference.addListener(_saveTextDraft);
  }

  void _saveTextDraft() {
    MedicalManagementDrafts.setText(
        widget.bill.id, 'submitRequest', 'amount', _amount.text);
    MedicalManagementDrafts.setText(
        widget.bill.id, 'submitRequest', 'reference', _reference.text);
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final major = double.tryParse(_amount.text.replaceAll(',', ''));
    if (major == null || major <= 0) {
      setState(() => _error = 'Enter the amount paid.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).submitRequest(
            billId: widget.bill.id,
            providerAmountMinor:
                Money.fromMajor(major, _currencyOf(widget.bill)).minorUnits,
            paymentDate: _paymentDate,
            paymentMonth: _monthKey(_paymentMonth),
            submissionDate: DateTime.now(),
            reference:
                _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'submitRequest');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not submit the request.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: 'Submit request',
            subtitle:
                'Confirm the provider payment and the insurance submission together.',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('submitAmountField'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount paid to provider',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _DateTile(
            label: 'Provider payment date',
            date: _paymentDate,
            onPick: (picked) => setState(() {
              _paymentDate = picked;
              _paymentMonth = DateTime(picked.year, picked.month);
              MedicalManagementDrafts.setDate(
                  widget.bill.id, 'submitRequest', 'date', picked);
              MedicalManagementDrafts.setText(widget.bill.id, 'submitRequest',
                  'month', _monthKey(_paymentMonth));
            }),
          ),
          _MonthYearField(
            key: const Key('submitPaymentMonth'),
            label: 'Payment month',
            month: _paymentMonth.month,
            year: _paymentMonth.year,
            onChanged: (month, year) => setState(() {
              _paymentMonth = DateTime(year, month);
              MedicalManagementDrafts.setText(widget.bill.id, 'submitRequest',
                  'month', _monthKey(_paymentMonth));
            }),
          ),
          Text(
            'This records the provider payment in the month it left your account.',
            style: TextStyle(
                fontSize: 12, color: MedicalTheme.subtleText(context)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reference,
            decoration: const InputDecoration(
              labelText: 'Insurance reference (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'submitRequest', paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('submitRequestConfirm'),
            onPressed: _saving ? null : _submit,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Confirm submission'),
          ),
        ],
      ),
    );
  }
}

class MedicalInsuranceSubmitSheet extends ConsumerStatefulWidget {
  const MedicalInsuranceSubmitSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalInsuranceSubmitSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalInsuranceSubmitSheet> createState() =>
      _MedicalInsuranceSubmitSheetState();
}

class _MedicalInsuranceSubmitSheetState
    extends ConsumerState<MedicalInsuranceSubmitSheet> {
  late final _reference = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'insuranceSubmit', 'reference') ??
          '');
  DateTime _submissionDate = DateTime.now();
  List<String> _documents = const [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedDate =
        MedicalManagementDrafts.date(widget.bill.id, 'insuranceSubmit', 'date');
    if (savedDate != null) _submissionDate = savedDate;
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'insuranceSubmit');
    _reference.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'insuranceSubmit', 'reference', _reference.text));
  }

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).submitInsuranceRequest(
            billId: widget.bill.id,
            submissionDate: _submissionDate,
            reference:
                _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'insuranceSubmit');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not submit the request.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _currencyOf(widget.bill);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: 'Submit request',
            subtitle:
                'Insurance pays the provider. Submitting does not deduct or confirm any money.',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          Text('Expected insurer payment: '
              '${MedicalTheme.moneyMinor(code, widget.bill.insurerPaidAmount)}'),
          Text('Expected your share: '
              '${MedicalTheme.moneyMinor(code, widget.bill.patientShareAmount)}'),
          const SizedBox(height: 8),
          _DateTile(
            label: 'Insurance submission date',
            date: _submissionDate,
            onPick: (picked) => setState(() {
              _submissionDate = picked;
              MedicalManagementDrafts.setDate(
                  widget.bill.id, 'insuranceSubmit', 'date', picked);
            }),
          ),
          TextField(
            controller: _reference,
            decoration: const InputDecoration(
              labelText: 'Insurance reference (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'insuranceSubmit', paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('insuranceSubmitConfirm'),
            onPressed: _saving ? null : _submit,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Confirm submission'),
          ),
        ],
      ),
    );
  }
}

class MedicalReceiptConfirmationSheet extends ConsumerStatefulWidget {
  const MedicalReceiptConfirmationSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (sheet) => MedicalReceiptConfirmationSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalReceiptConfirmationSheet> createState() =>
      _MedicalReceiptConfirmationSheetState();
}

class _MedicalReceiptConfirmationSheetState
    extends ConsumerState<MedicalReceiptConfirmationSheet> {
  DateTime _date = DateTime.now();
  List<String> _documents = const [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedDate =
        MedicalManagementDrafts.date(widget.bill.id, 'confirmReceipt', 'date');
    if (savedDate != null) _date = savedDate;
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'confirmReceipt');
  }

  Future<void> _confirm() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).confirmReceipt(
            billId: widget.bill.id,
            receiptDate: _date,
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'confirmReceipt');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not confirm receipt.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _wait() async {
    setState(() => _saving = true);
    try {
      await ref.read(medicalManagementServiceProvider).keepReceiptPending(
            billId: widget.bill.id,
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: () => mounted,
          );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Insurance received request',
              subtitle:
                  'Confirm only what you see in the insurer’s own application or message.',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            _DateTile(
              label: 'Receipt confirmation date',
              date: _date,
              onPick: (picked) => setState(() {
                _date = picked;
                MedicalManagementDrafts.setDate(
                    widget.bill.id, 'confirmReceipt', 'date', picked);
              }),
            ),
            MedicalDocumentPicker(
              paths: _documents,
              onChanged: (paths) {
                setState(() => _documents = paths);
                MedicalManagementDrafts.setDocuments(
                    widget.bill.id, 'confirmReceipt', paths);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('confirmReceiptButton'),
              onPressed: _saving ? null : _confirm,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: const Text('Confirm receipt'),
            ),
            TextButton(
              onPressed: _saving ? null : _wait,
              child: const Text('Still waiting'),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalDecisionSheet extends ConsumerStatefulWidget {
  const MedicalDecisionSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: MedicalTheme.surface(context),
      builder: (sheet) => MedicalDecisionSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalDecisionSheet> createState() =>
      _MedicalDecisionSheetState();
}

class _MedicalDecisionSheetState extends ConsumerState<MedicalDecisionSheet> {
  List<String> _documents = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'recordDecision');
  }

  Future<void> _record(MedicalDecision decision) async {
    setState(() => _saving = true);
    try {
      await ref.read(medicalManagementServiceProvider).recordDecision(
            billId: widget.bill.id,
            decision: decision,
            decisionDate: DateTime.now(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'recordDecision');
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final direct =
        widget.bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
    final currency = _currencyOf(widget.bill);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Insurance decision',
              subtitle:
                  'Record the outcome shown by the insurer. The app does not decide it.',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'EXPECTED FROM INSURER',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: MedicalTheme.subtleText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  MedicalMoneyRow(
                    label:
                        direct ? 'Insurance pays provider' : 'Expected refund',
                    value: MedicalTheme.moneyMinor(
                        currency, widget.bill.insurerPaidAmount),
                    compact: true,
                  ),
                  MedicalMoneyRow(
                    label: 'Your share',
                    value:
                        '${widget.bill.patientSharePercent.toStringAsFixed(0)}% · ${MedicalTheme.moneyMinor(currency, widget.bill.patientShareAmount)}',
                    compact: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'WHAT DID THE INSURER DECIDE?',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: MedicalTheme.subtleText(context),
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in const {
              MedicalDecision.approved: 'Approved',
              MedicalDecision.rejected: 'Rejected',
              MedicalDecision.cancelled: 'Request cancelled',
            }.entries) ...[
              _DecisionOption(
                key: Key('decision-${entry.key.name}'),
                title: entry.value,
                description: switch (entry.key) {
                  MedicalDecision.approved =>
                    'The insurer approved the request. Review the approved amounts next.',
                  MedicalDecision.rejected =>
                    'The insurer rejected it. Choose how to resolve the rejection next.',
                  MedicalDecision.cancelled =>
                    'The request was withdrawn or cancelled. No money moves.',
                },
                icon: switch (entry.key) {
                  MedicalDecision.approved => Icons.verified_outlined,
                  MedicalDecision.rejected => Icons.cancel_outlined,
                  MedicalDecision.cancelled => Icons.block_outlined,
                },
                color: switch (entry.key) {
                  MedicalDecision.approved =>
                    MedicalTheme.semantic(context, MedicalTheme.moneyIn),
                  MedicalDecision.rejected =>
                    MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                  MedicalDecision.cancelled =>
                    MedicalTheme.semantic(context, MedicalTheme.bank),
                },
                onTap: _saving ? null : () => _record(entry.key),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            Text(
              'SUPPORTING DOCUMENTS (OPTIONAL)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: MedicalTheme.subtleText(context),
              ),
            ),
            const SizedBox(height: 4),
            MedicalDocumentPicker(
              paths: _documents,
              onChanged: (paths) {
                setState(() => _documents = paths);
                MedicalManagementDrafts.setDocuments(
                    widget.bill.id, 'recordDecision', paths);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionOption extends StatelessWidget {
  const _DecisionOption({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: MedicalTheme.subtleText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicalApprovedAmountsSheet extends ConsumerStatefulWidget {
  const MedicalApprovedAmountsSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: MedicalTheme.surface(context),
      builder: (sheet) => MedicalApprovedAmountsSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalApprovedAmountsSheet> createState() =>
      _MedicalApprovedAmountsSheetState();
}

class _MedicalApprovedAmountsSheetState
    extends ConsumerState<MedicalApprovedAmountsSheet> {
  bool get _direct =>
      widget.bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
  late final _bill = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'reviewApprovedAmounts', 'bill') ??
          formatMinorUnitsInput(
              widget.bill.billedAmount, _currencyOf(widget.bill)));
  late final _share = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'reviewApprovedAmounts', 'share') ??
          formatMinorUnitsInput(
              widget.bill.patientShareAmount, _currencyOf(widget.bill)));
  late final _insurance = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'reviewApprovedAmounts', 'insurance') ??
          formatMinorUnitsInput(
              widget.bill.insurerPaidAmount, _currencyOf(widget.bill)));
  late DateTime _expectedMonth = _billMonthPlusOne(widget.bill);
  List<String> _documents = [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedMonth = MedicalManagementDrafts.text(
        widget.bill.id, 'reviewApprovedAmounts', 'month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _expectedMonth = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    _documents = MedicalManagementDrafts.documents(
        widget.bill.id, 'reviewApprovedAmounts');
    _saveTextDraft();
    _bill.addListener(_saveTextDraft);
    _share.addListener(_saveTextDraft);
    _insurance.addListener(_saveTextDraft);
  }

  void _saveTextDraft() {
    MedicalManagementDrafts.setText(
        widget.bill.id, 'reviewApprovedAmounts', 'bill', _bill.text);
    MedicalManagementDrafts.setText(
        widget.bill.id, 'reviewApprovedAmounts', 'share', _share.text);
    MedicalManagementDrafts.setText(
        widget.bill.id, 'reviewApprovedAmounts', 'insurance', _insurance.text);
  }

  @override
  void dispose() {
    _bill.dispose();
    _share.dispose();
    _insurance.dispose();
    super.dispose();
  }

  int? _minor(TextEditingController controller) {
    final value = double.tryParse(controller.text.replaceAll(',', ''));
    return value == null
        ? null
        : Money.fromMajor(value, _currencyOf(widget.bill)).minorUnits;
  }

  Future<void> _save() async {
    final bill = _minor(_bill);
    final share = _minor(_share);
    final insurance = _minor(_insurance);
    if (bill == null || share == null || insurance == null) return;
    final noShare = _direct && share == 0;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).reviewApprovedAmounts(
            billId: widget.bill.id,
            approvedBillMinor: bill,
            approvedShareMinor: share,
            approvedInsuranceMinor: insurance,
            expectedSalaryMonth: noShare ? null : _monthKey(_expectedMonth),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'reviewApprovedAmounts');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not save the approved amounts.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zeroShare = _direct && _minor(_share) == 0;
    final currency = _currencyOf(widget.bill);
    final scheme = Theme.of(context).colorScheme;
    final fields = [
      (
        'approvedBillField',
        'Approved bill amount',
        _bill,
        Icons.receipt_long_outlined,
        scheme.primary,
      ),
      (
        'approvedShareField',
        'Approved your share',
        _share,
        Icons.person_outline,
        MedicalTheme.semantic(context, MedicalTheme.planned),
      ),
      (
        'approvedInsuranceField',
        _direct ? 'Approved insurance payment' : 'Approved refund',
        _insurance,
        Icons.verified_outlined,
        MedicalTheme.semantic(context, MedicalTheme.moneyIn),
      ),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: 'Review approved amounts',
            subtitle:
                'Match the insurer breakdown. Expected values stay visible for comparison.',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'EXPECTED FROM THE INSURER',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: MedicalTheme.subtleText(context),
                  ),
                ),
                const SizedBox(height: 4),
                MedicalMoneyRow(
                  label: 'Bill total',
                  value: MedicalTheme.moneyMinor(
                      currency, widget.bill.billedAmount),
                  compact: true,
                ),
                MedicalMoneyRow(
                  label: 'Your share',
                  value:
                      '${widget.bill.patientSharePercent.toStringAsFixed(0)}% · ${MedicalTheme.moneyMinor(currency, widget.bill.patientShareAmount)}',
                  compact: true,
                ),
                MedicalMoneyRow(
                  label: _direct ? 'Insurer payment' : 'Expected refund',
                  value: MedicalTheme.moneyMinor(
                      currency, widget.bill.insurerPaidAmount),
                  compact: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _direct
                ? 'Your share is deducted in the month you choose.'
                : 'The refund is credited in the month you choose.',
            style: TextStyle(
                fontSize: 12, color: MedicalTheme.subtleText(context)),
          ),
          const SizedBox(height: 16),
          Text(
            'APPROVED AMOUNTS',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: MedicalTheme.subtleText(context),
            ),
          ),
          const SizedBox(height: 8),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                key: Key(field.$1),
                controller: field.$3,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: field.$2,
                  prefixIcon: Icon(field.$4, color: field.$5),
                  filled: true,
                  fillColor: field.$5.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (!zeroShare) ...[
            const SizedBox(height: 2),
            Text(
              'EXPECTED SALARY MONTH',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: MedicalTheme.subtleText(context),
              ),
            ),
            _MonthYearField(
              key: const Key('approvedExpectedMonth'),
              label: 'Expected salary month',
              month: _expectedMonth.month,
              year: _expectedMonth.year,
              onChanged: (month, year) => setState(() {
                _expectedMonth = DateTime(year, month);
                MedicalManagementDrafts.setText(
                    widget.bill.id,
                    'reviewApprovedAmounts',
                    'month',
                    _monthKey(_expectedMonth));
              }),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'SUPPORTING DOCUMENTS (OPTIONAL)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: MedicalTheme.subtleText(context),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'reviewApprovedAmounts', paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 18, color: scheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: TextStyle(
                            fontSize: 12, color: scheme.onErrorContainer)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('approvedAmountsConfirm'),
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(_saving ? 'Saving…' : 'Save approved amounts'),
          ),
        ],
      ),
    );
  }
}

class MedicalRefundSheet extends ConsumerStatefulWidget {
  const MedicalRefundSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: MedicalTheme.surface(context),
      builder: (sheet) => MedicalRefundSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalRefundSheet> createState() => _MedicalRefundSheetState();
}

class _MedicalRefundSheetState extends ConsumerState<MedicalRefundSheet> {
  bool get _direct =>
      widget.bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
  late final _amount = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'recordSettlement', 'amount') ??
          formatMinorUnitsInput(widget.bill.settlementAmountMinor ?? 0,
              _currencyOf(widget.bill)));
  late DateTime _month = _billMonthPlusOne(widget.bill);
  late DateTime _date;
  List<String> _documents = [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedMonth = MedicalManagementDrafts.text(
        widget.bill.id, 'recordSettlement', 'month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    final savedDate = MedicalManagementDrafts.date(
        widget.bill.id, 'recordSettlement', 'date');
    _date = savedDate != null &&
            savedDate.year == _month.year &&
            savedDate.month == _month.month
        ? savedDate
        : _dateWithinMonth(_month);
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'recordSettlement');
    _amount.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'recordSettlement', 'amount', _amount.text));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final major = double.tryParse(_amount.text.replaceAll(',', ''));
    if (major == null || major <= 0) return;
    final now = DateTime.now();
    if (_date.isAfter(now)) {
      setState(() => _error = _direct
          ? 'The deduction date cannot be in the future.'
          : 'The received date cannot be in the future.');
      return;
    }
    if (_date.year != _month.year || _date.month != _month.month) {
      setState(() => _error = _direct
          ? 'Choose a deduction date inside the salary month.'
          : 'Choose a received date inside the salary month.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final amountMinor =
          Money.fromMajor(major, _currencyOf(widget.bill)).minorUnits;
      final service = ref.read(medicalManagementServiceProvider);
      if (_direct) {
        await service.recordDeductionConfirmed(
          billId: widget.bill.id,
          amountMinor: amountMinor,
          actualSalaryMonth: _monthKey(_month),
          deductionDate: _date,
          operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
          documentPaths: _documents,
          isAccessCurrent: () => mounted,
        );
      } else {
        await service.recordRefundReceived(
          billId: widget.bill.id,
          amountMinor: amountMinor,
          actualSalaryMonth: _monthKey(_month),
          receivedDate: _date,
          operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
          documentPaths: _documents,
          isAccessCurrent: () => mounted,
        );
      }
      MedicalManagementDrafts.clear(widget.bill.id, 'recordSettlement');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not confirm the refund.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _notReceived() async {
    setState(() => _saving = true);
    try {
      final service = ref.read(medicalManagementServiceProvider);
      if (_direct) {
        await service.recordNotDeducted(
          billId: widget.bill.id,
          nextExpectedMonth: _monthKey(DateTime(_month.year, _month.month + 1)),
          operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
          isAccessCurrent: () => mounted,
        );
      } else {
        await service.recordNotReceived(
          billId: widget.bill.id,
          nextExpectedMonth: _monthKey(DateTime(_month.year, _month.month + 1)),
          operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
          isAccessCurrent: () => mounted,
        );
      }
      MedicalManagementDrafts.clear(widget.bill.id, 'recordSettlement');
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = MedicalTheme.semantic(
        context, _direct ? MedicalTheme.planned : MedicalTheme.moneyIn);
    final expected = widget.bill.settlementAmountMinor ??
        (_direct
            ? widget.bill.patientShareAmount
            : widget.bill.insurerPaidAmount);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: _direct ? 'Confirm salary deduction' : 'Check payslip',
            subtitle: _direct
                ? 'Confirm the share only when it appears as a deduction on your payslip.'
                : 'Confirm the refund only when it appears on your payslip.',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _direct ? 'EXPECTED DEDUCTION' : 'EXPECTED REFUND',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                MedicalMoneyRow(
                  label: _direct ? 'Your share' : 'Insurance refund',
                  value: MedicalTheme.moneyMinor(
                      _currencyOf(widget.bill), expected),
                  compact: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ACTUAL AMOUNT',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: MedicalTheme.subtleText(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('refundAmountField'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText:
                  _direct ? 'Actual share deducted' : 'Actual refund received',
              prefixIcon: Icon(Icons.payments_outlined, color: accent),
              filled: true,
              fillColor: accent.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SALARY MONTH',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: MedicalTheme.subtleText(context),
            ),
          ),
          _MonthYearField(
            key: const Key('refundSalaryMonth'),
            label: 'Actual salary month',
            month: _month.month,
            year: _month.year,
            onChanged: (month, year) => setState(() {
              final selected = DateTime(year, month);
              _month = selected;
              _date = _dateWithinMonth(selected);
              MedicalManagementDrafts.setText(widget.bill.id,
                  'recordSettlement', 'month', _monthKey(_month));
              MedicalManagementDrafts.setDate(
                  widget.bill.id, 'recordSettlement', 'date', _date);
            }),
          ),
          Text(
            _direct
                ? 'The deduction date follows the salary month you choose.'
                : 'The received date follows the salary month you choose.',
            style: TextStyle(
                fontSize: 12, color: MedicalTheme.subtleText(context)),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _DateTile(
                  label: _direct ? 'Deduction date' : 'Received date',
                  date: _date,
                  firstDate: DateTime(_month.year, _month.month, 1),
                  lastDate: _lastDayOfMonth(_month),
                  onPick: (picked) => setState(() {
                    _date = picked;
                    MedicalManagementDrafts.setDate(
                        widget.bill.id, 'recordSettlement', 'date', picked);
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SUPPORTING DOCUMENTS (OPTIONAL)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: MedicalTheme.subtleText(context),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'recordSettlement', paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 18, color: scheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: TextStyle(
                            fontSize: 12, color: scheme.onErrorContainer)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('refundConfirm'),
            onPressed: _saving ? null : _confirm,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: Icon(
                _direct ? Icons.check_circle_outline : Icons.savings_outlined),
            label: Text(_saving
                ? 'Saving…'
                : _direct
                    ? 'Confirm deduction'
                    : 'Confirm refund received'),
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _saving ? null : _notReceived,
            icon: const Icon(Icons.schedule),
            label: Text(_direct
                ? 'Not deducted this month'
                : 'Not received this month'),
          ),
        ],
      ),
    );
  }
}

class MedicalRejectionSheet extends ConsumerStatefulWidget {
  const MedicalRejectionSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (sheet) => MedicalRejectionSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalRejectionSheet> createState() =>
      _MedicalRejectionSheetState();
}

class _MedicalRejectionSheetState extends ConsumerState<MedicalRejectionSheet> {
  bool _saving = false;

  bool get _direct =>
      widget.bill.paymentMethod == MedicalPaymentMethod.insurerPaid;

  Future<void> _accept() async {
    setState(() => _saving = true);
    try {
      await ref.read(medicalManagementServiceProvider).acceptRejection(
            billId: widget.bill.id,
            decisionDate: DateTime.now(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: () => mounted,
          );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resolve(MedicalRejectionResolution resolution) async {
    if (resolution == MedicalRejectionResolution.appeal) {
      final changed = await MedicalAppealSheet.show(context, widget.bill);
      if (changed == true && mounted) Navigator.pop(context, true);
      return;
    }
    if (resolution == MedicalRejectionResolution.providerCancelled) {
      setState(() => _saving = true);
      try {
        await ref
            .read(medicalManagementServiceProvider)
            .resolveInsurancePaidRejection(
              billId: widget.bill.id,
              resolution: resolution,
              operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
              isAccessCurrent: () => mounted,
            );
        if (mounted) Navigator.pop(context, true);
      } finally {
        if (mounted) setState(() => _saving = false);
      }
      return;
    }
    final changed = await _ResolutionDetailsSheet.show(
      context,
      widget.bill,
      resolution,
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final options = _direct
        ? const {
            MedicalRejectionResolution.providerCancelled:
                'Provider cancelled the charge',
            MedicalRejectionResolution.userPaidProvider: 'I paid the provider',
            MedicalRejectionResolution.adjustedDeduction:
                'Adjusted salary deduction',
            MedicalRejectionResolution.appeal: 'Record an appeal',
            MedicalRejectionResolution.other: 'Another resolution',
          }
        : const {
            MedicalRejectionResolution.accepted: 'Accept rejection',
            MedicalRejectionResolution.appeal: 'Record an appeal',
          };
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Resolve rejection',
              subtitle: _direct
                  ? 'Record how the provider charge or payment responsibility was resolved.'
                  : 'Accept the final rejection or track an appeal.',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            for (final entry in options.entries)
              ListTile(
                key: Key('rejection-${entry.key.name}'),
                title: Text(entry.value),
                trailing: const Icon(Icons.chevron_right),
                onTap: _saving
                    ? null
                    : () => entry.key == MedicalRejectionResolution.accepted
                        ? _accept()
                        : _resolve(entry.key),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionDetailsSheet extends ConsumerStatefulWidget {
  const _ResolutionDetailsSheet({
    required this.bill,
    required this.resolution,
  });

  final MedicalBill bill;
  final MedicalRejectionResolution resolution;

  static Future<bool?> show(BuildContext context, MedicalBill bill,
      MedicalRejectionResolution resolution) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) =>
          _ResolutionDetailsSheet(bill: bill, resolution: resolution),
    );
  }

  @override
  ConsumerState<_ResolutionDetailsSheet> createState() =>
      _ResolutionDetailsSheetState();
}

class _ResolutionDetailsSheetState
    extends ConsumerState<_ResolutionDetailsSheet> {
  String get _draftKey => 'resolve-${widget.resolution.name}';
  late final _amount = TextEditingController(
      text: MedicalManagementDrafts.text(widget.bill.id, _draftKey, 'amount') ??
          '');
  late final _reason = TextEditingController(
      text: MedicalManagementDrafts.text(widget.bill.id, _draftKey, 'reason') ??
          '');
  DateTime _date = DateTime.now();
  DateTime _month = DateTime.now();
  List<String> _documents = [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedMonth =
        MedicalManagementDrafts.text(widget.bill.id, _draftKey, 'month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    final savedDate =
        MedicalManagementDrafts.date(widget.bill.id, _draftKey, 'date');
    if (savedDate != null) _date = savedDate;
    _documents = MedicalManagementDrafts.documents(widget.bill.id, _draftKey);
    _saveTextDraft();
    _amount.addListener(_saveTextDraft);
    _reason.addListener(_saveTextDraft);
  }

  void _saveTextDraft() {
    MedicalManagementDrafts.setText(
        widget.bill.id, _draftKey, 'amount', _amount.text);
    MedicalManagementDrafts.setText(
        widget.bill.id, _draftKey, 'reason', _reason.text);
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final needsAmount =
        widget.resolution == MedicalRejectionResolution.userPaidProvider ||
            widget.resolution == MedicalRejectionResolution.adjustedDeduction;
    final major = double.tryParse(_amount.text.replaceAll(',', ''));
    final amount = needsAmount && major != null && major > 0
        ? Money.fromMajor(major, _currencyOf(widget.bill)).minorUnits
        : null;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(medicalManagementServiceProvider)
          .resolveInsurancePaidRejection(
            billId: widget.bill.id,
            resolution: widget.resolution,
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: () => mounted,
            reason: _reason.text.trim(),
            amountMinor: amount,
            paymentDate:
                widget.resolution == MedicalRejectionResolution.userPaidProvider
                    ? _date
                    : null,
            paymentMonth:
                widget.resolution == MedicalRejectionResolution.userPaidProvider
                    ? _monthKey(_month)
                    : null,
            expectedSalaryMonth: widget.resolution ==
                    MedicalRejectionResolution.adjustedDeduction
                ? _monthKey(_month)
                : null,
            documentPaths: _documents,
          );
      MedicalManagementDrafts.clear(widget.bill.id, _draftKey);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not record the resolution.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paidProvider =
        widget.resolution == MedicalRejectionResolution.userPaidProvider;
    final adjusted =
        widget.resolution == MedicalRejectionResolution.adjustedDeduction;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: paidProvider ? 'I paid the provider' : 'Adjusted deduction',
            subtitle: paidProvider
                ? 'Record the amount and month that left your account.'
                : 'Record the new expected share taken from salary.',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          if (paidProvider || adjusted)
            TextField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText:
                    paidProvider ? 'Amount paid' : 'Expected share deduction',
                border: const OutlineInputBorder(),
              ),
            ),
          _MonthYearField(
            label: paidProvider ? 'Payment month' : 'Expected salary month',
            month: _month.month,
            year: _month.year,
            onChanged: (month, year) => setState(() {
              _month = DateTime(year, month);
              MedicalManagementDrafts.setText(
                  widget.bill.id, _draftKey, 'month', _monthKey(_month));
            }),
          ),
          if (paidProvider)
            _DateTile(
              label: 'Payment date',
              date: _date,
              onPick: (picked) => setState(() {
                _date = picked;
                MedicalManagementDrafts.setDate(
                    widget.bill.id, _draftKey, 'date', picked);
              }),
            ),
          TextField(
            controller: _reason,
            decoration: const InputDecoration(
              labelText: 'Resolution note',
              border: OutlineInputBorder(),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, _draftKey, paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Save resolution'),
          ),
        ],
      ),
    );
  }
}

class MedicalAppealSheet extends ConsumerStatefulWidget {
  const MedicalAppealSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalAppealSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalAppealSheet> createState() => _MedicalAppealSheetState();
}

class _MedicalAppealSheetState extends ConsumerState<MedicalAppealSheet> {
  late final _reference = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'recordAppeal', 'reference') ??
          '');
  late final _notes = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'recordAppeal', 'notes') ??
          '');
  DateTime _date = DateTime.now();
  List<String> _documents = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final savedDate =
        MedicalManagementDrafts.date(widget.bill.id, 'recordAppeal', 'date');
    if (savedDate != null) _date = savedDate;
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'recordAppeal');
    _reference.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'recordAppeal', 'reference', _reference.text));
    _notes.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'recordAppeal', 'notes', _notes.text));
  }

  @override
  void dispose() {
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(medicalManagementServiceProvider).recordAppeal(
            billId: widget.bill.id,
            submittedAt: _date,
            reference:
                _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            notes: _notes.text.trim(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'recordAppeal');
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: 'Record appeal',
            subtitle:
                'The appeal is submitted through the insurer’s own process. This only tracks it.',
            onClose: () => Navigator.pop(context),
          ),
          _DateTile(
            label: 'Appeal submission date',
            date: _date,
            onPick: (picked) => setState(() {
              _date = picked;
              MedicalManagementDrafts.setDate(
                  widget.bill.id, 'recordAppeal', 'date', picked);
            }),
          ),
          TextField(
            controller: _reference,
            decoration: const InputDecoration(
              labelText: 'Appeal reference (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'recordAppeal', paths);
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('appealSave'),
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Save appeal'),
          ),
        ],
      ),
    );
  }
}

class MedicalAppealOutcomeSheet extends ConsumerWidget {
  const MedicalAppealOutcomeSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (sheet) => MedicalAppealOutcomeSheet(bill: bill),
    );
  }

  Future<void> _record(
      BuildContext context, WidgetRef ref, bool approved) async {
    try {
      await ref.read(medicalManagementServiceProvider).recordAppealOutcome(
            billId: bill.id,
            approved: approved,
            decidedAt: DateTime.now(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: () => true,
          );
      if (context.mounted) Navigator.pop(context, true);
    } on MedicalManagementException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Appeal outcome',
              subtitle: 'Record what the insurer decided.',
              onClose: () => Navigator.pop(context),
            ),
            ListTile(
              key: const Key('appealApproved'),
              title: const Text('Appeal approved'),
              onTap: () => _record(context, ref, true),
            ),
            ListTile(
              key: const Key('appealRejected'),
              title: const Text('Appeal rejected'),
              onTap: () => _record(context, ref, false),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalCancelRequestSheet extends ConsumerStatefulWidget {
  const MedicalCancelRequestSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalCancelRequestSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalCancelRequestSheet> createState() =>
      _MedicalCancelRequestSheetState();
}

class _MedicalCancelRequestSheetState
    extends ConsumerState<MedicalCancelRequestSheet> {
  late final _reason = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'cancelRequest', 'reason') ??
          '');
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'cancelRequest', 'reason', _reason.text));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).cancelRequest(
            billId: widget.bill.id,
            cancelledAt: DateTime.now(),
            reason: _reason.text.trim(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'cancelRequest');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not cancel the request.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Cancel request',
              subtitle:
                  'Cancelling does not reverse a provider payment. Any remaining charge must still be resolved.',
              onClose: () => Navigator.pop(context),
            ),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _cancel,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: const Text('Cancel request'),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalProviderRefundSheet extends ConsumerStatefulWidget {
  const MedicalProviderRefundSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalProviderRefundSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalProviderRefundSheet> createState() =>
      _MedicalProviderRefundSheetState();
}

class _MedicalProviderRefundSheetState
    extends ConsumerState<MedicalProviderRefundSheet> {
  late final _amount = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'recordProviderRefund', 'amount') ??
          formatMinorUnitsInput(
              widget.bill.billedAmount, _currencyOf(widget.bill)));
  DateTime _month = DateTime.now();
  DateTime _date = DateTime.now();
  List<String> _documents = [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedMonth = MedicalManagementDrafts.text(
        widget.bill.id, 'recordProviderRefund', 'month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    final savedDate = MedicalManagementDrafts.date(
        widget.bill.id, 'recordProviderRefund', 'date');
    if (savedDate != null) _date = savedDate;
    _documents = MedicalManagementDrafts.documents(
        widget.bill.id, 'recordProviderRefund');
    _amount.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'recordProviderRefund', 'amount', _amount.text));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final major = double.tryParse(_amount.text.replaceAll(',', ''));
    if (major == null || major <= 0) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).recordProviderRefund(
            billId: widget.bill.id,
            amountMinor:
                Money.fromMajor(major, _currencyOf(widget.bill)).minorUnits,
            actualMonth: _monthKey(_month),
            receivedDate: _date,
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'recordProviderRefund');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not record the provider refund.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: 'Provider refund',
            subtitle:
                'The hospital or clinic returned the full charge to you. This is not an insurance refund.',
            onClose: () => Navigator.pop(context),
          ),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(
              labelText: 'Refund amount',
              border: OutlineInputBorder(),
            ),
          ),
          _MonthYearField(
            label: 'Actual refund month',
            month: _month.month,
            year: _month.year,
            onChanged: (month, year) => setState(() {
              _month = DateTime(year, month);
              MedicalManagementDrafts.setText(widget.bill.id,
                  'recordProviderRefund', 'month', _monthKey(_month));
            }),
          ),
          Text(
            'This records money returned to you in the month it arrived.',
            style: TextStyle(
                fontSize: 12, color: MedicalTheme.subtleText(context)),
          ),
          _DateTile(
            label: 'Refund received date',
            date: _date,
            onPick: (picked) => setState(() {
              _date = picked;
              MedicalManagementDrafts.setDate(
                  widget.bill.id, 'recordProviderRefund', 'date', picked);
            }),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'recordProviderRefund', paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Record provider refund'),
          ),
        ],
      ),
    );
  }
}

class MedicalReopenSheet extends ConsumerStatefulWidget {
  const MedicalReopenSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalReopenSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalReopenSheet> createState() => _MedicalReopenSheetState();
}

class _MedicalReopenSheetState extends ConsumerState<MedicalReopenSheet> {
  late final _reason = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'reopenBill', 'reason') ??
          '');
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => MedicalManagementDrafts.setText(
        widget.bill.id, 'reopenBill', 'reason', _reason.text));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _reopen() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).reopenBill(
            billId: widget.bill.id,
            reason: _reason.text.trim(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'reopenBill');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not reopen the bill.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Reopen bill',
              subtitle:
                  'The original closure, events and history stay visible. Record why it is reopening.',
              onClose: () => Navigator.pop(context),
            ),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _reopen,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: const Text('Reopen'),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalCorrectionSheet extends ConsumerStatefulWidget {
  const MedicalCorrectionSheet({super.key, required this.bill});

  final MedicalBill bill;

  static Future<bool?> show(BuildContext context, MedicalBill bill) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => MedicalCorrectionSheet(bill: bill),
    );
  }

  @override
  ConsumerState<MedicalCorrectionSheet> createState() =>
      _MedicalCorrectionSheetState();
}

class _MedicalCorrectionSheetState
    extends ConsumerState<MedicalCorrectionSheet> {
  late final _amount = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'correctEvent', 'amount') ??
          formatMinorUnitsInput(
              widget.bill.settledAmountMinor ?? 0, _currencyOf(widget.bill)));
  late final _reason = TextEditingController(
      text: MedicalManagementDrafts.text(
              widget.bill.id, 'correctEvent', 'reason') ??
          '');
  DateTime _month = DateTime.now();
  List<String> _documents = [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final savedMonth =
        MedicalManagementDrafts.text(widget.bill.id, 'correctEvent', 'month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    _documents =
        MedicalManagementDrafts.documents(widget.bill.id, 'correctEvent');
    _saveTextDraft();
    _amount.addListener(_saveTextDraft);
    _reason.addListener(_saveTextDraft);
  }

  void _saveTextDraft() {
    MedicalManagementDrafts.setText(
        widget.bill.id, 'correctEvent', 'amount', _amount.text);
    MedicalManagementDrafts.setText(
        widget.bill.id, 'correctEvent', 'reason', _reason.text);
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final major = double.tryParse(_amount.text.replaceAll(',', ''));
    if (major == null || major <= 0) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicalManagementServiceProvider).correctFinancialEvent(
            billId: widget.bill.id,
            newAmountMinor:
                Money.fromMajor(major, _currencyOf(widget.bill)).minorUnits,
            actualMonth: _monthKey(_month),
            reason: _reason.text.trim(),
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            documentPaths: _documents,
            isAccessCurrent: () => mounted,
          );
      MedicalManagementDrafts.clear(widget.bill.id, 'correctEvent');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is MedicalManagementException
            ? error.message
            : 'Could not correct the event.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicalSheetHeader(
            title: 'Correct amount or month',
            subtitle:
                'The original event is kept. A reversal and a corrected event are added to history.',
            onClose: () => Navigator.pop(context),
          ),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(
              labelText: 'Corrected amount',
              border: OutlineInputBorder(),
            ),
          ),
          _MonthYearField(
            label: 'Corrected actual month',
            month: _month.month,
            year: _month.year,
            onChanged: (month, year) => setState(() {
              _month = DateTime(year, month);
              MedicalManagementDrafts.setText(
                  widget.bill.id, 'correctEvent', 'month', _monthKey(_month));
            }),
          ),
          Text(
            'History keeps the original event and records the corrected amount in the chosen month.',
            style: TextStyle(
                fontSize: 12, color: MedicalTheme.subtleText(context)),
          ),
          TextField(
            controller: _reason,
            decoration: const InputDecoration(
              labelText: 'Correction reason',
              border: OutlineInputBorder(),
            ),
          ),
          MedicalDocumentPicker(
            paths: _documents,
            onChanged: (paths) {
              setState(() => _documents = paths);
              MedicalManagementDrafts.setDocuments(
                  widget.bill.id, 'correctEvent', paths);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Save correction'),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onPick,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final first = firstDate ?? DateTime(2000);
    final last = lastDate ?? DateTime(2100);
    final initial = date.isBefore(first)
        ? first
        : date.isAfter(last)
            ? last
            : date;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(DateFormat.yMMMd().format(date)),
      trailing: const Icon(Icons.calendar_today_outlined),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: last,
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}

class _MonthYearField extends StatelessWidget {
  const _MonthYearField({
    super.key,
    required this.label,
    required this.month,
    required this.year,
    required this.onChanged,
  });

  final String label;
  final int month;
  final int year;
  final void Function(int month, int year) onChanged;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final newestYear = year > currentYear + 1 ? year : currentYear + 1;
    final years = [for (var y = newestYear; y >= 2000; y--) y];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: month,
              isExpanded: true,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder()),
              items: [
                for (var m = 1; m <= 12; m++)
                  DropdownMenuItem(
                      value: m,
                      child: Text(DateFormat.MMMM().format(DateTime(2000, m)))),
              ],
              onChanged: (value) {
                if (value != null) onChanged(value, year);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: year,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                for (final y in years)
                  DropdownMenuItem(value: y, child: Text('$y')),
              ],
              onChanged: (value) {
                if (value != null) onChanged(month, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _monthKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

CurrencyCode _currencyOf(MedicalBill bill) =>
    bill.currencyCode ?? CurrencyCode.huf;

/// The salary month a bill normally settles in: the month its insurance
/// request was created + 1. Falls back to the bill period + 1 for legacy rows
/// that predate a recorded submission date.
DateTime _billMonthPlusOne(MedicalBill bill) {
  final submitted = bill.submissionDate?.toLocal();
  if (submitted != null) {
    return DateTime(submitted.year, submitted.month + 1);
  }
  final parts = bill.yearMonth.split('-');
  if (parts.length == 2) {
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year != null && month != null && month >= 1 && month <= 12) {
      return DateTime(year, month + 1);
    }
  }
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1);
}

/// A safe default receipt date inside [month]: today when it belongs there,
/// otherwise the first day of that month.
DateTime _dateWithinMonth(DateTime month) {
  final now = DateTime.now();
  if (now.year == month.year && now.month == month.month) {
    return DateTime(now.year, now.month, now.day);
  }
  return DateTime(month.year, month.month, 1);
}

DateTime _lastDayOfMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0);
