import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/services/allocation_service.dart';
import 'package:budget_buddy/core/services/transfer_service.dart';
import 'package:budget_buddy/core/services/borrowing_service.dart';
import 'package:budget_buddy/core/services/income_aggregation_service.dart';

void main() {
  for (final currency in CurrencyCode.values) {
    test(
        '${currency.name}: allocation transfer conserves every minor unit and borrowing never raises allocation',
        () {
      final source = BudgetProfile()
        ..id = 1
        ..allocation = 100001;
      final destination = BudgetProfile()
        ..id = 2
        ..allocation = 200002;
      const transfers = TransferService();
      for (final amount in [1, 2345, 50000]) {
        final total = source.allocation + destination.allocation;
        expect(transfers.apply(source, destination, amount), isTrue);
        expect(source.allocation + destination.allocation, total);
      }
      final sourceBefore = source.allocation,
          destinationBefore = destination.allocation;
      expect(transfers.apply(source, destination, sourceBefore + 1), isFalse);
      expect((source.allocation, destination.allocation),
          (sourceBefore, destinationBefore));
      final state = const BorrowingService().stateFor(
          profile: source, spent: sourceBefore + 10001, availableReserve: 3333);
      expect(state.borrowed, 3333);
      expect(state.deficit, 6668);
      expect(source.allocation, sourceBefore);
      final exact =
          Money(2345, currency) + Money(1, currency) - Money(1, currency);
      expect(exact.minorUnits, 2345);
    });
  }
  test('budget warning colours change at the specified percentage boundaries',
      () {
    for (final pair in [
      (79, BudgetStatus.green),
      (80, BudgetStatus.yellow),
      (99, BudgetStatus.yellow),
      (100, BudgetStatus.orange),
      (101, BudgetStatus.red)
    ]) {
      expect(
          const BorrowingService()
              .state(allocation: 100, spent: pair.$1, availableReserve: 100)
              .status,
          pair.$2);
    }
  });
  test(
      'allocation restrictions preserve reserve capacity and never fund Direct profiles',
      () {
    const service = AllocationService();
    final profile = BudgetProfile()..allocation = 100;
    expect(service.canAllocateToDirect(DirectExpenseProfile()), isFalse);
    expect(service.apply(profile: profile, amount: 101, availableReserve: 100),
        isFalse);
    expect(profile.allocation, 100);
    expect(service.apply(profile: profile, amount: 25, availableReserve: 100),
        isTrue);
    expect(profile.allocation, 125);
    expect(service.release(profile: profile, amount: 126), isFalse);
    expect(profile.allocation, 125);
    expect(service.release(profile: profile, amount: 25), isTrue);
    expect(profile.allocation, 100);
  });
  test(
      'income frequency and inclusive active-month boundaries follow approved rules',
      () {
    const service = IncomeAggregationService();
    IncomeSource source(IncomeFrequency frequency) => IncomeSource()
      ..name = 'Income'
      ..amount = 100
      ..currency = 'HUF'
      ..frequency = frequency
      ..startDate = DateTime(2026, 10, 15)
      ..endDate = DateTime(2027, 10, 15)
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    for (final frequency in IncomeFrequency.values) {
      final row = source(frequency);
      expect(service.monthlyTotal([row], '2026-09', currency: CurrencyCode.huf),
          0);
      expect(service.monthlyTotal([row], '2027-11', currency: CurrencyCode.huf),
          0);
      expect(service.monthlyTotal([row], '2026-10', currency: CurrencyCode.huf),
          frequency == IncomeFrequency.weekly ? 400 : 100);
    }
    expect(
        service.monthlyTotal([source(IncomeFrequency.quarterly)], '2027-01',
            currency: CurrencyCode.huf),
        100);
    expect(
        service.monthlyTotal([source(IncomeFrequency.quarterly)], '2026-11',
            currency: CurrencyCode.huf),
        0);
    expect(
        service.monthlyTotal([source(IncomeFrequency.yearly)], '2027-10',
            currency: CurrencyCode.huf),
        100);
    expect(
        service.monthlyTotal([source(IncomeFrequency.oneTime)], '2027-10',
            currency: CurrencyCode.huf),
        0);
  });
}
