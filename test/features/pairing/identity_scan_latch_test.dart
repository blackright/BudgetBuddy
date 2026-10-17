import 'package:budget_buddy/features/pairing/presentation/show_identity_code_screen.dart';
import 'package:budget_buddy/features/pairing/presentation/widgets/scan_error_panel.dart';
import 'package:budget_buddy/features/pairing/providers/pairing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/pairing_harness.dart';

/// US7: the presenter's reply scan **latches** a refusal.
///
/// Regression for the playground bug where a wrong reply made the message
/// repeat forever: `MobileScanner` fires once per camera frame, so a refused
/// scan has to stop the camera and show the reason exactly once.
void main() {
  late PairingTestHarness alice;

  // Real Isar I/O must not run inside `testWidgets` (its FakeAsync zone never
  // completes file work), so the harness is built once, outside the tests.
  setUpAll(() async {
    alice = await PairingTestHarness.create(username: 'Alice');
  });

  tearDownAll(() async {
    await alice.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pairingServiceProvider.overrideWithValue(alice.service),
        ],
        child: const MaterialApp(home: ShowIdentityCodeScreen()),
      ),
    );
    await tester.pump();
  }

  /// Scans [raw] and rebuilds. Anything that touches Isar has to run outside
  /// the FakeAsync zone, hence [WidgetTester.runAsync].
  Future<void> scan(WidgetTester tester, String raw) async {
    final state = tester.state<ShowIdentityCodeScreenState>(
      find.byType(ShowIdentityCodeScreen),
    );
    await tester.runAsync(() => state.handleScanned(raw));
    await tester.pump();
  }

  testWidgets('a refused reply scan stops the camera and shows one message',
      (tester) async {
    await pumpScreen(tester);
    // The most common mistake: scanning an identity code where a reply was
    // expected.
    final identityCode = alice.service.createIdentityInvite().payload.encode();

    await scan(tester, identityCode);

    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);
    // The camera must be gone, so the same code cannot re-fire every frame.
    expect(find.byKey(const Key('identityReplyScanner')), findsNothing);
    expect(find.byKey(const Key('scanReplyButton')), findsNothing);
    expect(find.byKey(const Key('identityCodeQr')), findsOneWidget);
  });

  testWidgets('a repeated bad scan does not stack up a second message',
      (tester) async {
    await pumpScreen(tester);
    final identityCode = alice.service.createIdentityInvite().payload.encode();

    await scan(tester, identityCode);
    await scan(tester, identityCode);
    await scan(tester, 'not json at all');
    await scan(tester, identityCode);

    // Exactly one latched panel, not one per frame or attempt.
    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);
    expect(find.byKey(const Key('identityReplyScanner')), findsNothing);
  });

  testWidgets('a reply for someone else is refused and latched',
      (tester) async {
    await pumpScreen(tester);
    // A well-formed reply, but for a different invite token.
    final otherToken = alice.service.createIdentityInvite().token;
    final foreignReply = await scannerClaim(otherToken);

    await scan(tester, foreignReply.encode());

    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);
    expect(find.byKey(const Key('identityReplyScanner')), findsNothing);
    expect(find.textContaining('You added'), findsNothing);
  });

  testWidgets('a good reply scan clears the latched error and succeeds',
      (tester) async {
    await pumpScreen(tester);
    final state = tester.state<ShowIdentityCodeScreenState>(
      find.byType(ShowIdentityCodeScreen),
    );

    await scan(tester, 'not json at all');
    expect(find.byType(ScanErrorPanel), findsOneWidget);

    final reply = await scannerClaim(state.inviteToken!);
    await scan(tester, reply.encode());

    // The refusal is gone and the exchange completed.
    expect(find.byKey(const Key('scanErrorMessage')), findsNothing);
    expect(find.byType(ScanErrorPanel), findsNothing);
    expect(find.textContaining('You added Bob.'), findsOneWidget);
    expect(find.byKey(const Key('identityReplyScanner')), findsNothing);
  });

  testWidgets('the panel reports the reason and asks to scan again',
      (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScanErrorPanel(
            message: 'That code expired.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);
    expect(find.text('That code expired.'), findsOneWidget);
    expect(find.text('Scan again'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanAgainButton')));
    expect(retried, isTrue);
  });
}
