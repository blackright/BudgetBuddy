import '../../../shared/presentation/financial_feedback.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../spaces/presentation/space_switcher.dart';
import '../../../core/services/month_end_report.dart';
import '../../../core/services/refund_service.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../providers/month_end_providers.dart';
import '../../pending_actions/providers/pending_actions_providers.dart';

class MonthEndScreen extends ConsumerWidget {
  const MonthEndScreen({super.key, this.initialMonth});

  /// The month a deep link asked for. It is honoured only when the service
  /// exposes that month; otherwise the screen falls back to a closable month.
  final String? initialMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _MonthEndBody(
      key:
          ValueKey('${ref.watch(budgetContextProvider)}|${initialMonth ?? ''}'),
      initialMonth: initialMonth);
}

class _MonthEndBody extends ConsumerStatefulWidget {
  const _MonthEndBody({super.key, this.initialMonth});
  final String? initialMonth;
  @override
  ConsumerState<_MonthEndBody> createState() => _MonthEndBodyState();
}

class _ProfileInput {
  _ProfileInput(BudgetProfile p, CurrencyCode currency)
      : amount = TextEditingController(
            text: formatMinorUnitsInput(
                p.defaultAllocationMinor ?? p.allocation, currency)),
        rule = p.monthEndRule,
        confirmedDefault = p.defaultAllocationMinor != null;
  final TextEditingController amount;
  MonthEndRule rule;
  bool confirmedDefault;
  String? destination;
  bool destinationReviewed = false;
}

class _MonthEndBodyState extends ConsumerState<_MonthEndBody> {
  final _inputs = <String, _ProfileInput>{};
  final _scrollController = ScrollController();
  List<BudgetProfile> _profiles = [];
  List<String> _months = [];
  CurrencyCode _currency = CurrencyCode.huf;
  String? _month, _error;
  bool _loading = true, _busy = false, _previewOutdated = false;
  MonthEndReport? _report;
  List<MonthEndChoice> _reviewedChoices = [];

