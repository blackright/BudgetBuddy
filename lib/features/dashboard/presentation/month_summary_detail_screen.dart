import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/conversion_footnote.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/month_summary_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../finance/providers/finance_providers.dart';
import '../../medical/presentation/medical_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_copy.dart';

/// The single statement behind the Dashboard's month row.
///
/// The screen is intentionally calm: one hero, three section titles, and a
/// single calculation container holding independent tonal tiles. The formula
/// is a quiet caption so the money movement stays readable at a glance.
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
    final title = DashboardCopy.monthStatementLabel(yearMonth);
    final heroTitle =
        '${DashboardCopy.kept} ${DashboardCopy.heroCaption(yearMonth)}';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, key: const Key('statementTitle')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _StatementHero(
            title: heroTitle,
            amount: _money(summary.kept, currency),
            color: summary.kept < 0
                ? MedicalTheme.semantic(context, MedicalTheme.moneyOut)
                : summary.kept == 0
                    ? scheme.onSurface
                    : MedicalTheme.semantic(context, MedicalTheme.moneyIn),
          ),
          const SizedBox(height: 16),
          _IncomeSummaryCard(
            key: const Key('statementIncome'),
            amount: _money(summary.income, currency),
            onTap: () => context.push('/income_sources'),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            key: Key('statementMoneyInBankTitle'),
            text: _StatementCopy.moneyInBankTitle,
          ),
          const SizedBox(height: 10),
          _MoneyInBankCard(
            key: const Key('statementMoneyInBank'),
            amount: summary.moneyInBank == null
                ? null
                : _money(summary.moneyInBank!, currency),
            missingText: _StatementCopy.openingBalanceMissing,
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            key: Key('statementCalculationTitle'),
            text: _StatementCopy.calculationTitle,
          ),
          const SizedBox(height: 10),
          Container(
            key: const Key('statementCalculationSection'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final labelWidth =
                    _measureLabelWidth(context, constraints.maxWidth);
                return _StatementTileMetrics(
                  labelWidth: labelWidth,
                  child: Column(
                    children: [
                      if (summary.vaultTransfers != 0)
                        _StatementTile(
                          key: const Key('statementVaultTransfers'),
                          label: _StatementCopy.savingsTransfers,
                          caption: _StatementCopy.savingsTransfersCaption,
                          value: _signed(
                            summary.vaultTransfers,
                            negative: summary.vaultTransfers < 0,
                            currency: currency,
                          ),
                          color: MedicalTheme.semantic(
                            context,
                            summary.vaultTransfers > 0
                                ? MedicalTheme.moneyIn
                                : MedicalTheme.moneyOut,
                          ),
                        ),
                      _StatementTile(
                        key: const Key('statementPaidOut'),
                        label: _StatementCopy.moneyPaidOut,
                        caption: _StatementCopy.moneyPaidOutCaption,
                        value: _signed(
                          summary.paymentsMade,
                          negative: true,
                          currency: currency,
                        ),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyOut),
                        onTap: () => context.go('/expenses'),
                      ),
                      _StatementTile(
                        key: const Key('statementBack'),
                        label: _StatementCopy.moneyBack,
                        caption: _StatementCopy.moneyBackCaption,
                        value: _signed(
                          summary.moneyReturned,
                          negative: false,
                          currency: currency,
                        ),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyIn),
                        subRows: [
                          if (summary.insuranceReturned > 0)
                            _SubRow(
                              key: const Key('statementMedicalBack'),
                              label: _StatementCopy.medicalRefunds,
                              value: _signed(
                                summary.insuranceReturned,
                                negative: false,
                                currency: currency,
                              ),
                              color: MedicalTheme.semantic(
                                  context, MedicalTheme.moneyIn),
                              onTap: () => context.go('/medical'),
                            ),
                          if (summary.expenseReturned > 0)
                            _SubRow(
                              key: const Key('statementExpenseBack'),
                              label: _StatementCopy.expenseRefunds,
                              value: _signed(
                                summary.expenseReturned,
                                negative: false,
                                currency: currency,
                              ),
                              color: MedicalTheme.semantic(
                                  context, MedicalTheme.moneyIn),
                              onTap: () => context.go(
                                '/expenses',
                                extra: {
                                  'status': ExpenseStatus.reimbursed.name
                                },
                              ),
                            ),
                        ],
                      ),
                      _StatementTile(
                        key: const Key('statementPlanned'),
                        label: _StatementCopy.plannedSpending,
                        caption: _StatementCopy.plannedSpendingCaption,
                        value: _money(summary.planned, currency),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.planned),
                        onTap: () => context.go(
                          '/expenses',
                          extra: {'status': ExpenseStatus.planned.name},
                        ),
                      ),
                      if (summary.cancelled > 0)
                        _StatementTile(
                          key: const Key('statementCancelled'),
                          label: _StatementCopy.cancelledSpending,
                          caption: _StatementCopy.cancelledSpendingCaption,
                          value: _money(summary.cancelled, currency),
                          color:
                              MedicalTheme.semantic(context, MedicalTheme.bank),
                        ),
                      _StatementTile(
                        key: const Key('statementSetAside'),
                        label: _StatementCopy.budgetSetAside,
                        caption: _StatementCopy.budgetSetAsideCaption,
                        value: _signed(
                          summary.setAside,
                          negative: true,
                          currency: currency,
                        ),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyOut),
                        onTap: () => context.push('/allocations'),
                      ),
                      _StatementTile(
                        key: const Key('statementBorrowed'),
                        label: _StatementCopy.borrowedFromReserve,
                        caption: borrowed > 0
                            ? _StatementCopy.borrowedCaption
                            : _StatementCopy.noBorrowingCaption,
                        value: formatMinorUnits(borrowed, currency),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyOut),
                        onTap: () => context.push('/allocations'),
                      ),
                      if (summary.carryOver != 0)
                        _StatementTile(
                          key: const Key('statementReserved'),
                          label: _StatementCopy.heldForNextMonth,
                          caption: _StatementCopy.heldForNextMonthCaption,
                          value: _signed(
                            summary.carryOver,
                            negative: summary.carryOver > 0,
                            currency: currency,
                          ),
                          color: MedicalTheme.semantic(
                            context,
                            summary.carryOver < 0
                                ? MedicalTheme.moneyIn
                                : MedicalTheme.moneyOut,
                          ),
                          onTap: () => context.push('/month_end'),
                        ),
                      _StatementTile(
                        key: const Key('statementCarriedOver'),
                        label: _StatementCopy.carriedOver,
                        caption: _StatementCopy.carriedOverCaption,
                        value: _signed(
                          summary.carriedIn,
                          negative: false,
                          currency: currency,
                        ),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyIn),
                        onTap: () => context.push('/month_end'),
                      ),
                      _StatementTile(
                        key: const Key('statementReleased'),
                        label: _StatementCopy.released,
                        caption: _StatementCopy.releasedCaption,
                        value: _signed(
                          summary.releasedAtMonthEnd,
                          negative: false,
                          currency: currency,
                        ),
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.moneyIn),
                        onTap: () => context.push('/month_end'),
                      ),
                      const SizedBox(height: 2),
                      KeyedSubtree(
                        key: const Key('statementResultTile'),
                        child: _ResultTile(
                          key: const Key('statementKeptTotal'),
                          label: _StatementCopy.whatYouKept,
                          caption: _StatementCopy.whatYouKeptCaption,
                          amount: _money(summary.kept, currency),
                        ),
                      ),
                      if (summary.usesOverriddenIncome)
                        Padding(
                          key: const Key('overrideMarker'),
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _StatementCopy.overrideNote,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                        child: Text(
                          _formula(summary.vaultTransfers, summary.carryOver),
                          key: const Key('statementFormula'),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: const Key('statementConversionNote'),
            child: ConversionFootnote(
              main: main,
              display: currency,
              table: table,
            ),
          ),
        ],
      ),
    );
  }

  /// One shared label column, measured from the longest calculation label.
  ///
  /// The column is clamped so the value column keeps enough room on narrow
  /// screens and at large text scales. The label wraps in that clamped case;
  /// the separator still stays at the same x-position in every tile.
  double _measureLabelWidth(BuildContext context, double tileWidth) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final painter = TextPainter(
      text: TextSpan(text: _StatementCopy.carriedOver, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final available = tileWidth - 35;
    final maxWidth = available > 0 ? available * 0.68 : 0.0;
    final desired = painter.width + 4;
    return desired < maxWidth ? desired : maxWidth;
  }

  String _formula(double vaultTransfers, double carryOver) {
    final buffer = StringBuffer(
      '${_StatementCopy.formulaPrefix}Income − money paid out + money back '
      '− budget set-aside',
    );
    if (carryOver != 0) buffer.write(' − held for next month');
    buffer.write(' + carried over from last month + released at month end');
    if (vaultTransfers != 0) buffer.write(' + savings transfers');
    return buffer.toString();
  }

  String _signed(double amount,
      {required bool negative, required CurrencyCode currency}) {
    if (amount == 0) return _money(0, currency);
    return '${negative ? '-' : '+'} ${_money(amount.abs(), currency)}';
  }

  String _money(double amount, CurrencyCode currency) =>
      MedicalTheme.moneyMajor(currency, amount);
}

