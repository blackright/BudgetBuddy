import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/selected_month_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../medical/presentation/medical_theme.dart';
import '../providers/finance_providers.dart';
import '../repositories/month_finance_repository.dart';

/// Income settings: the profile-wide default salary and a per-month override.
///
/// Two separate controls because they answer different questions. The default
/// applies to every month that has no opinion of its own; the override pins one
/// specific month, which is how an irregular month — bonus, holiday, unpaid
/// stretch — is handled without editing history (FR-001, FR-005).
///
/// Changing the default never rewrites months that already exist (FR-004); a
/// month only stops following it once it carries its own override.
class NetSalarySection extends ConsumerWidget {
  const NetSalarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final repository = ref.watch(monthFinanceRepositoryProvider);
    final resolved = ref.watch(resolvedIncomeProvider);
    // Salary is kept in the profile's main currency; show its symbol on entry
    // rather than a hardcoded default (FR-009, defect D5).
    final currency = ref.watch(mainCurrencyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Net salary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'What you actually take home, after tax.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _AmountField(
              key: const Key('defaultSalaryField'),
              label: 'Default salary',
              helper: 'Applies to every month without its own amount.',
              initialValue: ref.watch(defaultNetSalaryProvider),
              prefixText: '${currency.symbol} ',
              onSubmitted: (amount) =>
                  repository.saveDefaultNetSalary(amount ?? 0.0),
            ),
            const Divider(height: 28),
            _AmountField(
              key: const Key('monthOverrideField'),
              label: '${monthLabel(yearMonth)} only',
              helper: resolved.usesOverride
                  ? 'Currently overridden for this month.'
                  : 'Leave empty to follow the default salary.',
              initialValue: resolved.usesOverride ? resolved.amount : null,
              prefixText: '${currency.symbol} ',
              onSubmitted: (amount) =>
                  repository.saveNetSalaryOverride(yearMonth, amount),
            ),
            const SizedBox(height: 12),
            Text(
              'Income used for this month: ${MedicalTheme.moneyMajor(currency, resolved.amount)}'
              '${resolved.usesOverride ? ' (override)' : ' (default)'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// A numeric field that reports `null` when cleared, so an override can be
/// removed without typing a zero.
class _AmountField extends StatefulWidget {
  const _AmountField({
    super.key,
    required this.label,
    required this.helper,
    required this.initialValue,
    required this.onSubmitted,
    this.prefixText,
  });

  final String label;
  final String helper;
  final double? initialValue;
  final ValueChanged<double?> onSubmitted;
  final String? prefixText;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _controller =
      TextEditingController(text: _format(widget.initialValue));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim().replaceAll(',', '');
    if (raw.isEmpty) {
      widget.onSubmitted(null);
      return;
    }
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed < 0) return;
    widget.onSubmitted(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            helperText: widget.helper,
            helperMaxLines: 2,
            prefixText: widget.prefixText,
          ),
          onSubmitted: (_) => _submit(),
          onEditingComplete: _submit,
        ),
      ],
    );
  }

  static String _format(double? amount) {
    if (amount == null) return '';
    return NumberFormat('#,##0.00').format(amount);
  }
}
