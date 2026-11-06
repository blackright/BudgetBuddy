import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../core/models/balance_checkpoint.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/fx_revision.dart';
import '../../../core/services/balance_checkpoint_service.dart';
import '../../../core/services/receipt_snapshot_repository.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/modals/app_date_picker.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/time_picker_dialogs.dart';
import '../../sync/domain/sync_guid.dart';

class CheckpointSheetData {
  const CheckpointSheetData(this.sources, this.localZone, this.now);
  final CheckpointSources sources;
  final String localZone;
  final DateTime now;
}

/// Existing shared grouping formatter, with exact decimal -> minor conversion
/// at this money boundary. No binary-double parsing or silent rounding.
int? parseCheckpointAmount(String text, CurrencyCode currency) {
  final raw = text.replaceAll(',', '').trim();
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(raw) || raw.length > 24) return null;
  final parts = raw.split('.');
  if (parts.length == 2 && parts[1].length > currency.exponent) return null;
  final major = BigInt.tryParse(parts[0]);
  if (major == null) return null;
  final fraction = parts.length == 2
      ? BigInt.parse(parts[1].padRight(currency.exponent, '0'))
      : BigInt.zero;
  final value = major * BigInt.from(currency.minorUnitsPerMajor) + fraction;
  return value > BigInt.from(fxMoneyBound) ? null : value.toInt();
}

class BalanceCheckpointSheet extends StatefulWidget {
  const BalanceCheckpointSheet(
      {super.key,
      required this.load,
      required this.preview,
      required this.save});
  final Future<CheckpointSheetData> Function() load;
  final Future<CheckpointPreview> Function(CheckpointSources, CheckpointDraft)
      preview;
  final Future<void> Function(CheckpointPreview, String) save;
  @override
  State<BalanceCheckpointSheet> createState() => _BalanceCheckpointSheetState();
}

