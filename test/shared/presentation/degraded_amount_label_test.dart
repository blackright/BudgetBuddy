import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/shared/presentation/widgets/degraded_amount_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// FR-014: a degraded conversion must surface an explicit unavailable marker
/// and show the original amount — never a fabricated converted value.
void main() {
  const original = Money(100000, CurrencyCode.huf);

  ConversionResult converted({required Money amount}) => ConversionResult(
        amount: amount,
        rate: 0.0028,
        source: RateSource.bundled,
        asOf: DateTime.utc(2026, 1, 1),
        isStale: false,
        isDegraded: false,
      );

  const degraded = ConversionResult(
    amount: original,
    rate: null,
    source: null,
    asOf: null,
    isStale: false,
    isDegraded: true,
  );

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('shows the converted amount beside the original (FR-002)',
      (tester) async {
    await pump(
      tester,
      const DegradedAmountLabel(
        original: original,
        result: ConversionResult(
          amount: Money(1000, CurrencyCode.usd),
          rate: 0.01,
          source: RateSource.bundled,
          asOf: null,
          isStale: false,
          isDegraded: false,
        ),
      ),
    );

    expect(find.text(r'$ 10.00 · Ft 100,000'), findsOneWidget);
  });

  testWidgets('collapses to the converted amount in the same currency',
      (tester) async {
    await pump(
      tester,
      DegradedAmountLabel(
        original: const Money(2000, CurrencyCode.usd),
        result: converted(amount: const Money(2000, CurrencyCode.usd)),
      ),
    );

    expect(find.text(r'$ 20.00'), findsOneWidget);
  });

  testWidgets('a degraded result shows the original and an unavailable label',
      (tester) async {
    await pump(
      tester,
      const DegradedAmountLabel(original: original, result: degraded),
    );

    expect(find.text('Ft 100,000'), findsOneWidget);
    expect(find.text('Rate unavailable'), findsOneWidget);
  });

  testWidgets('a degraded result never renders a converted figure',
      (tester) async {
    await pump(
      tester,
      const DegradedAmountLabel(original: original, result: degraded),
    );

    // The would-be converted value must not appear anywhere.
    expect(find.textContaining(r'$ 10.00'), findsNothing);
  });

  testWidgets('a null result is treated as degraded', (tester) async {
    await pump(tester, const DegradedAmountLabel(original: original));

    expect(find.text('Ft 100,000'), findsOneWidget);
    expect(find.text('Rate unavailable'), findsOneWidget);
  });
}
