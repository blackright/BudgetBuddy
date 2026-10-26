import 'dart:async';

import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/providers/database_integrity_provider.dart';
import 'package:budget_buddy/core/routing/router_providers.dart';
import 'package:budget_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('failed scan blocks app and Retry runs a fresh safety check',
      (tester) async {
    var scans = 0;
    var routerReads = 0;
    final retry = Completer<List<MoneyIntegrityIssue>>();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        moneyIntegrityIssuesProvider.overrideWith((ref) async {
          scans++;
          if (scans == 1) throw StateError('private database details');
          return retry.future;
        }),
        routerProvider.overrideWith((ref) {
          routerReads++;
          throw StateError('router must remain inaccessible');
        }),
      ],
      child: const MyApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Unable to check saved data'), findsOneWidget);
    expect(find.textContaining('private database details'), findsNothing);
    expect(routerReads, 0);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(scans, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(routerReads, 0);

    retry.completeError(StateError('still unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to check saved data'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(routerReads, 0);
    expect(tester.takeException(), isNull);
  });
}
