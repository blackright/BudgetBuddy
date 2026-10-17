import 'package:budget_buddy/features/pairing/presentation/widgets/scan_error_panel.dart';
import 'package:budget_buddy/features/pairing/providers/pairing_providers.dart';
import 'package:budget_buddy/features/spaces/presentation/scan_contact_into_space_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// US7 (T064): scanning a person into a space reuses the **latched** refusal
/// introduced for the People flow, so a wrong code cannot flood the screen.
void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The refusal path never unlocks the identity, so nothing Isar-backed
          // is touched here.
          signingPairingServiceProvider.overrideWith((ref) => null),
        ],
        child: const MaterialApp(
          home: ScanContactIntoSpaceScreen(spaceId: 1, spaceName: 'Home'),
        ),
      ),
    );
    await tester.pump();
  }

  ScanContactIntoSpaceScreenState stateOf(WidgetTester tester) =>
      tester.state<ScanContactIntoSpaceScreenState>(
        find.byType(ScanContactIntoSpaceScreen),
      );

  testWidgets('a wrong code latches, stops the camera and can be retried',
      (tester) async {
    await pumpScreen(tester);
    expect(find.byKey(const Key('addToSpaceScanner')), findsOneWidget);

    final state = stateOf(tester);
    await state.handleScanned('not json at all');
    await tester.pump();

    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);
    expect(find.byKey(const Key('addToSpaceScanner')), findsNothing);

    // Repeating the bad scan must not stack a second message.
    await state.handleScanned('still not json');
    await tester.pump();
    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);

    // Scan again brings the camera back.
    await tester.tap(find.byKey(const Key('scanAgainButton')));
    await tester.pump();
    expect(find.byType(ScanErrorPanel), findsNothing);
    expect(find.byKey(const Key('addToSpaceScanner')), findsOneWidget);
  });
}
