import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/analytics/domain/chart_filters.dart';
import 'package:budget_buddy/features/analytics/domain/chart_query.dart';
import 'package:budget_buddy/features/analytics/repositories/analytics_repository.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';

/// Builds a context-scoped snapshot the way the app does — through the real
/// [AnalyticsRepository] — but with no database behind it, so these tests stay
/// pure and fast.
AnalyticsSnapshot _snapshot({
  required List<Expense> expenses,
  List<Category> categories = const [],
  List<MedicalBill> medicalBills = const [],
  List<SharedMember> members = const [],
  List<Reimbursement> reimbursements = const [],
  ChartFilters filters = ChartFilters.none,
  ContextRef? context,
}) {
  final repository = AnalyticsRepository(RateTableRegistry());
  return repository.build(
    context: context ?? ContextRef.personal(profileId: 1, yearMonth: '2026-01'),
    mainCurrency: CurrencyCode.huf,
    filters: filters,
    expenses: expenses,
    reimbursements: reimbursements,
    medicalBills: medicalBills,
    month: null,
    members: members,
    categories: categories,
  );
}

Expense _expense({
  required int amount,
  required String categoryId,
  required ExpenseStatus status,
  DateTime? date,
  String currency = 'huf',
  int profileId = 1,
  int? sharedSpaceId,
}) =>
    Expense(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      yearMonth: '2026-01',
      title: categoryId,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      status: status,
      date: date ?? DateTime(2026, 1, 5),
      budgetId: 1,
    );

Category _category(String id, String name) =>
    Category(categoryId: id, name: name, emoji: '', colorValue: 0xFF9E9E9E);

MedicalBill _bill({
  required int billedAmount,
  double patientSharePercent = 20,
  MedicalPaymentMethod paymentMethod = MedicalPaymentMethod.insurerPaid,
  MedicalBillState state = MedicalBillState.paid,
}) =>
    MedicalBill()
      ..profileId = 1
      ..yearMonth = '2026-01'
      ..billedAmount = billedAmount
      ..patientSharePercent = patientSharePercent
      ..paymentMethod = paymentMethod
      ..state = state
      ..currency = 'huf';

SharedMember _member(int profileId, SharedMemberRole role) => SharedMember()
  ..sharedSpaceId = 7
  ..profileId = profileId
  ..role = role
  ..joinedAt = DateTime(2026, 1, 1);

Reimbursement _reimbursement({
  required int profileId,
  required int amount,
}) =>
    Reimbursement(
      profileId: profileId,
      sharedSpaceId: 7,
      originYearMonth: '2026-01',
      amount: amount,
      currency: 'huf',
      date: DateTime(2026, 1, 20),
    );

