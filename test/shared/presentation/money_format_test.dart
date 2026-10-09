import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/features/medical/presentation/medical_theme.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the money-unit contract in one place (T-R01, FR-018).
///
/// Two helpers must never be confused:
/// - `formatMinorUnits`/`moneyMinor` render a **minor-unit int** (every stored
///   amount field).
/// - `formatMajorUnits`/`moneyMajor` render a **major-unit double** (engine
///   aggregates only).
///
/// Passing a minor int to the major helper inflates it by the currency's minor
/// factor, so these tests pin both sides of that boundary.
void main() {
  group('formatMinorUnits renders minor units exactly', () {
    test('USD renders two decimals from whole cents', () {
      expect(formatMinorUnits(1000, CurrencyCode.usd), r'$ 10.00');
      expect(formatMinorUnits(1, CurrencyCode.usd), r'$ 0.01');
      expect(formatMinorUnits(100000, CurrencyCode.usd), r'$ 1,000.00');
    });

    test('HUF renders no decimals (fixes phantom cents, D10)', () {
      expect(formatMinorUnits(1000, CurrencyCode.huf), 'Ft 1,000');
      expect(formatMinorUnits(1, CurrencyCode.huf), 'Ft 1');
    });

    test('negative amounts keep the sign outside the symbol', () {
      expect(formatMinorUnits(-1000, CurrencyCode.usd), r'-$ 10.00');
    });

    test('a minor-unit int never inflates when rendered here', () {
      // The regression that started Phase 0: a stored minor int must read as
      // its true magnitude, not one hundred times larger.
      expect(
          formatMinorUnits(1000, CurrencyCode.usd), isNot(contains('100,000')));
      expect(formatMinorUnits(1000, CurrencyCode.usd),
          isNot(contains('1,000.00')));
    });
  });

  group('formatMajorUnits bridges a major double', () {
    test('USD rounds once to whole cents', () {
      expect(formatMajorUnits(10.0, CurrencyCode.usd), r'$ 10.00');
      expect(formatMajorUnits(10.005, CurrencyCode.usd), r'$ 10.01');
    });

    test('HUF drops the fractional part', () {
      expect(formatMajorUnits(1000.0, CurrencyCode.huf), 'Ft 1,000');
    });

    test('equals the minor formatter for the same true amount', () {
      expect(
        formatMajorUnits(10.0, CurrencyCode.usd),
        formatMinorUnits(1000, CurrencyCode.usd),
      );
    });
  });

  group('formatMoney goes through the minor path', () {
    test('a Money value renders its stored minor units', () {
      expect(formatMoney(const Money(1000, CurrencyCode.usd)), r'$ 10.00');
      expect(formatMoney(const Money(1000, CurrencyCode.huf)), 'Ft 1,000');
    });
  });

  group('MedicalTheme helpers delegate to the shared formatter', () {
    test('moneyMinor equals formatMinorUnits', () {
      expect(
        MedicalTheme.moneyMinor(CurrencyCode.usd, 1000),
        formatMinorUnits(1000, CurrencyCode.usd),
      );
    });

    test('moneyMajor equals formatMajorUnits', () {
      expect(
        MedicalTheme.moneyMajor(CurrencyCode.usd, 10.0),
        formatMajorUnits(10.0, CurrencyCode.usd),
      );
    });

    test('the two helpers deliberately differ by the minor factor', () {
      // Same numeric literal, different unit: 1000 minor is 10.00 major.
      expect(
        MedicalTheme.moneyMinor(CurrencyCode.usd, 1000),
        isNot(MedicalTheme.moneyMajor(CurrencyCode.usd, 1000)),
      );
    });
  });

  group('formatMoneyWithOriginal', () {
    test('shows the original beside a converted amount (FR-002)', () {
      expect(
        formatMoneyWithOriginal(
          converted: const Money(1000, CurrencyCode.usd),
          original: const Money(100000, CurrencyCode.huf),
        ),
        r'$ 10.00 · Ft 100,000',
      );
    });

    test('collapses when both sides share a currency', () {
      expect(
        formatMoneyWithOriginal(
          converted: const Money(1000, CurrencyCode.usd),
          original: const Money(2000, CurrencyCode.usd),
        ),
        r'$ 10.00',
      );
    });
  });
}
