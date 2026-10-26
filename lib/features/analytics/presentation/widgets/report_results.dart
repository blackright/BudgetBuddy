import 'package:flutter/material.dart';
import '../../../../core/models/financial_report.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/services/report_format.dart';
import '../../../../core/services/free_funds.dart';

class ReportResults extends StatefulWidget {
  const ReportResults({super.key, required this.report});
  final FinancialReport report;
  @override
  State<ReportResults> createState() => _ReportResultsState();
}

class _ReportResultsState extends State<ReportResults> {
  String? open, monthOpen;
  int page = 0;
  FinancialReport get report => widget.report;
  @override
  void didUpdateWidget(covariant ReportResults old) {
    super.didUpdateWidget(old);
    if (old.report != report) {
      page = 0;
      open = null;
      monthOpen = null;
    }
  }

  Widget section(String id, String label, IconData icon, int count,
          Widget Function() body) =>
      Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ListTile(
                leading: Icon(icon),
                title: Text(label),
                subtitle: Text(
                    '$count ${id == 'transactions' ? 'entries' : 'items'}'),
                trailing:
                    Icon(open == id ? Icons.expand_less : Icons.expand_more),
                onTap: () => setState(() => open = open == id ? null : id)),
            if (open == id)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: body())
          ]));
  Widget measure(String name, int? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 3,
          children: [
            Text(name),
            SelectableText(reportMoney(value, report.request.currency),
                style: const TextStyle(fontWeight: FontWeight.w600))
          ]));
  Widget unavailable() => const Text(
      'Financial data needs review. Details with incomplete totals are not presented as a complete breakdown.');
  @override
  Widget build(BuildContext context) {
    final code = report.request.currency,
        colors = Theme.of(context).colorScheme;
    final pages = (report.transactions.length + 19) ~/ 20;
    if (page >= pages) page = pages == 0 ? 0 : pages - 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(report.request.label,
                style: Theme.of(context).textTheme.titleLarge),
            Text('Generated ${reportTime(report.generatedAt)}',
                style: Theme.of(context).textTheme.bodySmall),
            const Text(
                'Frozen recorded-data snapshot. Regenerate after corrections.')
          ])),
      if (!report.complete)
        Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(18)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Financial data needs review',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              for (final issue in report.issues.take(3)) Text(issue),
              if (report.issues.length > 3)
                TextButton(
                    onPressed: () => showDialog<void>(
                        context: context,
                        builder: (c) => AlertDialog(
                                title: const Text('Report data issues'),
                                content: SingleChildScrollView(
                                    child: Text(report.issues.join('\n\n'))),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(c),
                                      child: const Text('Close'))
                                ])),
                    child: const Text('View all issues')),
              const Text(
                  'Affected exports are disabled. No financial values were repaired or guessed.')
            ])),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 360 &&
            MediaQuery.textScalerOf(context).scale(1) < 1.4;
        final width =
            wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final key in [
            if (report.request.scope != ReportScope.financialProfile) 'income',
            'net',
            'refunds',
            'planned'
          ])
            SizedBox(
                width: width,
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: key == 'net'
                            ? colors.primaryContainer
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reportMetricLabels[key]!,
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 6),
                          SelectableText(reportMoney(report.flow(key), code),
                              style: Theme.of(context).textTheme.titleMedium)
                        ])))
        ]);
      }),
      const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
              'Period cards show activity only. Missing monthly records make period totals unavailable. Monthly balances below are never added across months.')),
      section(
          'statements',
          'Monthly statements',
          Icons.calendar_month,
          report.statements.length,
          () => Column(children: [
                for (final s in report.statements)
                  Card.outlined(
                      child: Column(children: [
                    ListTile(
                        title: Text(s.context),
                        subtitle: Text(s.month),
                        trailing: Icon(monthOpen == '${s.owner.key}:${s.month}'
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onTap: () => setState(() => monthOpen =
                            monthOpen == '${s.owner.key}:${s.month}'
                                ? null
                                : '${s.owner.key}:${s.month}')),
                    if (monthOpen == '${s.owner.key}:${s.month}')
                      Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (s.amounts.isEmpty)
                                  const Text(
                                      'No complete recorded monthly statement.'),
                                for (final a in s.amounts.entries)
                                  measure(reportMetricLabels[a.key] ?? a.key,
                                      a.value),
                                Text(s.rateBasis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                for (final issue in s.issues)
                                  Text(issue,
                                      style: TextStyle(color: colors.error))
                              ]))
                  ]))
              ])),
      section(
          'profiles',
          'Financial profile analysis',
          Icons.account_balance_wallet_outlined,
          report.profiles.length,
          () => !report.complete
              ? unavailable()
              : Column(children: [
                  for (final p in report.profiles)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('${p.type}: ${p.name}',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              Text('${p.context} · ${p.month}'),
                              if (p.allocation != null)
                                measure('Allocation', p.allocation),
                              measure('Net allocation usage', p.net),
                              if (p.borrowed != null)
                                measure('Borrowing against shared reserve',
                                    p.borrowed),
                              if (p.deficit != null)
                                measure('Deficit', p.deficit),
                              const Divider()
                            ])),
                  const Text(
                      'Individual profile borrowing uses a shared reserve. Do not add borrowing capacities together.')
                ])),
      section(
          'spaces',
          'Context and space analysis',
          Icons.groups_outlined,
          report.request.owners.length,
          () => !report.complete
              ? unavailable()
              : Column(children: [
                  for (final owner in report.request.owners)
                    Builder(builder: (context) {
                      final statements = report.statements
                          .where((s) => s.owner == owner)
                          .toList();
                      int? net;
                      try {
                        if (statements.every((s) => s.amounts['net'] != null)) {
                          net = sumFinancialMinor(
                              statements.map((s) => s.amounts['net']!));
                        }
                      } on FormatException {
                        net = null;
                      }
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    statements.firstOrNull?.context ??
                                        'Context unavailable',
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                                measure('Net paid activity', net),
                                if (owner.shared)
                                  const Text(
                                      'Full shared-space amounts, not your personal ownership share.')
                              ]));
                    })
                ])),
      for (final field in ['merchant', 'category'])
        section(
            field,
            field == 'merchant' ? 'Merchant analysis' : 'Category analysis',
            field == 'merchant'
                ? Icons.storefront_outlined
                : Icons.category_outlined,
            report.complete ? report.breakdown(field).length : 0,
            () => !report.complete
                ? unavailable()
                : Column(children: [
                    for (final e
                        in (report.breakdown(field).entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value))))
                      measure(e.key, e.value)
                  ])),
      section(
          'original',
          'Original-currency subtotals',
          Icons.currency_exchange,
          originalReportTotals(report).length,
          () => Column(children: [
                for (final e in originalReportTotals(report).entries)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key),
                            SelectableText(CurrencyCode.tryParse(
                                        e.key.split(' · ').first) ==
                                    null
                                ? 'Unsupported currency; subtotal unavailable'
                                : reportMoney(
                                    e.value,
                                    CurrencyCode.tryParse(
                                        e.key.split(' · ').first)!))
                          ]))
              ])),
      section(
          'savings',
          'Savings movements and balances',
          Icons.savings_outlined,
          report.balances.length,
          () =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                measure('Added during selected financial months',
                    report.flow('savingsAdded')),
                measure('Removed during selected financial months',
                    report.flow('savingsRemoved')),
                for (final b in report.balances) ...[
                  const Divider(),
                  Text('${b.context}: ${b.label}'),
                  Text(reportTime(b.date)),
                  SelectableText(CurrencyCode.tryParse(b.currency) == null
                      ? 'Unsupported currency'
                      : reportMoney(
                          b.amount, CurrencyCode.tryParse(b.currency)!)),
                  measure('Report equivalent', b.converted)
                ],
                if (report.balances.isEmpty)
                  const Text(
                      'No endpoint balance is available for this period. Vault movement totals are not income or expenses.')
              ])),
      section(
          'insights',
          'Comparisons and insights',
          Icons.insights_outlined,
          report.insights.length,
          () => !report.complete
              ? unavailable()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      if (report.previousNet == null)
                        const Text(
                            'Previous-period comparison unavailable: some prior months have no complete recorded statement.')
                      else ...[
                        measure('Previous-period net paid', report.previousNet),
                        measure(
                            'Change',
                            report.flow('net') == null
                                ? null
                                : report.flow('net')! - report.previousNet!)
                      ],
                      for (final insight in report.insights)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(insight)),
                      const SizedBox(height: 12),
                      const Text(
                          'Calculated locally from recorded data. No predictions or AI guesses.')
                    ])),
      section('reconciliation', 'How totals add up', Icons.rule_outlined, 1,
          () => const SelectableText(reportReconciliation)),
      section(
          'quality',
          'Data quality and rate notes',
          Icons.fact_check_outlined,
          report.warnings.length,
          () => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (report.warnings.isEmpty)
                  const Text('No report data warnings.'),
                for (final w in report.warnings)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(w))
              ])),
      section(
          'transactions',
          'Transaction details',
          Icons.receipt_long_outlined,
          report.transactions.length,
          () =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (report.transactions.isEmpty)
                  const Text('No transaction entries in this selection.'),
                for (final r in report.transactions.skip(page * 20).take(20))
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          border: Border.all(color: colors.outlineVariant),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: Theme.of(context).textTheme.titleSmall),
                            Text('${r.kind} · ${reportStatus(r.status)}'),
                            Text('${r.context} · ${r.month} · ${r.profile}'),
                            Text(
                                '${r.merchant} · ${r.category} · ${reportPayment(r.payment)}'),
                            SelectableText(
                                'Original: ${CurrencyCode.tryParse(r.currency) == null ? 'Unsupported currency' : reportMoney(r.amount, CurrencyCode.tryParse(r.currency)!)}'),
                            SelectableText(
                                'Report: ${reportMoney(r.converted, code)}'),
                            Text('Expense/event date: ${reportDate(r.date)}'),
                            Text('Recorded: ${reportTime(r.recordedAt)}'),
                            if (r.paidAt != null)
                              Text('Paid: ${reportDate(r.paidAt!)}'),
                            Text('Evidence: ${r.evidence}')
                          ])),
                if (pages > 1)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(
                                onPressed: page > 0
                                    ? () => setState(() => page--)
                                    : null,
                                child: const Text('Previous')),
                            Text('Page ${page + 1} of $pages'),
                            TextButton(
                                onPressed: page + 1 < pages
                                    ? () => setState(() => page++)
                                    : null,
                                child: const Text('Next'))
                          ]))
              ])),
    ]);
  }
}
