import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/services/income_aggregation_service.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/financial_drafts.dart';

void main() {
  test('zero sources are real records; date errors never silently drop a row',
      () {
    const zero = OnboardingSourceDraft(
        sourceGuid: 'zero',
        name: 'Variable income',
        amountText: '0',
        currency: CurrencyCode.huf);
    final review = OnboardingFinance.review(financialDraft(sources: [zero]));
    expect(review.normalized.sources, hasLength(1));
    expect(review.incomeMinor, 0);
    for (final source in [
      OnboardingSourceDraft(
          sourceGuid: 'bad',
          name: 'Reversed',
          amountText: '10',
          currency: CurrencyCode.huf,
          startDate: DateTime(2026, 10, 2),
          endDate: DateTime(2026, 10, 1)),
      const OnboardingSourceDraft(
          sourceGuid: 'bad',
          name: 'One time',
          amountText: '10',
          currency: CurrencyCode.huf,
          frequency: IncomeFrequency.oneTime),
    ]) {
      expect(
          () =>
              OnboardingFinance.review(financialDraft(sources: [zero, source])),
          throwsA(isA<OnboardingFinanceException>().having(
              (e) => e.fields, 'date guidance', contains('source:bad:dates'))));
    }
  });
  test(
      'multiple individually valid amounts cannot overflow the combined engine envelope',
      () {
    expect(
        () => OnboardingFinance.review(financialDraft(sources: [
              for (final id in ['a', 'b'])
                OnboardingSourceDraft(
                    sourceGuid: id,
                    name: id,
                    amountText: '2,000,000,000,000,000',
                    currency: CurrencyCode.huf)
            ])),
        throwsA(isA<OnboardingFinanceException>()
            .having((e) => e.fields, 'income limit', contains('income'))));
    expect(
        () => OnboardingFinance.review(
            financialDraft(opening: '9,007,199,254,740,000')),
        throwsA(isA<OnboardingFinanceException>()
            .having((e) => e.fields, 'combined limit', contains('totals'))));
  });
  for (final currency in CurrencyCode.values) {
    test('${currency.name} exact review keeps opening and income separate', () {
      final r = OnboardingFinance.review(financialDraft(currency: currency));
      final factor = currency.minorUnitsPerMajor;
      expect(r.incomeMinor, 500000 * factor);
      expect(r.freeMinor, 500000 * factor);
      expect(r.bankMinor, 600000 * factor);
      expect(Money.fromMajor(r.openingMajor, currency).minorUnits,
          100000 * factor);
      expect(r.digest, hasLength(64));
    });
    test(
        '${currency.name} confirmed zero, unknown and no income do not invent sources',
        () {
      final known = OnboardingFinance.review(financialDraft(
          currency: currency,
          opening: '0',
          incomeChoice: OnboardingIncomeChoice.none));
      expect(known.bankMinor, 0);
      expect(known.incomeMinor, 0);
      expect(known.normalized.sources, isEmpty);
      final unknown = OnboardingFinance.review(financialDraft(
          currency: currency, openingChoice: OnboardingOpeningChoice.unknown));
      expect(unknown.bankMinor, isNull);
      expect(unknown.freeMinor, 500000 * currency.minorUnitsPerMajor);
    });
  }
  test('fractional grouped values are parsed without losing cents', () {
    final r = OnboardingFinance.review(financialDraft(
        currency: CurrencyCode.eur,
        opening: '1,234.56',
        sources: [
          const OnboardingSourceDraft(
              sourceGuid: 'a',
              name: 'Freelance',
              amountText: '12.34',
              currency: CurrencyCode.eur)
        ]));
    expect(r.bankMinor, 124690);
    expect(r.incomeMinor, 1234);
  });
  test(
      'recurrence and active-month contributions agree with the ordinary engine',
      () {
    for (final frequency in IncomeFrequency.values) {
      final source = OnboardingSourceDraft(
          sourceGuid: 'a',
          name: 'Source',
          amountText: '100',
          currency: CurrencyCode.huf,
          frequency: frequency,
          startDate: DateTime(2026, 7, 15));
      final r = OnboardingFinance.review(financialDraft(sources: [source]));
      final row = OnboardingFinance.sourceRecord(r.normalized.sources.single,
          profileId: 9, at: DateTime.utc(2026));
      expect(
          r.incomeMinor,
          const IncomeAggregationService()
              .monthlyTotal([row], '2026-10', currency: CurrencyCode.huf));
      expect(
          r.incomeMinor,
          frequency == IncomeFrequency.weekly
              ? 400
              : frequency == IncomeFrequency.monthly ||
                      frequency == IncomeFrequency.quarterly
                  ? 100
                  : 0);
    }
    final inactive = OnboardingFinance.review(financialDraft(sources: [
      OnboardingSourceDraft(
          sourceGuid: 'a',
          name: 'Future',
          amountText: '100',
          currency: CurrencyCode.huf,
          startDate: DateTime(2027, 1, 1))
    ]));
    expect(inactive.contributions.single.minor, 0);
    expect(inactive.contributions.single.explanation, isNotEmpty);
  });
  test(
      'invalid, unsafe and incomplete money is refused with field-specific guidance',
      () {
    for (final text in ['', '-1', 'NaN', '1.25', '9007199254740992']) {
      expect(
          () => OnboardingFinance.review(financialDraft(opening: text)),
          throwsA(isA<OnboardingFinanceException>()
              .having((e) => e.fields, 'fields', contains('opening'))));
    }
    for (final text in ['', '1.001', '9007199254740992']) {
      expect(
          () => OnboardingFinance.review(
                  financialDraft(currency: CurrencyCode.eur, sources: [
                OnboardingSourceDraft(
                    sourceGuid: 'a',
                    name: 'Income',
                    amountText: text,
                    currency: CurrencyCode.eur)
              ])),
          throwsA(isA<OnboardingFinanceException>()));
    }
    expect(
        () => OnboardingFinance.review(financialDraft(sources: [
              const OnboardingSourceDraft(
                  sourceGuid: 'a',
                  name: 'Weekly',
                  amountText: '9007199254740991',
                  currency: CurrencyCode.huf,
                  frequency: IncomeFrequency.weekly)
            ])),
        throwsA(isA<OnboardingFinanceException>()));
  });
  test('review digest binds names, source identities, month and money', () {
    final a = OnboardingFinance.review(financialDraft());
    final b = OnboardingFinance.review(financialDraft(opening: '100000'));
    expect(a.digest, b.digest,
        reason: 'Grouping is presentation, not changed money');
    expect(
        a.digest,
        isNot(
            OnboardingFinance.review(financialDraft(month: '2026-11')).digest));
    expect(
        a.digest,
        isNot(OnboardingFinance.review(financialDraft(opening: '100001'))
            .digest));
  });
}
