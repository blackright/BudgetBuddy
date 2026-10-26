import 'currency_code.dart';
import '../services/free_funds.dart';

enum ReportScope { personal, financialProfile, space, consolidated }

class ReportOwner {
  const ReportOwner.personal(this.id) : shared = false;
  const ReportOwner.space(this.id) : shared = true;
  final int id;
  final bool shared;
  String get key => '${shared ? 's' : 'p'}:$id';
  @override
  bool operator ==(Object other) => other is ReportOwner && other.key == key;
  @override
  int get hashCode => key.hashCode;
}

class ReportRequest {
  ReportRequest(
      {required this.scope,
      required this.personalProfileId,
      required Iterable<ReportOwner> owners,
      required this.firstMonth,
      required this.lastMonth,
      required this.currency,
      this.financialProfile = 'main'})
      : owners = List.unmodifiable(owners) {
    final months = reportMonths(firstMonth, lastMonth);
    if (months.length > 1200 ||
        this.owners.isEmpty ||
        this.owners.toSet().length != this.owners.length) {
      throw ArgumentError('Choose distinct contexts and up to 100 years.');
    }
    if (scope != ReportScope.consolidated && this.owners.length != 1) {
      throw ArgumentError('This report uses one context.');
    }
    if (scope == ReportScope.personal &&
        (this.owners.single.shared ||
            this.owners.single.id != personalProfileId)) {
      throw ArgumentError('Choose the active personal profile.');
    }
    if (scope == ReportScope.space && !this.owners.single.shared) {
      throw ArgumentError('Choose a shared space.');
    }
    if (scope == ReportScope.consolidated &&
        !this.owners.contains(ReportOwner.personal(personalProfileId))) {
      throw ArgumentError('Consolidated includes the active personal profile.');
    }
    if (this.owners.any((o) => !o.shared && o.id != personalProfileId)) {
      throw ArgumentError('Other personal profiles are outside this scope.');
    }
  }
  final ReportScope scope;
  final int personalProfileId;
  final List<ReportOwner> owners;
  final String firstMonth, lastMonth, financialProfile;
  final CurrencyCode currency;
  List<String> get months => reportMonths(firstMonth, lastMonth);
  String get previousFirst => shiftReportMonth(firstMonth, -months.length);
  String get previousLast => shiftReportMonth(firstMonth, -1);
  String get label => switch (scope) {
        ReportScope.personal => 'Personal overview',
        ReportScope.financialProfile => 'Financial profile',
        ReportScope.space => 'Space report',
        ReportScope.consolidated => 'Consolidated report'
      };
  bool includes(String month) =>
      month.compareTo(firstMonth) >= 0 && month.compareTo(lastMonth) <= 0;
}