void main() {
  // A realistic month: every status appears at least once.
  final expenses = <Expense>[
    _expense(amount: 1000, categoryId: 'food', status: ExpenseStatus.paid),
    _expense(amount: 500, categoryId: 'food', status: ExpenseStatus.planned),
    _expense(amount: 2000, categoryId: 'transport', status: ExpenseStatus.paid),
    _expense(
      amount: 300,
      categoryId: 'shopping',
      status: ExpenseStatus.cancelled,
    ),
    _expense(
      amount: 700,
      categoryId: 'health',
      status: ExpenseStatus.reimbursed,
    ),
  ];

  final categories = <Category>[
    _category('food', 'Food'),
    _category('transport', 'Transport'),
    _category('shopping', 'Shopping'),
    _category('health', 'Health'),
  ];

  // Everything except the cancelled 300 → 4200.
  const expectedTotal = 4200;

  group('SC-001 — one source of truth', () {
    test('category total equals monthly-spending total', () {
      final snapshot = _snapshot(expenses: expenses, categories: categories);

      final spending = spendingSeries(snapshot);
      final category = categorySeries(snapshot);

      expect(spending.total, expectedTotal);
      expect(category.total, spending.total);
    });

    test('category slices add up to the total', () {
      final snapshot = _snapshot(expenses: expenses, categories: categories);

      final category = categorySeries(snapshot);
      final sum = category.slices
          .fold<int>(0, (total, slice) => total + slice.minorUnits);

      expect(sum, category.total);
      expect(category.total, expectedTotal);
    });
  });

  group('status separation', () {
    test('cancelled never appears in spending or category totals', () {
      final snapshot = _snapshot(expenses: expenses, categories: categories);

      final spending = spendingSeries(snapshot);
      final category = categorySeries(snapshot);

      // The cancelled 300 must be absent from both.
      expect(spending.total, expectedTotal);
      expect(spending.total, isNot(4500));
      expect(category.total, expectedTotal);
      // Its category only holds cancelled money, so it has no slice at all.
      expect(
        category.slices.map((slice) => slice.categoryId),
        isNot(contains('shopping')),
      );
    });

    test('planned, paid and cancelled are counted separately', () {
      final snapshot = _snapshot(expenses: expenses, categories: categories);

      final bars = plannedPaidSeries(snapshot).bars;
      final food = bars.firstWhere((bar) => bar.label == 'Food');
      final transport = bars.firstWhere((bar) => bar.label == 'Transport');

      expect(food.plannedMinorUnits, 500);
      expect(food.paidMinorUnits, 1000);

      expect(transport.plannedMinorUnits, 0);
      expect(transport.paidMinorUnits, 2000);

      // Cancelled money reaches neither bucket, and its category never appears.
      expect(bars.map((bar) => bar.label), isNot(contains('Shopping')));
    });
  });

  group('filters', () {
    test('restricting to one category narrows every series', () {
      final snapshot = _snapshot(
        expenses: expenses,
        categories: categories,
        filters: const ChartFilters(categoryIds: {'food'}),
      );

      final spending = spendingSeries(snapshot);
      final category = categorySeries(snapshot);
      final bars = plannedPaidSeries(snapshot).bars;

      expect(spending.total, 1500);
      expect(category.total, 1500);
      expect(category.slices.single.categoryId, 'food');
      expect(bars.single.label, 'Food');
    });
  });

  group('US4 — medical insurer/user split (SC-006)', () {
    test('splits each bill into its insurer and patient shares', () {
      final snapshot = _snapshot(
        expenses: const [],
        medicalBills: [
          _bill(billedAmount: 10000, patientSharePercent: 20),
        ],
      );

      final series = insuranceSeries(snapshot);

      expect(series.total, 10000);
      final insurer =
          series.slices.firstWhere((s) => s.categoryId == 'insurer');
      final patient =
          series.slices.firstWhere((s) => s.categoryId == 'patient');
      expect(insurer.minorUnits, 8000);
      expect(patient.minorUnits, 2000);
      expect(insurer.minorUnits + patient.minorUnits, series.total);
    });

    test('a planned bill is not counted — its money has not moved', () {
      final snapshot = _snapshot(
        expenses: const [],
        medicalBills: [
          _bill(billedAmount: 10000, state: MedicalBillState.planned),
        ],
      );

      expect(insuranceSeries(snapshot).isEmpty, isTrue);
    });

    test('no bills means an honest empty series', () {
      final snapshot = _snapshot(expenses: const []);
      expect(insuranceSeries(snapshot).isEmpty, isTrue);
    });
  });

  group('US4 — member contribution (FR-011)', () {
    test('groups shared rows by member, includes zero contributors, ordered',
        () {
      final snapshot = _snapshot(
        context: ContextRef.shared(spaceId: 7, yearMonth: '2026-01'),
        expenses: [
          _expense(
            amount: 1000,
            categoryId: 'food',
            status: ExpenseStatus.paid,
            profileId: 1,
            sharedSpaceId: 7,
          ),
          _expense(
            amount: 3000,
            categoryId: 'transport',
            status: ExpenseStatus.paid,
            profileId: 2,
            sharedSpaceId: 7,
          ),
        ],
        reimbursements: [_reimbursement(profileId: 1, amount: 500)],
        members: [
          _member(1, SharedMemberRole.owner),
          _member(2, SharedMemberRole.editor),
          _member(3, SharedMemberRole.viewer),
        ],
      );

      final series = contributionSeries(snapshot);

      // Every member appears, largest net first; the zero contributor is kept.
      expect(
        series.slices.map((s) => s.categoryId).toList(),
        ['member:2', 'member:1', 'member:3'],
      );
      expect(series.slices[0].minorUnits, 3000);
      expect(series.slices[1].minorUnits, 500); // 1000 spent - 500 returned
      expect(series.slices[2].minorUnits, 0);
      // The headline total equals the sum of the member slices (SC-001).
      expect(series.total, 3500);
      expect(
        series.slices.fold<int>(0, (sum, s) => sum + s.minorUnits),
        series.total,
      );
    });

    test('a shared space with no members is honestly empty', () {
      final snapshot = _snapshot(
        context: ContextRef.shared(spaceId: 7, yearMonth: '2026-01'),
        expenses: const [],
      );
      expect(contributionSeries(snapshot).isEmpty, isTrue);
    });
  });

  group('US4 — shared vs personal', () {
    test('combined total is the sum of its two slices', () {
      final shared = _snapshot(
        context: ContextRef.shared(spaceId: 7, yearMonth: '2026-01'),
        expenses: [
          _expense(
            amount: 2500,
            categoryId: 'transport',
            status: ExpenseStatus.paid,
            sharedSpaceId: 7,
          ),
        ],
      );
      final personal = _snapshot(
        expenses: [
          _expense(
              amount: 1000, categoryId: 'food', status: ExpenseStatus.paid),
        ],
      );

      final series = sharedVsPersonalSeries(shared, personal);

      expect(series.total, 3500);
      final personalSlice =
          series.slices.firstWhere((s) => s.categoryId == 'personal');
      final sharedSlice =
          series.slices.firstWhere((s) => s.categoryId == 'shared');
      expect(personalSlice.minorUnits, 1000);
      expect(sharedSlice.minorUnits, 2500);
      expect(personalSlice.minorUnits + sharedSlice.minorUnits, series.total);
    });
  });

  group('performance — one month of 1000+ records stays bounded (SC-008)', () {
    // 1000 rows inside a single month. Aggregation must keep the *point count*
    // bounded (one bucket per day, never one per record) so the chart stays
    // smooth no matter how many records are behind it (FR-015).
    final bigMonth = <Expense>[
      for (var i = 0; i < 1000; i++)
        _expense(
          amount: 100,
          categoryId: i.isEven ? 'food' : 'transport',
          status: ExpenseStatus.paid,
          date: DateTime(2026, 1, (i % 28) + 1),
        ),
    ];

    test('spending collapses 1000 records into at most one point per day', () {
      final snapshot = _snapshot(expenses: bigMonth, categories: categories);

      final spending = spendingSeries(snapshot);

      expect(spending.total, 100000);
      expect(spending.buckets.length, lessThanOrEqualTo(31));
      expect(spending.buckets.length, lessThan(bigMonth.length));
      // Every record is still counted — bounded points, complete total.
      final points =
          spending.buckets.fold<int>(0, (sum, b) => sum + b.pointCount);
      expect(points, bigMonth.length);
    });

    test('the category total still matches the spending total at scale', () {
      final snapshot = _snapshot(expenses: bigMonth, categories: categories);

      final spending = spendingSeries(snapshot);
      final category = categorySeries(snapshot);

      expect(category.total, spending.total);
      expect(category.slices.length, 2);
    });
  });
}
