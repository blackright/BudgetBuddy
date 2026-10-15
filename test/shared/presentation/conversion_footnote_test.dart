import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/shared/presentation/widgets/conversion_footnote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oracle for the conversion caption (T054).
///
/// The caption is the only place a month's conversion provenance reaches the
/// UI, so these tests pin both halves of that contract: it names the rate and
/// its source when a rate exists, and it never fabricates one when it cannot
/// (FR-014).
void main() {
  const usd = CurrencyCode.usd;
  const huf = CurrencyCode.huf;
  const eur = CurrencyCode.eur;
  const cad = CurrencyCode.cad;

  RateTable table(RateSource source, {bool stale = false}) {
    return RateTable.tryCreate(
      usdRates: const {usd: 1.0, eur: 0.86, huf: 345.0, cad: 1.36},
      asOf: DateTime(2026, 2, 1),
      fetchedAt: DateTime(2026, 2, 1),
      source: source,
      isStale: stale,
    )!;
  }

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('visibility', () {
    testWidgets('a single-currency screen renders nothing', (tester) async {
      await tester.pumpWidget(
        wrap(const ConversionFootnote(
          main: usd,
          display: usd,
          table: null,
        )),
      );

      expect(find.byKey(const Key('conversionFootnote')), findsNothing);
    });

    testWidgets('a converted screen renders the caption', (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.live),
        )),
      );

      expect(find.byKey(const Key('conversionFootnote')), findsOneWidget);
    });
  });

  group('the caption names the governing rate', () {
    testWidgets('shows how many main units one display unit buys',
        (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.live),
        )),
      );

      expect(find.textContaining('1 \$ = 345 Ft'), findsOneWidget);
      expect(find.textContaining('2026-02-01'), findsOneWidget);
    });

    testWidgets('reverse direction reads the other way', (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: usd,
          display: eur,
          table: table(RateSource.live),
        )),
      );

      // 1 EUR = 1 / 0.86 USD.
      expect(find.textContaining('1 € = 1.16 \$'), findsOneWidget);
    });
  });

  group('provenance label (contract currency-conversion §1)', () {
    testWidgets('live table is named a live rate', (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.live),
        )),
      );

      expect(find.textContaining('live rate'), findsOneWidget);
    });

    testWidgets('a sealed month names the close date', (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.historical),
        )),
      );

      expect(find.textContaining('sealed at month close'), findsOneWidget);
    });

    testWidgets('a reused table is named a last known rate', (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.lastKnown),
        )),
      );

      expect(find.textContaining('last known rate'), findsOneWidget);
    });

    testWidgets('a first-launch table is named an offline estimate',
        (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.bundled),
        )),
      );

      expect(find.textContaining('offline estimate'), findsOneWidget);
    });

    testWidgets('a stale live table flags it as stale', (tester) async {
      await tester.pumpWidget(
        wrap(ConversionFootnote(
          main: huf,
          display: usd,
          table: table(RateSource.live, stale: true),
        )),
      );

      expect(find.textContaining('stale'), findsOneWidget);
    });
  });

  group('degraded table (FR-014)', () {
    testWidgets('the marker is shown instead of an invented rate',
        (tester) async {
      await tester.pumpWidget(
        wrap(const ConversionFootnote(
          main: huf,
          display: usd,
          table: null,
        )),
      );

      expect(find.byKey(const Key('conversionFootnote')), findsOneWidget);
      expect(find.textContaining('Rate unavailable'), findsOneWidget);
      expect(find.textContaining('='), findsNothing);
    });
  });
}