String reportMonth(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
String shiftReportMonth(String month, int delta) {
  if (!RegExp(r'^[0-9]{4}-(0[1-9]|1[0-2])$').hasMatch(month)) {
    throw ArgumentError('Use YYYY-MM.');
  }
  final date = DateTime(
      int.parse(month.substring(0, 4)), int.parse(month.substring(5)) + delta);
  if (date.year < 1 || date.year > 9999) {
    throw ArgumentError('Month outside supported calendar.');
  }
  return reportMonth(date);
}

List<String> reportMonths(String first, String last) {
  shiftReportMonth(first, 0);
  shiftReportMonth(last, 0);
  if (first.compareTo(last) > 0) {
    throw ArgumentError('The last month must follow the first.');
  }
  final months = <String>[];
  var month = first;
  while (true) {
    months.add(month);
    if (month == last) break;
    if (months.length > 1200) throw ArgumentError('Choose up to 100 years.');
    month = shiftReportMonth(month, 1);
  }
  return List.unmodifiable(months);
}

const reportMetricLabels = <String, String>{
  'rounding': 'Currency conversion rounding (display only)',
  'income': 'Income',
  'allocated': 'Allocated',
  'paid': 'Paid spending',
  'refunds': 'Recorded refunds',
  'legacyReturns': 'Legacy fully returned adjustment',
  'net': 'Net paid spending',
  'planned': 'Planned',
  'unused': 'Unused allocations',
  'carryIn': 'Carry received',
  'released': 'Month-End released',
  'carryProtection': 'Carry protection',
  'vaultCredit': 'Vault transfers into monthly funds',
  'reserve': 'Available reserve before borrowing',
  'borrowed': 'Budget borrowing',
  'deficit': 'Uncovered deficit',
  'free': 'Free to spend',
  'bank': 'Bank availability',
  'opening': 'Confirmed opening funds',
  'savingsAdded': 'Savings added to vault',
  'savingsRemoved': 'Savings removed from vault',
};
const reportFlowMetrics = {
  'income',
  'paid',
  'refunds',
  'legacyReturns',
  'net',
  'planned',
  'savingsAdded',
  'savingsRemoved',
  'vaultCredit'
};

class ReportTransaction {
  const ReportTransaction(
      {required this.owner,
      required this.context,
      required this.month,
      required this.kind,
      required this.name,
      required this.date,
      required this.amount,
      required this.currency,
      required this.converted,
      required this.rateBasis,
      this.profile = 'Main',
      this.profileKey = 'main',
      this.category = 'Not recorded',
      this.merchant = 'Not recorded',
      this.payment = 'Not recorded',
      this.status = '',
      this.evidence = 'Not recorded',
      this.recordedAt,
      this.notes,
      this.paidAt,
      this.effect = 0});
  final String profileKey;
  final ReportOwner owner;
  final String context,
      month,
      kind,
      name,
      currency,
      rateBasis,
      profile,
      category,
      merchant,
      payment,
      status,
      evidence;
  final int amount;
  final int? converted;

  /// Spending effect: +paid, -refund, 0 planned/allocations/vault movements.
  final int effect;
  final DateTime date;
  final DateTime? recordedAt, paidAt;
  final String? notes;
}

class ReportStatement {
  ReportStatement(
      {required this.owner,
      required this.context,
      required this.month,
      required Map<String, int?> amounts,
      required this.rateBasis,
      Iterable<String> issues = const []})
      : amounts = Map.unmodifiable(amounts),
        issues = List.unmodifiable(issues);
  final ReportOwner owner;
  final String context, month, rateBasis;
  final Map<String, int?> amounts;
  final List<String> issues;
  bool get complete => issues.isEmpty;
}

class ReportBreakdown {
  const ReportBreakdown(
      {required this.context,
      required this.month,
      required this.name,
      required this.type,
      required this.paid,
      required this.returned,
      required this.net,
      required this.planned,
      this.allocation,
      this.borrowed,
      this.deficit});
  final String context, month, name, type;
  final int? paid, returned, net, planned, allocation, borrowed, deficit;
}

class ReportBalance {
  const ReportBalance(
      {required this.context,
      required this.label,
      required this.date,
      required this.currency,
      required this.amount,
      required this.converted});
  final String context, label, currency;
  final DateTime date;
  final int amount;
  final int? converted;
}

class FinancialReport {
  FinancialReport(
      {required this.request,
      required this.generatedAt,
      required this.actorId,
      required Iterable<ReportStatement> statements,
      required Iterable<ReportTransaction> transactions,
      required Iterable<ReportBreakdown> profiles,
      required Iterable<ReportBalance> balances,
      required Iterable<String> issues,
      required Iterable<String> warnings,
      required this.canExport,
      required this.previousNet})
      : statements = List.unmodifiable(statements),
        transactions = List.unmodifiable(transactions),
        profiles = List.unmodifiable(profiles),
        balances = List.unmodifiable(balances),
        issues = List.unmodifiable(issues),
        warnings = List.unmodifiable(warnings);
  final ReportRequest request;
  final DateTime generatedAt;
  final int actorId;
  final List<ReportStatement> statements;
  final List<ReportTransaction> transactions;
  final List<ReportBreakdown> profiles;
  final List<ReportBalance> balances;
  final List<String> issues, warnings;
  final bool canExport;
  final int? previousNet;
  bool get complete => issues.isEmpty && statements.every((s) => s.complete);
  int? flow(String key) {
    if (!complete || statements.isEmpty || !reportFlowMetrics.contains(key)) {
      return null;
    }
    final values = statements.map((s) => s.amounts[key]);
    if (values.any((v) => v == null)) return null;
    try {
      return sumFinancialMinor(values.cast<int>());
    } on FormatException {
      return null;
    }
  }

  Map<String, int> breakdown(String field) {
    if (!complete) return const {};
    final result = <String, int>{};
    for (final row in transactions.where((r) => r.effect != 0)) {
      if (row.converted == null) continue;
      final key = field == 'merchant' ? row.merchant : row.category;
      result[key] =
          sumFinancialMinor([result[key] ?? 0, row.converted! * row.effect]);
    }
    return Map.unmodifiable(result);
  }

  List<String> get insights {
    final result = <String>[];
    final net = flow('net');
    if (previousNet != null && net != null) {
      result.add(
          'Net paid spending is ${net > previousNet! ? 'higher than' : net < previousNet! ? 'lower than' : 'unchanged from'} the preceding ${request.months.length} month(s).');
    }
    final merchants = breakdown('merchant').entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (merchants.isNotEmpty) {
      result.add('Top merchant by net paid spending: ${merchants.first.key}.');
    }
    final categories = breakdown('category').entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (categories.isNotEmpty) {
      result.add('Top category by net paid spending: ${categories.first.key}.');
    }
    return List.unmodifiable(result);
  }

  void requireExportable() {
    if (!canExport) {
      throw StateError(
          'Every selected space must grant Owner or Editor export permission.');
    }
    if (!complete) {
      throw StateError(
          'Resolve the listed financial data issues before exporting.');
    }
  }
}