class _BalanceCheckpointSheetState extends State<BalanceCheckpointSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController(), _pool = TextEditingController();
  final _amountFocus = FocusNode(), _poolFocus = FocusNode();
  final _movementKeys = <String, GlobalKey>{};
  final _choices = <String, MovementChoice>{};
  CheckpointSheetData? _data;
  CheckpointPreview? _preview;
  DateTime? _balanceAt;
  bool _busy = true, _saved = false, _ack = false;
  String? _error;
  String _operation = newSyncGuid();
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    _pool.dispose();
    _amountFocus.dispose();
    _poolFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final data = await widget.load();
      BalanceCheckpointService.initializeZones();
      final zone = BalanceCheckpointService.location(data.localZone);
      final previous = data.sources.previous;
      final month =
          DateTime.parse('${data.sources.source.context.yearMonth}-01');
      final now = tz.TZDateTime.from(data.now, zone);
      if (!mounted) return;
      setState(() {
        _data = data;
        _busy = false;
        _error = null;
        _preview = null;
        _ack = false;
        _operation = newSyncGuid();
        _balanceAt = previous?.balanceAsOf ??
            (month.year == now.year && month.month == now.month
                ? data.now.toUtc()
                : tz.TZDateTime(zone, month.year, month.month).toUtc());
        _amount.text = data.sources.initialBalanceMinor == null
            ? ''
            : formatMinorUnitsInput(data.sources.initialBalanceMinor!,
                data.sources.source.currency);
        _pool.text = previous?.cashPoolDescription ?? '';
        _choices.clear();
        for (final choice in data.sources.previousChoices) {
          if (data.sources.movements.any(
              (m) => m.key == choice.key && m.revision == choice.revision)) {
            _choices[choice.key] = choice;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = checkpointMessage(e);
        });
      }
    }
  }

  void _changed() {
    setState(() {
      _preview = null;
      _ack = false;
      _error = null;
      _operation = newSyncGuid();
    });
  }

  Future<DateTime?> _pickTime(DateTime initial, {bool balance = false}) async {
    final data = _data!;
    final zone = BalanceCheckpointService.location(data.localZone);
    final local = tz.TZDateTime.from(initial, zone);
    final start = DateTime.parse('${data.sources.source.context.yearMonth}-01');
    final first = balance ? start : DateTime(1970);
    final last = balance
        ? DateTime(start.year, start.month + 1, 0)
        : DateTime(2100, 12, 31);
    final seed = DateTime(local.year, local.month, local.day);
    final day = await showAppDatePicker(
        context: context,
        initialDate: seed.isBefore(first)
            ? first
            : seed.isAfter(last)
                ? last
                : seed,
        firstDate: first,
        lastDate: last,
        helpText: balance
            ? 'When was this balance checked?'
            : 'Confirm actual payment date');
    if (day == null || !mounted) return null;
    final time = await showSafeTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: local.hour, minute: local.minute));
    if (time == null || !mounted) return null;
    final selected = tz.TZDateTime(
        zone, day.year, day.month, day.day, time.hour, time.minute);
    // A nonexistent DST wall time must not silently move to another hour.
    if (selected.hour != time.hour || selected.minute != time.minute) {
      setState(() => _error =
          'That time does not exist in this time zone. Choose another time.');
      return null;
    }
    return selected.toUtc();
  }

  Future<void> _buildPreview() async {
    final data = _data!;
    final amount =
        parseCheckpointAmount(_amount.text, data.sources.source.currency);
    final valid = _form.currentState!.validate();
    if (!valid) {
      final focus = amount == null ? _amountFocus : _poolFocus;
      focus.requestFocus();
      final target = focus.context;
      if (target != null) {
        await Scrollable.ensureVisible(target,
            duration: const Duration(milliseconds: 180));
      }
      return;
    }
    final unreviewed = data.sources.movements.where((m) =>
        !_choices.containsKey(m.key) ||
        (_choices[m.key]!.role != 'outside' &&
            m.actualAt == null &&
            _choices[m.key]!.actualAt == null));
    if (unreviewed.isNotEmpty) {
      setState(() => _error =
          'Review the first highlighted payment and confirm its date when needed.');
      final target = _movementKeys[unreviewed.first.key]?.currentContext;
      if (target != null) {
        await Scrollable.ensureVisible(target,
            duration: const Duration(milliseconds: 180));
      }
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await widget.preview(
          data.sources,
          CheckpointDraft(
              balanceMinor: amount!,
              balanceAsOf: _balanceAt!,
              localZone: data.localZone,
              pool: _pool.text,
              choices: _choices.values));
      if (mounted) {
        setState(() {
          _preview = result;
          _busy = false;
          _error = null;
          _ack = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = checkpointMessage(e);
        });
      }
    }
  }

  Future<void> _save() async {
    if (_busy || !_ack || _preview?.canConfirm != true) return;
    setState(() => _busy = true);
    try {
      await widget.save(_preview!, _operation);
      if (mounted) {
        setState(() {
          _busy = false;
          _saved = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = checkpointMessage(e);
        });
      }
    }
  }

  String _date(DateTime value) =>
      DateFormat('d MMM yyyy, HH:mm').format(tz.TZDateTime.from(
          value, BalanceCheckpointService.location(_data!.localZone)));
  String _money(int amount) =>
      '${_data!.sources.source.currency.code.toUpperCase()} ${formatMinorUnitsInput(amount, _data!.sources.source.currency)}';
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final data = _data;
    final enabled = !_busy && !_saved;
    return PopScope(
        canPop: !_busy,
        child: AppSheet(
            title: 'Review opening money',
            leading: Icon(Icons.account_balance_wallet_outlined,
                color: colors.primary),
            bodyScrollable: false,
            body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Form(
                    key: _form,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                              'Tell us when you checked your balance and which payments it already includes. This review does not create income or change your old opening balance.'),
                          if (data != null) ...[
                            const SizedBox(height: 16),
                            Card(
                                color: colors.primaryContainer,
                                margin: EdgeInsets.zero,
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              DateFormat.yMMMM().format(
                                                  DateTime.parse(
                                                      '${data.sources.source.context.yearMonth}-01')),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          const Text(
                                              'Cash review only; new financial rules remain inactive.'),
                                        ]))),
                            const SizedBox(height: 16),
                            TextFormField(
                                key: const Key('checkpointAmount'),
                                controller: _amount,
                                focusNode: _amountFocus,
                                enabled: enabled,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: const [
                                  ThousandsSeparatorInputFormatter()
                                ],
                                decoration: InputDecoration(
                                    labelText: 'Balance checked',
                                    prefixText:
                                        '${data.sources.source.currency.code.toUpperCase()} '),
                                onChanged: (_) => _changed(),
                                validator: (value) => parseCheckpointAmount(
                                            value ?? '',
                                            data.sources.source.currency) ==
                                        null
                                    ? 'Enter a valid amount; zero is allowed.'
                                    : null),
                            const SizedBox(height: 12),
                            TextFormField(
                                key: const Key('checkpointScope'),
                                controller: _pool,
                                focusNode: _poolFocus,
                                enabled: enabled,
                                maxLength: 120,
                                decoration: const InputDecoration(
                                    labelText: 'Money covered by this balance',
                                    hintText:
                                        'Example: my bank account and budget cash'),
                                onChanged: (_) => _changed(),
                                validator: (value) => (value ?? '')
                                        .trim()
                                        .isEmpty
                                    ? 'Describe the money covered by this balance.'
                                    : null),
                            OutlinedButton.icon(
                                onPressed: enabled
                                    ? () async {
                                        final value = await _pickTime(
                                            _balanceAt!,
                                            balance: true);
                                        if (value != null && mounted) {
                                          _balanceAt = value;
                                          _changed();
                                        }
                                      }
                                    : null,
                                icon: const Icon(Icons.schedule),
                                label: Text(
                                    'Balance checked: ${_date(_balanceAt!)}')),
                            Text('Time zone: ${data.localZone}'),
                            const SizedBox(height: 16),
                            Text(
                                'Review payments (${data.sources.movements.length})',
                                style: Theme.of(context).textTheme.titleMedium),
                            const Text(
                                'Already included: happened before the balance check. Later: happened afterward. Outside: belongs to money this balance does not cover.'),
                            if (data.sources.movements.isEmpty)
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                      'No recorded cash movements to review for this month. Expected Income Sources are not actual receipts.')),
                            for (final movement in data.sources.movements)
                              Card(
                                  key: _movementKeys.putIfAbsent(
                                      movement.key, () => GlobalKey()),
                                  margin: const EdgeInsets.only(top: 12),
                                  child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(movement.label,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall),
                                            Text(
                                                '${movement.signedMinor < 0 ? 'Payment' : 'Money received'}: ${_money(movement.signedMinor.abs())}'),
                                            DropdownButtonFormField<String>(
                                                initialValue:
                                                    _choices[movement.key]
                                                        ?.role,
                                                isExpanded: true,
                                                decoration: const InputDecoration(
                                                    labelText:
                                                        'How does it relate to this balance?'),
                                                items: const [
                                                  DropdownMenuItem(
                                                      value: 'included',
                                                      child: Text(
                                                          'Already included')),
                                                  DropdownMenuItem(
                                                      value: 'later',
                                                      child: Text(
                                                          'Later movement')),
                                                  DropdownMenuItem(
                                                      value: 'outside',
                                                      child: Text(
                                                          'Outside this balance'))
                                                ],
                                                onChanged: enabled
                                                    ? (role) {
                                                        if (role == null) {
                                                          return;
                                                        }
                                                        _choices[
                                                            movement
                                                                .key] = MovementChoice(
                                                            key: movement.key,
                                                            revision: movement
                                                                .revision,
                                                            role: role,
                                                            actualAt: movement
                                                                    .actualAt ??
                                                                _choices[movement
                                                                        .key]
                                                                    ?.actualAt);
                                                        _changed();
                                                      }
                                                    : null),
                                            if (_choices[movement.key]?.role !=
                                                'outside') ...[
                                              if (movement.actualAt != null)
                                                Text(
                                                    'Paid: ${_date(movement.actualAt!)}')
                                              else
                                                TextButton.icon(
                                                    onPressed: enabled
                                                        ? () async {
                                                            final value = await _pickTime(
                                                                _choices[movement
                                                                            .key]
                                                                        ?.actualAt ??
                                                                    _balanceAt!);
                                                            final choice =
                                                                _choices[
                                                                    movement
                                                                        .key];
                                                            if (value != null &&
                                                                choice !=
                                                                    null &&
                                                                mounted) {
                                                              _choices[
                                                                  movement
                                                                      .key] = MovementChoice(
                                                                  key: movement
                                                                      .key,
                                                                  revision: movement
                                                                      .revision,
                                                                  role: choice
                                                                      .role,
                                                                  actualAt:
                                                                      value);
                                                              _changed();
                                                            }
                                                          }
                                                        : null,
                                                    icon: const Icon(Icons
                                                        .event_available_outlined),
                                                    label: Text(_choices[
                                                                    movement
                                                                        .key]
                                                                ?.actualAt ==
                                                            null
                                                        ? 'Confirm actual payment date'
                                                        : 'Payment: ${_date(_choices[movement.key]!.actualAt!)}')),
                                            ],
                                          ]))),
                            for (final blocker in data.sources.blockers)
                              _notice(
                                  checkpointMessage(
                                      ReceiptGuardException(blocker)),
                                  colors.errorContainer),
                            if (_preview != null) ...[
                              const SizedBox(height: 16),
                              _summary('Balance checked',
                                  _preview!.draft.balanceMinor),
                              _summary('Already included: money in',
                                  _preview!.cash.includedCreditMinor),
                              _summary('Already included: payments',
                                  _preview!.cash.includedDebitMinor),
                              _summary('Later money in',
                                  _preview!.cash.laterCreditMinor),
                              _summary('Later payments',
                                  _preview!.cash.laterDebitMinor),
                              _summary('Reserved for other months',
                                  data.sources.reservedFundingMinor),
                              if (_preview!.cash.bankMinor != null)
                                _summary('Cash balance after later movements',
                                    _preview!.cash.bankMinor!),
                              const Text(
                                  'This is a cash preview, not Free to spend. Existing allocations and funding protections still apply.'),
                              for (final blocker in _preview!.blockers)
                                _notice(
                                    checkpointMessage(
                                        ReceiptGuardException(blocker)),
                                    colors.errorContainer),
                              if (_preview!.canConfirm && !_saved)
                                CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: _ack,
                                    onChanged: enabled
                                        ? (v) =>
                                            setState(() => _ack = v ?? false)
                                        : null,
                                    title: const Text(
                                        'I reviewed the balance date, scope and included payments.')),
                            ],
                            if (!_saved) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                  onPressed: enabled ? _buildPreview : null,
                                  child: const Text('Preview balance')),
                              FilledButton(
                                  onPressed: enabled &&
                                          _ack &&
                                          _preview?.canConfirm == true
                                      ? _save
                                      : null,
                                  child: const Text('Confirm balance review')),
                            ],
                          ],
                          if (_busy)
                            const Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    Center(child: CircularProgressIndicator())),
                          if (_error != null)
                            Semantics(
                                liveRegion: true,
                                child: _notice(_error!, colors.errorContainer)),
                          if (_saved)
                            Semantics(
                                liveRegion: true,
                                child: _notice(
                                    'Balance review saved on this device. Historical records and Dashboard calculations are unchanged.',
                                    colors.secondaryContainer)),
                          if (!_busy && !_saved)
                            TextButton(
                                onPressed: _load,
                                child: const Text('Refresh recorded payments')),
                          TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(_saved ? 'Done' : 'Close')),
                        ])))));
  }

  Widget _summary(String label, int value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(label),
            Text(_money(value),
                style: const TextStyle(fontWeight: FontWeight.w600))
          ]));
  Widget _notice(String text, Color color) => Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text));
}

