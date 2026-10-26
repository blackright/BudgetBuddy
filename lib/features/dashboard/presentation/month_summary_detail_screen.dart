import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../engine/providers/month_summary_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/currency_resolution.dart';
import '../../finance/providers/finance_providers.dart';
import '../../medical/presentation/medical_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/conversion_footnote.dart';
import '../providers/dashboard_providers.dart';

/// Detail screen explaining how "Kept this month" is calculated.
/// T172: formula breakdown with drilldowns to related screens.
class MonthSummaryDetailScreen extends ConsumerWidget {
  const MonthSummaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);
    final main = ref.watch(mainCurrencyProvider);
    // Summary values are already converted. Resolve the same display currency
    // as monthSummaryProvider and format them without converting a second time.
    final currency = resolveContextDisplayCurrency(
      ref.watch(monthFinanceProvider).value,
      main,
    );
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
    final borrowed = ref.watch(dashboardBorrowingTotalsProvider).borrowed;
    final transferFormula = summary.vaultTransfers == 0
        ? ''
        : ' + Vault withdrawals - Vault deposits';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kept this month'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  Text(
                    'Kept this month',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _money(summary.kept, currency),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: MedicalTheme.semantic(
                        context,
                        summary.kept < 0
                            ? MedicalTheme.moneyOut
                            : MedicalTheme.moneyIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Free to spend (reserve draws from this)',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Money in bank
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Money in bank',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  if (summary.moneyInBank == null)
                    Text(
                      'Opening balance not confirmed yet. Confirm it in this month to see money in bank.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    Text(
                      _money(summary.moneyInBank!, currency),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Actual bank money = opening balance + income − paid out + returned (allocations not carved out)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // How it's calculated
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How it's calculated",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.carriedIn != 0 || summary.releasedAtMonthEnd != 0
                        ? 'Kept = Income − Paid out + Returned − Set aside for budgets − Carry over + Carried in + Released at month-end$transferFormula'
                        : 'Kept = Income − Paid out + Returned − Set aside for budgets − Carry over$transferFormula',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Income',
                    value: _money(summary.income, currency),
                    color: MedicalTheme.semantic(context, MedicalTheme.moneyIn),
                    onTap: () => context.push('/income_sources'),
                  ),
                  if (summary.vaultTransfers != 0)
                    _DetailRow(
                      label: 'Vault transfers (withdrawals - deposits)',
                      value:
                          '${summary.vaultTransfers > 0 ? '+' : '-'} ${_money(summary.vaultTransfers.abs(), currency)}',
                      color: MedicalTheme.semantic(
                          context,
                          summary.vaultTransfers > 0
                              ? MedicalTheme.moneyIn
                              : MedicalTheme.moneyOut),
                    ),
                  _DetailRow(
                    label: 'Paid out',
                    value: '- ${_money(summary.paymentsMade, currency)}',
                    color:
                        MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                    onTap: () => context.go('/expenses'),
                  ),
                  _DetailRow(
                    label: 'Returned',
                    value: '+ ${_money(summary.moneyReturned, currency)}',
                    color: MedicalTheme.semantic(context, MedicalTheme.moneyIn),
                  ),
                  if (summary.insuranceReturned > 0)
                    _DetailRow(
                      label: '  Insurance return',
                      value: '+ ${_money(summary.insuranceReturned, currency)}',
                      color:
                          MedicalTheme.semantic(context, MedicalTheme.moneyIn),
                      indent: 12,
                      onTap: () => context.go('/medical'),
                    ),
                  if (summary.expenseReturned > 0)
                    _DetailRow(
                      label: '  Expense returns',
                      value: '+ ${_money(summary.expenseReturned, currency)}',
                      color:
                          MedicalTheme.semantic(context, MedicalTheme.moneyIn),
                      indent: 12,
                      onTap: () => context.go(
                        '/expenses',
                        extra: {'status': ExpenseStatus.reimbursed.name},
                      ),
                    ),
                  if (summary.setAside > 0)
                    _DetailRow(
                      label: 'Set aside for budgets',
                      value: '- ${_money(summary.setAside, currency)}',
                      color:
                          MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                      onTap: () => context.push('/allocations'),
                    ),
                  if (borrowed > 0) ...[
                    _DetailRow(
                      label: 'Borrowed so far',
                      value: formatMinorUnits(borrowed, currency),
                      color:
                          MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                      onTap: () => context.push('/allocations'),
                    ),
                    Text(
                      'Borrowing is already included in paid out; it is not subtracted again.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (summary.carriedIn != 0)
                    _DetailRow(
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyIn),
                        label: 'Carried in',
                        value: '+ ${_money(summary.carriedIn, currency)}',
                        onTap: () => context.push('/month_end')),
                  if (summary.releasedAtMonthEnd != 0)
                    _DetailRow(
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyIn),
                        label: 'Released at month-end',
                        value:
                            '+ ${_money(summary.releasedAtMonthEnd, currency)}',
                        onTap: () => context.push('/month_end')),
                  if (summary.carryOver != 0)
                    _DetailRow(
                      label: 'Carry over',
                      value:
                          '${summary.carryOver < 0 ? '+' : '-'} ${_money(summary.carryOver.abs(), currency)}',
                      color: MedicalTheme.semantic(
                        context,
                        summary.carryOver < 0
                            ? MedicalTheme.moneyIn
                            : MedicalTheme.moneyOut,
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        'Kept this month',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        _money(summary.kept, currency),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MedicalTheme.semantic(
                            context,
                            summary.kept < 0
                                ? MedicalTheme.moneyOut
                                : MedicalTheme.moneyIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // At a glance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'At a glance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Planned',
                    value: _money(summary.planned, currency),
                    color: MedicalTheme.semantic(context, MedicalTheme.planned),
                    onTap: () => context.go(
                      '/expenses',
                      extra: {'status': ExpenseStatus.planned.name},
                    ),
                  ),
                  _DetailRow(
                    label: 'Cancelled',
                    value: _money(summary.cancelled, currency),
                    color: MedicalTheme.semantic(context, MedicalTheme.bank),
                  ),
                  _DetailRow(
                    label: 'Medical',
                    value: _money(summary.medicalPaid, currency),
                    color:
                        MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                    onTap: () => context.go('/medical'),
                  ),
                  if (summary.excessReturned > 0)
                    _DetailRow(
                      label: 'Excess returned',
                      value: _money(summary.excessReturned, currency),
                      color:
                          MedicalTheme.semantic(context, MedicalTheme.moneyIn),
                    ),
                  _DetailRow(
                    label: 'Allocated total',
                    value: _money(summary.allocated, currency),
                    color:
                        MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                    onTap: () => context.push('/allocations'),
                  ),
                  if (summary.usesOverriddenIncome)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Salary set for this month only',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConversionFootnote(
            main: main,
            display: currency,
            table: table,
          ),
        ],
      ),
    );
  }

  String _money(double amount, CurrencyCode currency) =>
      MedicalTheme.moneyMajor(currency, amount);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.indent = 0,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(indent, 4, 0, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