class _StatementHero extends StatelessWidget {
  const _StatementHero({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          key: const Key('statementHeroTitle'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              key: const Key('statementKept'),
              maxLines: 1,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.0,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _IncomeSummaryCard extends StatelessWidget {
  const _IncomeSummaryCard({
    super.key,
    required this.amount,
    required this.onTap,
  });

  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _StatementCopy.income,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _StatementCopy.incomeCaption,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    amount,
                    key: const Key('statementIncomeAmount'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyInBankCard extends StatelessWidget {
  const _MoneyInBankCard({
    super.key,
    required this.amount,
    required this.missingText,
  });

  final String? amount;
  final String missingText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (amount == null)
            Text(
              missingText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount!,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            _StatementCopy.moneyInBankCaption,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

Key? _dividerKeyFor(Key? key) {
  if (key is ValueKey<String>) {
    return ValueKey('${key.value}Divider');
  }
  return null;
}

class _StatementTileMetrics extends InheritedWidget {
  const _StatementTileMetrics({
    required this.labelWidth,
    required super.child,
  });

  final double labelWidth;

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_StatementTileMetrics>()
            ?.labelWidth ??
        160;
  }

  @override
  bool updateShouldNotify(_StatementTileMetrics oldWidget) =>
      oldWidget.labelWidth != labelWidth;
}

class _StatementTile extends StatelessWidget {
  const _StatementTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.caption,
    this.onTap,
    this.subRows = const [],
  });

  final String label;
  final String value;
  final Color color;
  final String? caption;
  final VoidCallback? onTap;
  final List<Widget> subRows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelWidth = _StatementTileMetrics.of(context);
    final content = Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 0, 12),
                child: SizedBox(
                  width: labelWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (caption != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          caption!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                key: _dividerKeyFor(key),
                width: 1,
                color: scheme.outlineVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: _StatementValue(
                    value: value,
                    color: color,
                    style: Theme.of(context).textTheme.titleMedium,
                    showChevron: onTap != null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (subRows.isNotEmpty) ...[
          Divider(height: 1, color: scheme.outlineVariant),
          ...subRows,
        ],
      ],
    );

    final tile = Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: tile,
    );
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelWidth = _StatementTileMetrics.of(context);
    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 0, 8),
            child: SizedBox(
              width: labelWidth,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Container(
            key: _dividerKeyFor(key),
            width: 1,
            color: scheme.outlineVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
              child: _StatementValue(
                value: value,
                color: color,
                style: Theme.of(context).textTheme.bodyMedium,
                showChevron: onTap != null,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

class _StatementValue extends StatelessWidget {
  const _StatementValue({
    required this.value,
    required this.color,
    required this.style,
    required this.showChevron,
  });

  final String value;
  final Color color;
  final TextStyle? style;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              maxLines: 1,
              textAlign: TextAlign.right,
              style: style?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 20,
          child: showChevron
              ? Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                )
              : null,
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    super.key,
    required this.label,
    required this.caption,
    required this.amount,
  });

  final String label;
  final String caption;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelWidth = _StatementTileMetrics.of(context);
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
              child: SizedBox(
                width: labelWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.78,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              key: _dividerKeyFor(key),
              width: 1,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 12, 14),
                child: _StatementValue(
                  value: amount,
                  color: scheme.onPrimaryContainer,
                  style: Theme.of(context).textTheme.titleLarge,
                  showChevron: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementCopy {
  const _StatementCopy._();

  static const String moneyInBankTitle = 'Money in the bank';
  static const String moneyInBankCaption =
      'Opening balance + income − money paid out + money back';
  static const String openingBalanceMissing =
      'Opening balance not confirmed yet. Confirm it in this month to see money in the bank.';
  static const String calculationTitle = 'How this month adds up';

  static const String income = 'Income';
  static const String incomeCaption = 'Money received this month';
  static const String savingsTransfers = 'Savings transfers';
  static const String savingsTransfersCaption = 'Moved to or from savings';
  static const String moneyPaidOut = 'Money paid out';
  static const String moneyPaidOutCaption = 'Left your account';
  static const String moneyBack = 'Money back';
  static const String moneyBackCaption = 'Refunds and reimbursements';
  static const String medicalRefunds = 'Medical refunds';
  static const String expenseRefunds = 'Expense refunds';
  static const String plannedSpending = 'Planned spending';
  static const String plannedSpendingCaption = 'Committed, not paid';
  static const String cancelledSpending = 'Cancelled spending';
  static const String cancelledSpendingCaption = 'No longer affects the month';
  static const String budgetSetAside = 'Budget set-aside';
  static const String budgetSetAsideCaption = 'Reserved for budget profiles';
  static const String borrowedFromReserve = 'Borrowed from reserve';
  static const String borrowedCaption = 'Already included in money paid out';
  static const String noBorrowingCaption = 'No borrowing this month';
  static const String heldForNextMonth = 'Held for next month';
  static const String heldForNextMonthCaption = 'Reserved before month end';
  static const String carriedOver = 'Carried over from last month';
  static const String carriedOverCaption = 'Incoming month-end money';
  static const String released = 'Released at month end';
  static const String releasedCaption = 'Freed at month end';

  static const String whatYouKept = 'What you kept';
  static const String whatYouKeptCaption = 'After all adjustments';
  static const String overrideNote = 'Salary set for this month only';
  static const String formulaPrefix = 'Formula: ';
}