String checkpointMessage(Object error) {
  final code = error is ReceiptGuardException ? error.code : '';
  return switch (code) {
    'adoptionRequired' =>
      'Review receipt setup first, including its starting month.',
    'missingCashScope' =>
      'Describe which bank or cash money this balance covers.',
    'balanceOutsideMonth' => 'The balance check must be in the selected month.',
    'invalidTimezone' =>
      'The phone time zone could not be verified. Retry after checking phone settings.',
    'futureBalance' ||
    'futurePayment' =>
      'A balance check or actual payment cannot be in the future.',
    'beforeCheckpointNotIncluded' =>
      'A payment dated before the balance check must be marked Already included, or its date/scope needs correction.',
    'afterCheckpointIncluded' =>
      'A payment dated after the balance check must be marked Later movement, or its date needs correction.',
    'paymentDateNeedsReview' ||
    'movementNeedsReview' =>
      'Confirm the payment choices and any missing actual dates.',
    'stalePreview' ||
    'duplicateMismatch' =>
      'Recorded information changed. Refresh the payments and review again before saving.',
    'ownerRequired' => 'Only the budget owner can review opening money.',
    'missingMonth' ||
    'missingOpeningReview' =>
      'Complete the month and confirm its existing opening balance first; zero is allowed.',
    'sealedMonth' ||
    'settledMonth' ||
    'sweptMonth' ||
    'settlementNeedsReview' =>
      'This month is closed, processed or needs Month-End review. Choose an eligible open month.',
    'accessChanged' ||
    'wrongOwner' ||
    'notActiveMember' =>
      'Access changed. Reopen the review after unlocking the correct budget.',
    'movementMoneyNeedsReview' ||
    'invalidMoney' =>
      'Some recorded amounts or currency evidence need review. No money was changed.',
    'fundingAssignmentNeedsReview' =>
      'Reserved money could not be verified against its source. Resolve it before confirming.',
    'duplicateMovement' ||
    'unknownMovement' ||
    'invalidInclusion' =>
      'The payment list needs review. Refresh the recorded payments.',
    _ =>
      'The review could not be completed. No money was changed. Retry or check the selected month.',
  };
}
