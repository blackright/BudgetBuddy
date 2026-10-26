import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/refund_service.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_format.dart';
import '../models/savings_vault.dart';
import '../repositories/vault_repository.dart';
import '../vault_goal_schedule.dart';
import '../providers/vault_providers.dart';

class VaultGoalProgress extends ConsumerWidget {
  const VaultGoalProgress({super.key, required this.vault, this.maxDeposit});
  final SavingsVault vault;
  final int? maxDeposit;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = vault.goalTargetMinor;
    final code = vault.currencyCode;
    if (!vault.hasValidBalance || target == null || code == null) {
      return const SizedBox.shrink();
    }
    if (target <= 0 || target > 9007199254740991) {
      return const Text('Goal target needs review. Edit the savings goal.');
    }
    final reached = vault.totalMinor >= target;
    final schedule = VaultGoalSchedule(
        target: target,
        saved: vault.totalMinor,
        targetMonth: vault.goalTargetYearMonth,
        now: ref.watch(vaultNowProvider).valueOrNull ??
            ref.read(vaultClockProvider)());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(vault.goalName ?? 'Savings goal',
          style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      LinearProgressIndicator(
          value: (vault.totalMinor / target).clamp(0.0, 1.0)),
      const SizedBox(height: 8),
      Text(reached
          ? 'Goal reached'
          : 'Remaining: ${formatMinorUnits(target - vault.totalMinor, code)}'),
      Text('Target: ${formatMinorUnits(target, code)}'),
      if (schedule.invalid)
        const Text('Goal target month needs review. Edit the goal.'),
      if (!schedule.invalid && vault.goalTargetYearMonth != null) ...[
        Text('Target month: ${vault.goalTargetYearMonth}'),
        if (schedule.overdue)
          const Text(
              'Target month passed. Edit the goal to choose a new month.'),
        if (!reached && schedule.suggested != null) ...[
          Text(
              'Suggested per month: ${formatMinorUnits(schedule.suggested!, code)}'),
          Text('${schedule.months} saving months, including this month'),
          if (maxDeposit != null && maxDeposit! < schedule.suggested!)
            Text(
                'This month has ${formatMinorUnits(maxDeposit!, code)} available; ${formatMinorUnits(schedule.suggested! - maxDeposit!, code)} below the suggestion.'),
        ],
        const Text('Guidance only. No money is deducted automatically.'),
      ],
    ]);
  }
}

class VaultGoalEditor extends ConsumerStatefulWidget {
  const VaultGoalEditor({super.key, required this.vault});
  final SavingsVault vault;
  @override
  ConsumerState<VaultGoalEditor> createState() => _VaultGoalEditorState();
}

class _VaultGoalEditorState extends ConsumerState<VaultGoalEditor> {
  late final _name = TextEditingController(text: widget.vault.goalName);
  late final _amount = TextEditingController(
      text: widget.vault.goalTargetMinor == null
          ? ''
          : formatMinorUnitsInput(
              widget.vault.goalTargetMinor!, widget.vault.currencyCode!));
  bool _busy = false;
  late String? _targetMonth = widget.vault.goalTargetYearMonth;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save({bool remove = false}) async {
    final id = ref.read(activeProfileProvider).valueOrNull?.id;
    if (ref.read(budgetContextProvider).isShared ||
        id != widget.vault.profileId) {
      setState(
          () => _error = 'The profile changed. Close and reopen this editor.');
      return;
    }
    final target = parseRefundAmount(_amount.text, widget.vault.currencyCode!);
    if (!remove &&
        (_name.text.trim().isEmpty ||
            _name.text.trim().length > 80 ||
            target == null)) {
      setState(() => _error =
          'Enter a name (up to 80 characters) and a positive target with valid currency precision.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(vaultRepositoryProvider).saveGoal(
          profileId: widget.vault.profileId,
          actorId: id!,
          expectedCurrency: widget.vault.currency,
          isStillActive: () =>
              mounted &&
              !ref.read(budgetContextProvider).isShared &&
              ref.read(budgetContextProvider).profileId == id &&
              ref.read(activeProfileProvider).valueOrNull?.id == id,
          name: remove ? null : _name.text,
          targetMinor: remove ? null : target,
          targetYearMonth: remove ? null : _targetMonth,
          clock: ref.read(vaultClockProvider));
      if (mounted) {
        showFinancialFeedback(
            context, remove ? 'Savings goal removed' : 'Savings goal saved');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        showFinancialFeedback(
            context, 'Savings goal could not be saved. Please retry.',
            kind: FinancialFeedbackKind.error);
        setState(() {
          _busy = false;
          _error = error is ArgumentError
              ? 'Choose a valid current or future target month.'
              : 'Could not save this goal. Reopen the editor and retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: const Text('Savings goal'),
        content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'A goal tracks progress. It does not move or reserve money.'),
          TextField(
              key: const Key('goalName'),
              controller: _name,
              enabled: !_busy,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Goal name')),
          TextField(
              key: const Key('goalTarget'),
              controller: _amount,
              enabled: !_busy,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                  labelText:
                      'Target (${widget.vault.currency.toUpperCase()})')),
          TextButton.icon(
              key: const Key('goalMonth'),
              icon: const Icon(Icons.calendar_month),
              label: Text(_targetMonth == null
                  ? 'Add target month (optional)'
                  : 'Target month: $_targetMonth'),
              onPressed: _busy
                  ? null
                  : () async {
                      final now = ref.read(vaultClockProvider)();
                      final first = DateTime(now.year, now.month);
                      final parsed = validGoalMonth(_targetMonth)
                          ? DateTime.parse('${_targetMonth!}-01')
                          : first;
                      final selected = await showDatePicker(
                          context: context,
                          helpText: 'Choose a date in your target month',
                          firstDate: first,
                          lastDate: DateTime(9999, 12, 31),
                          initialDate: parsed.isBefore(first) ? first : parsed);
                      if (mounted && selected != null) {
                        setState(() => _targetMonth = vaultYearMonth(selected));
                      }
                    }),
          if (_targetMonth != null)
            TextButton(
                onPressed:
                    _busy ? null : () => setState(() => _targetMonth = null),
                child: const Text('Remove target month')),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ])),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          if (widget.vault.goalTargetMinor != null)
            TextButton(
                onPressed: _busy ? null : () => _save(remove: true),
                child: const Text('Remove goal')),
          FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving…' : 'Save goal')),
        ],
      ));
}
