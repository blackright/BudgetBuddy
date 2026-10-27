import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/shared/presentation/branding/branded_startup.dart';
import 'package:budget_buddy/shared/presentation/branding/brand_artwork.dart';

class _MissingAssets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('missing decoration');
}

void main() {
  testWidgets('already-ready startup has no delay or later decorative replay',
      (tester) async {
    final session = StartupBrandSession();
    Widget app(bool ready) => MaterialApp(
        home: BrandedStartup(
            session: session,
            ready: ready,
            child: const Text('Ready destination')));
    await tester.pumpWidget(app(true));
    expect(find.text('Ready destination'), findsOneWidget);
    await tester.pumpWidget(app(false));
    expect(tester.widget<BrandArtwork>(find.byType(BrandArtwork)).progress, 1);
  });

  testWidgets(
      'pending sequence completes at 1200ms; ready interrupts immediately',
      (tester) async {
    final session = StartupBrandSession();
    Widget app(bool ready) => MaterialApp(
        home: BrandedStartup(
            session: session,
            ready: ready,
            child: const Text('Guarded destination')));
    await tester.pumpWidget(app(false));
    expect(find.text('Checking saved data...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Guarded destination'), findsNothing);
    await tester.pumpWidget(app(true));
    expect(find.text('Guarded destination'), findsOneWidget);
    expect(find.text('Checking saved data...'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'pending animation stops; resume/remount never replays and disposal is safe',
      (tester) async {
    final session = StartupBrandSession();
    Widget app() => MaterialApp(
        home: BrandedStartup(
            session: session, ready: false, child: const SizedBox()));
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(tester.widget<BrandArtwork>(find.byType(BrandArtwork)).progress, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.widget<BrandArtwork>(find.byType(BrandArtwork)).progress, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    expect(tester.widget<BrandArtwork>(find.byType(BrandArtwork)).progress, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'reduced motion and errors are static; failure retry remains reachable',
      (tester) async {
    var retries = 0;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: BrandedStartup(
                session: StartupBrandSession(),
                ready: false,
                onRetry: () => retries++,
                child: const SizedBox()))));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Unable to check saved data'), findsOneWidget);
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });
  testWidgets('missing decorative images retain usable static identity',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: DefaultAssetBundle(
            bundle: _MissingAssets(),
            child: BrandedStartup(
                session: StartupBrandSession(),
                ready: false,
                child: const SizedBox()))));
    await tester.pumpAndSettle();
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);
    expect(find.text('Budget together. Grow together.'), findsOneWidget);
    expect(tester.widget<BrandArtwork>(find.byType(BrandArtwork)).progress, 1);
    expect(tester.takeException(), isNull);
  });
}