  String get _contextName {
    final context = ref.read(budgetContextProvider);
    if (context.isShared) {
      final space = ref.read(activeSpaceProvider).valueOrNull;
      return space?.id == context.spaceId ? space!.displayName : 'Shared space';
    }
    final profile = ref.read(activeProfileProvider).valueOrNull;
    return profile?.id == context.profileId
        ? profile!.name
        : 'Personal profile';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final input in _inputs.values) {
      input.amount.dispose();
    }
    super.dispose();
  }

  String _monthOf(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}';

  /// The requested month wins when the service exposes it. Otherwise keep a
  /// completed month already selected, then prefer the earliest completed month
  /// that has no applied run, then the latest completed month, then the latest
  /// available month. The current/future month is never chosen implicitly.
  String? _defaultMonth(
      List<String> months, List<MonthEndRun> runs, String current) {
    if (months.isEmpty) return null;
    final completed = months.where((m) => m.compareTo(current) < 0).toList()
      ..sort();
    final selected = ref.read(budgetContextProvider).yearMonth;
    if (completed.contains(selected)) return selected;
    final applied =
        runs.where((run) => run.applied).map((run) => run.yearMonth).toSet();
    final unfinished = completed.where((m) => !applied.contains(m)).toList();
    if (unfinished.isNotEmpty) return unfinished.first;
    if (completed.isNotEmpty) return completed.last;
    return months.last;
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(monthEndServiceProvider).inputs();
      if (!mounted) return;
      List<MonthEndRun> runs;
      try {
        runs = await ref.read(monthEndRunsProvider.future);
      } catch (_) {
        runs = const [];
      }
      if (!mounted) return;
      final current = _monthOf(ref.read(monthEndServiceProvider).clock());
      final requested = widget.initialMonth;
      final requestedAvailable =
          requested != null && data.months.contains(requested);
      final kept =
          _month != null && data.months.contains(_month) ? _month : null;
      setState(() {
        _profiles = data.profiles;
        _months = data.months;
        _currency = data.currency;
        _month = kept ??
            (requestedAvailable
                ? requested
                : _defaultMonth(data.months, runs, current));
        _loading = false;
        _report = null;
        _previewOutdated = false;
        _error = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$error';
        });
      }
    }
  }

  void _invalidate() {
    setState(() {
      _previewOutdated = _report != null;
      _error = null;
    });
  }

  Future<void> _preview() async {
    if (_busy || _month == null) return;
    final choices = <MonthEndChoice>[];
    for (final p in _profiles.where((p) => p.yearMonth == _month)) {
      final input = _inputs[p.syncGuid]!;
      final raw = input.amount.text.trim();
      final amount = (raw == '0' ||
              (_currency.exponent > 0 && RegExp(r'^0\.0{1,2}$').hasMatch(raw)))
          ? 0
          : parseRefundAmount(raw, _currency);
      if (!input.confirmedDefault || amount == null) {
        setState(() {
          _error = 'Confirm a valid default allocation for ${p.name}.';
          _previewOutdated = _report != null;
        });
        return;
      }
      final next = nextFinancialMonth(_month!);
      final legacyTargets =
          _profiles.where((p) => p.yearMonth == next && p.familyGuid.isEmpty);
      final family = p.familyGuid.isEmpty ? p.syncGuid : p.familyGuid;
      final known =
          _profiles.where((p) => p.yearMonth == next && p.familyGuid == family);
      if (legacyTargets.isNotEmpty &&
          known.isEmpty &&
          !input.destinationReviewed) {
        setState(() {
          _error =
              'Choose a destination or explicitly create a new monthly profile for ${p.name}.';
          _previewOutdated = _report != null;
        });
        return;
      }
      choices.add(MonthEndChoice(
          sourceGuid: p.syncGuid,
          rule: input.rule,
          defaultAllocation: amount,
          destinationGuid: input.destination));
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final report = await ref
          .read(monthEndServiceProvider)
          .preview(_month!, choices: choices);
      if (mounted) {
        setState(() {
          _report = report;
          _reviewedChoices = choices;
          _previewOutdated = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut);
          }
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final report = _report;
    if (_busy || _previewOutdated || report == null || !report.ready) {
      return;
    }
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Finish ${report.yearMonth}?'),
                content: Text(
                    'Context: $_contextName. Carry ${formatMinorUnits(report.carried, _currency)} to ${report.destinationMonth} and release ${formatMinorUnits(report.released, _currency)} to reserve. This confirmed result cannot be rerun or edited.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm month-end'))
                ]));
    if (accepted != true || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(monthEndServiceProvider)
          .confirm(report, choices: _reviewedChoices);
      await ref.read(pendingActionServiceProvider).completeByRecord(
          'monthend.close', report.yearMonth, report.yearMonth);
      if (!mounted) return;
      showFinancialFeedback(context, 'Month-End confirmed');
      final saved =
          await ref.read(monthEndServiceProvider).preview(report.yearMonth);
      if (mounted) {
        setState(() {
          _report = saved;
          _previewOutdated = false;
        });
      }
    } catch (error) {
      if (mounted) {
        showFinancialFeedback(context,
            'Month-End action could not finish. Review the current settlement before retrying.',
            kind: FinancialFeedbackKind.error);
        setState(() {
          _error = '$error';
          _previewOutdated = _report != null;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(activeProfileProvider);
    ref.watch(activeSpaceProvider);
    final runs = ref.watch(monthEndRunsProvider).value ?? const [];
    final saved = runs.where((r) => r.yearMonth == _month).firstOrNull ??
        _report?.completed;
    final source = _profiles.where((p) => p.yearMonth == _month).toList();
    final next = _month == null ? null : nextFinancialMonth(_month!);
    final showActions = !_loading && saved == null && _months.isNotEmpty;
    return PopScope(
        canPop: !_busy,
        child: Scaffold(
            appBar: AppBar(title: const Text('Month-End'), actions: [
              IconButton(
                  onPressed: _busy ? null : _load,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh')
            ]),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                        IgnorePointer(
                            ignoring: _busy,
                            child: ContextSwitcherMenu(
                                child: ListTile(
                                    leading: const Icon(
                                        Icons.account_balance_wallet_outlined),
                                    title: Text(_contextName),
                                    subtitle:
                                        const Text('Personal / shared context'),
                                    trailing:
                                        const Icon(Icons.arrow_drop_down)))),
                        const Text(
                            'Review a completed month. Income and opening bank balances stay unchanged. Carried funds are reserved once; Reset releases unused funds.'),
                        const SizedBox(height: 16),
                        if (_months.isEmpty)
                          const Text(
                              'No months are available. Open a month in your budget first.'),
                        if (_months.isNotEmpty)
                          DropdownButtonFormField<String>(
                              key: const Key('sourceMonthDropdown'),
                              isExpanded: true,
                              initialValue: _month,
                              decoration: const InputDecoration(
                                  labelText: 'Source month'),
                              items: _months
                                  .map((m) => DropdownMenuItem(
                                      value: m, child: Text(m)))
                                  .toList(),
                              onChanged: _busy
                                  ? null
                                  : (value) => setState(() {
                                        _month = value;
                                        _report = null;
                                        _previewOutdated = false;
                                        _error = null;
                                      })),
                        if (saved != null) ...[
                          const SizedBox(height: 16),
                          Text(
                              saved.hasConflict
                                  ? 'Conflicting confirmations need review. Further month-end processing is blocked.'
                                  : 'Month already finished',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                              'Confirmed by ${saved.actor} on ${saved.createdAt.toLocal()}'),
                          if (!saved.applied)
                            const Text(
                                'This conflicting plan has not been applied.'),
                          Text(
                              'Carried: ${formatMinorUnits(saved.carriedMinor, CurrencyCode.tryParse(saved.currency) ?? _currency)}'),
                          Text(
                              'Released: ${formatMinorUnits(saved.releasedMinor, CurrencyCode.tryParse(saved.currency) ?? _currency)}'),
                          for (final line
                              in (jsonDecode(saved.reportJson)['lines']
                                  as List))
                            ListTile(
                                title: Text(line['name'] as String),
                                subtitle: Text(
                                    '${line['rule']} • next allocation ${formatMinorUnits(line['nextAllocation'] as int, CurrencyCode.tryParse(saved.currency) ?? _currency)}')),
                        ] else ...[
                          for (final p in source) _profileCard(p, next!),
                          if (_report != null) ...[
                            const SizedBox(height: 16),
                            Text('Ready to finish',
                                style: Theme.of(context).textTheme.titleLarge),
                            if (_report!.blockers.isEmpty)
                              const ListTile(
                                  leading: Icon(Icons.check_circle),
                                  title: Text('Financial checks passed')),
                            for (final blocker in _report!.blockers)
                              ListTile(
                                  leading: const Icon(Icons.warning_amber),
                                  title: Text(blocker)),
                            if (!_report!.canConfirm)
                              const Text(
                                  'Only the shared-space Owner can confirm. You can inspect this report.'),
                            for (final line in _report!.lines)
                              Card(
                                  child: ListTile(
                                      title: Text(line.name),
                                      subtitle: Text(
                                          'Allocated ${formatMinorUnits(line.amounts.allocation, _currency)} • Net spending ${formatMinorUnits(line.amounts.spent, _currency)}\n'
                                          'Unused ${formatMinorUnits(line.amounts.unused, _currency)} • Overspent ${formatMinorUnits(line.amounts.overspent, _currency)}\n'
                                          'Borrowed ${formatMinorUnits(line.borrowed, _currency)} | Deficit ${formatMinorUnits(line.deficit, _currency)} (not transferred)\n'
                                          '${line.amounts.rule == MonthEndRule.reset ? 'Reset' : 'Carry Forward'} → ${_report!.destinationMonth}\n'
                                          'Carry ${formatMinorUnits(line.amounts.carried, _currency)} • Release ${formatMinorUnits(line.amounts.released, _currency)}\n'
                                          'Next allocation ${formatMinorUnits(line.amounts.nextAllocation, _currency)}'))),
                          ],
                        ],
                      ]),
            bottomNavigationBar: showActions ? _actionArea(context) : null));
  }

  Widget _actionArea(BuildContext context) {
    final outdated = _previewOutdated && _report != null;
    final canFinish = _report != null && !_busy && !outdated && _report!.ready;
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (outdated)
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                        'Preview is outdated — review again before finishing.',
                        key: const Key('outdatedPreviewHint'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              if (_error != null)
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!,
                        key: const Key('monthEndError'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              Row(children: [
                Expanded(
                    child: FilledButton(
                        onPressed: _busy || _month == null ? null : _preview,
                        child: Text(_busy
                            ? 'Checking…'
                            : outdated
                                ? 'Review again'
                                : 'Review month-end'))),
                if (_report != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                      child: FilledButton(
                          onPressed: canFinish ? _confirm : null,
                          child: const Text('Finish month'))),
                ],
              ]),
            ])));
  }

  Widget _profileCard(BudgetProfile p, String next) {
    final input =
        _inputs.putIfAbsent(p.syncGuid, () => _ProfileInput(p, _currency));
    final family = p.familyGuid.isEmpty ? p.syncGuid : p.familyGuid;
    final targets = _profiles
        .where((d) =>
            d.yearMonth == next &&
            (d.familyGuid.isEmpty || d.familyGuid == family))
        .toList();
    final known = targets.where((d) => d.familyGuid == family).firstOrNull;
    return Card(
        key: ValueKey(p.syncGuid),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<MonthEndRule>(
                  isExpanded: true,
                  initialValue: input.rule,
                  decoration:
                      const InputDecoration(labelText: 'Month-end policy'),
                  items: const [
                    DropdownMenuItem(
                        value: MonthEndRule.reset, child: Text('Reset')),
                    DropdownMenuItem(
                        value: MonthEndRule.carryForward,
                        child: Text('Carry Forward'))
                  ],
                  onChanged: _busy
                      ? null
                      : (value) {
                          if (value != null) input.rule = value;
                          _invalidate();
                        }),
              TextField(
                  controller: input.amount,
                  inputFormatters: const [ThousandsSeparatorInputFormatter()],
                  enabled: !_busy,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText:
                          'Default allocation (${_currency.code.toUpperCase()})'),
                  onChanged: (_) {
                    input.confirmedDefault = false;
                    _invalidate();
                  }),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Confirm this default allocation'),
                  value: input.confirmedDefault,
                  onChanged: _busy
                      ? null
                      : (v) {
                          input.confirmedDefault = v ?? false;
                          _invalidate();
                        }),
              if (!input.confirmedDefault)
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                        'Tick the confirmation to include this profile in the review.',
                        key: ValueKey('defaultRequired-${p.syncGuid}'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12))),
              if (known != null)
                Text(
                    'Linked destination: ${known.name} ($next). Its existing allocation is preserved.')
              else
                DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: input.destinationReviewed
                        ? (input.destination ?? '__new')
                        : null,
                    decoration:
                        InputDecoration(labelText: 'Destination in $next'),
                    items: [
                      const DropdownMenuItem(
                          value: '__new',
                          child: Text('Create a new monthly profile')),
                      for (final target in targets)
                        DropdownMenuItem(
                            value: target.syncGuid, child: Text(target.name))
                    ],
                    onChanged: _busy
                        ? null
                        : (value) {
                            input.destinationReviewed = true;
                            input.destination = value == '__new' ? null : value;
                            _invalidate();
                          }),
              if (known == null &&
                  targets.any((d) => d.familyGuid.isEmpty) &&
                  !input.destinationReviewed)
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                        'Choose a destination or create a new monthly profile.',
                        key: ValueKey('destinationRequired-${p.syncGuid}'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12))),
              const Text(
                  'Choices apply to this settlement and the next monthly profile. Closed source records are preserved.'),
            ])));
  }
}
