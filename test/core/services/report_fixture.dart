import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/models/currency_code.dart';

FinancialReport reportFixture(
    {int count = 1,
    String title = 'Coffee',
    String? notes = 'PRIVATE NOTE',
    bool canExport = true}) {
  const owner = ReportOwner.personal(1);
  final request = ReportRequest(
      scope: ReportScope.personal,
      personalProfileId: 1,
      owners: [owner],
      firstMonth: '2026-10',
      lastMonth: '2026-10',
      currency: CurrencyCode.huf);
  return FinancialReport(
      request: request,
      generatedAt: DateTime.utc(2026, 10, 26, 12, 34),
      actorId: 1,
      statements: [
        ReportStatement(
            owner: owner,
            context: 'Personal',
            month: '2026-10',
            amounts: {
              'income': 100000,
              'paid': 1000 * count,
              'refunds': 0,
              'net': 1000 * count,
              'planned': 0,
              'savingsAdded': 0,
              'savingsRemoved': 0,
              'vaultCredit': 0,
              'bank': 100000 - 1000 * count
            },
            rateBasis: 'Same currency')
      ],
      transactions: List.generate(
          count,
          (i) => ReportTransaction(
              owner: owner,
              context: 'Personal',
              month: '2026-10',
              kind: 'Expense',
              name: '$title $i',
              date: DateTime(2026, 10, 26),
              recordedAt: DateTime.utc(2026, 10, 26, 12),
              amount: 1000,
              currency: 'HUF',
              converted: 1000,
              rateBasis: 'Same currency',
              merchant: 'Café Budapest',
              category: 'Food',
              payment: 'card',
              status: 'paid',
              notes: notes,
              effect: 1)),
      profiles: [],
      balances: [],
      issues: [],
      warnings: [],
      canExport: canExport,
      previousNet: 500);
}
