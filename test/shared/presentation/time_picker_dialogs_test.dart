import 'package:budget_buddy/shared/presentation/time_picker_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the fix for `BoxConstraints has non-normalized height constraints`
/// thrown by the Material time picker.
///
/// HONEST SCOPE: the crashing number in the device log (`216.0<=h<=201.6`) is
/// reproduced here by arithmetic rather than guesswork. Flutter sizes the
/// input-mode dialog at `_kTimePickerInputSize.height * textScale` (252) and
/// then asks the same box for `minHeight: _kTimePickerInputMinimumHeight`
/// (216). At scale 0.8 that is `252 * 0.8 = 201.6 < 216`, which is exactly the
/// reported value, and scale 0.85 (Android's *Smallest* font setting) lands in
/// the same window. The first test asserts that raw `showTimePicker` really
/// does throw at that scale, so the tests after it are known to be guarding a
/// live scenario rather than one that no longer reproduces.
void main() {
  /// A phone-sized surface reporting the given platform font scale, the way a
  /// device with that setting would. `MaterialApp` rebuilds its own
  /// `MediaQuery` from the view, so the scale has to enter at the view to reach
  /// the dialog's route - which is exactly the situation the fix covers.
  void useSurfaceAtTextScale(WidgetTester tester, double scale) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.reset);
  }

  /// A button that opens the picker, so the tap goes through the real route
  /// transition rather than a bare `pumpWidget`.
  Widget openWith(Future<TimeOfDay?> Function(BuildContext) open) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  /// The text scale the dialog's own subtree receives.
  double scaleSeenByDialog(WidgetTester tester) {
    final BuildContext inDialog = tester.element(
      find
          .descendant(
            of: find.byType(TimePickerDialog),
            matching: find.byType(Text),
          )
          .first,
    );
    return MediaQuery.textScalerOf(inDialog).scale(10) / 10;
  }

  group('Material time picker vs. small text scales', () {
    testWidgets('raw showTimePicker throws in input mode at scale 0.8',
        (tester) async {
      // The control case: if this ever stops throwing, the tests below are
      // guarding a scenario that no longer exists.
      useSurfaceAtTextScale(tester, 0.8);

      await tester.pumpWidget(
        openWith(
          (context) => showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 9, minute: 30),
            initialEntryMode: TimePickerEntryMode.input,
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isA<FlutterError>().having(
          (FlutterError e) => e.message,
          'message',
          contains('non-normalized height constraints'),
        ),
      );
    });

    for (final scale in <double>[0.8, 0.85]) {
      testWidgets('showSafeTimePicker opens input mode at scale $scale',
          (tester) async {
        useSurfaceAtTextScale(tester, scale);

        await tester.pumpWidget(
          openWith(
            (context) => showSafeTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 30),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // The scale was raised to the documented floor, not left alone.
        expect(scaleSeenByDialog(tester), 0.9);

        // Not merely "no throw": the dialog is really on screen and its
        // animated box got constraints the framework would accept.
        expect(find.byType(TimePickerDialog), findsOneWidget);
        final RenderBox box = tester.renderObject<RenderBox>(
          find
              .descendant(
                of: find.byType(TimePickerDialog),
                matching: find.byType(AnimatedContainer),
              )
              .last,
        );
        expect(
          box.constraints.minHeight,
          lessThanOrEqualTo(box.constraints.maxHeight),
          reason: 'the picker box must stay normalized',
        );

        // Still usable: switching to keyboard entry mode must not throw.
        await tester.tap(find.byIcon(Icons.keyboard_outlined));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(TextField), findsWidgets);
      });
    }

    testWidgets('showSafeTimePicker leaves normal and large scales alone',
        (tester) async {
      for (final scale in <double>[1.0, 2.0]) {
        useSurfaceAtTextScale(tester, scale);

        await tester.pumpWidget(
          openWith(
            (context) => showSafeTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 30),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // Unclamped, so a large-scale user keeps the framework's own 1.1
        // growth cap rather than being pinned by an accessibility floor.
        expect(scaleSeenByDialog(tester), scale);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      }
    });
  });
}