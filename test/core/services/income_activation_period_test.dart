import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/services/income_activation_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IncomeSource source(
    IncomeFrequency frequency, {
    DateTime? start,
    DateTime? end,
  }) =>
      IncomeSource()
        ..frequency = frequency
        ..startDate = start ?? DateTime.utc(2026, 2, 15)
        ..endDate = end;

  test('monthly and weekly periods use the calendar month', () {
    final monthly = source(IncomeFrequency.monthly);
    final weekly = source(IncomeFrequency.weekly);
    final date = DateTime.utc(2026, 11, 15);

    expect(periodKeyFor(monthly, date), '2026-11');
    expect(periodKeyFor(weekly, date), '2026-11');
    expect(nextPeriodKey(monthly, '2026-11'), '2026-12');
    expect(nextPeriodKey(weekly, '2026-12'), '2027-01');
  });

  test('quarterly periods use the quarter start and advance by three months',
      () {
    final quarterly = source(IncomeFrequency.quarterly);

    expect(periodKeyFor(quarterly, DateTime.utc(2026, 11, 15)), '2026-10');
    expect(periodKeyFor(quarterly, DateTime.utc(2026, 2, 15)), '2026-01');
    expect(nextPeriodKey(quarterly, '2026-10'), '2027-01');
    expect(nextPeriodKey(quarterly, '2026-12'), '2027-03');
  });

  test('yearly periods use January and advance by twelve months', () {
    final yearly = source(IncomeFrequency.yearly);

    expect(periodKeyFor(yearly, DateTime.utc(2026, 11, 15)), '2026-01');
    expect(nextPeriodKey(yearly, '2026-01'), '2027-01');
  });

  test('one-time income uses its single period and has no next period', () {
    final oneTime = source(
      IncomeFrequency.oneTime,
      start: DateTime.utc(2026, 11, 5),
    );

    expect(periodKeyFor(oneTime, DateTime.utc(2027, 5, 1)), '2026-11');
    expect(nextPeriodKey(oneTime, '2026-11'), isNull);
  });

  test('period activity respects start, end and frequency boundaries', () {
    final monthly = source(
      IncomeFrequency.monthly,
      start: DateTime.utc(2026, 2, 15),
      end: DateTime.utc(2026, 4, 10),
    );
    expect(isPeriodActive(monthly, '2026-03'), isTrue);
    expect(isPeriodActive(monthly, '2026-01'), isFalse);
    expect(isPeriodActive(monthly, '2026-05'), isFalse);

    final quarterly = source(
      IncomeFrequency.quarterly,
      start: DateTime.utc(2026, 2, 15),
    );
    expect(isPeriodActive(quarterly, '2026-01'), isTrue);
    expect(isPeriodActive(quarterly, '2025-10'), isFalse);
    expect(isPeriodActive(quarterly, '2026-04'), isTrue);

    final oneTime = source(
      IncomeFrequency.oneTime,
      start: DateTime.utc(2026, 11, 5),
    );
    expect(isPeriodActive(oneTime, '2026-11'), isTrue);
    expect(isPeriodActive(oneTime, '2026-12'), isFalse);
  });

  test('period end keys describe the inclusive period boundary', () {
    expect(periodEndKey('2026-11', IncomeFrequency.monthly), '2026-11');
    expect(periodEndKey('2026-10', IncomeFrequency.quarterly), '2026-12');
    expect(periodEndKey('2026-01', IncomeFrequency.yearly), '2026-12');
    expect(periodEndKey('2026-11', IncomeFrequency.oneTime), '2026-11');
  });

  test('malformed periods fail instead of guessing', () {
    final monthly = source(IncomeFrequency.monthly);
    expect(() => nextPeriodKey(monthly, '2026-13'), throwsFormatException);
    expect(() => isPeriodActive(monthly, 'November'), throwsFormatException);
    expect(() => periodEndKey('2026-00', IncomeFrequency.monthly),
        throwsFormatException);
  });
}
