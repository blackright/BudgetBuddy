import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/shared/presentation/modals/app_confirm.dart';
import 'package:budget_buddy/shared/presentation/modals/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(
    ThemeData theme,
    Future<void> Function(BuildContext context, StateSetter setState) open,
  ) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => Center(
            child: TextButton(
              key: const Key('openDialog'),
              onPressed: () => open(context, setState),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  test('overlay themes derive from the active light and dark schemes', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness: brightness);
      final scheme = theme.colorScheme;
      expect(theme.dialogTheme.backgroundColor, scheme.surfaceContainerHigh);
      expect(theme.bottomSheetTheme.modalBackgroundColor,
          scheme.surfaceContainerLow);
      expect(
          theme.datePickerTheme.backgroundColor, scheme.surfaceContainerHigh);
      expect(
          theme.timePickerTheme.backgroundColor, scheme.surfaceContainerHigh);
      expect(theme.popupMenuTheme.color, scheme.surfaceContainerHigh);
    }
  });

  testWidgets('dialog layout stays reachable at 320 wide and 200% text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness: brightness);
      await tester.pumpWidget(host(theme, (context, setState) async {
        await showAppDialog<void>(
          context: context,
          builder: (_) => AppDialog(
            title: const Text('Delete this item?'),
            content: const Text(
                'This is a longer explanation that must remain readable and '
                'scrollable when the screen is narrow and the text is large. '
                'The action below must stay reachable without clipping.'),
            scrollable: true,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }));
      await tester.tap(find.byKey(const Key('openDialog')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.backgroundColor, theme.colorScheme.surfaceContainerHigh);
      expect(dialog.scrollable, isTrue);
      expect(find.text('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('AppSimpleDialog remains a SimpleDialog choice list',
      (tester) async {
    final theme = buildAppTheme(brightness: Brightness.light);
    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppDialog<void>(
        context: context,
        builder: (_) => AppSimpleDialog(
          title: const Text('Choose a month'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('October'),
            ),
          ],
        ),
      );
    }));
    await tester.tap(find.byKey(const Key('openDialog')));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialog), findsOneWidget);
    expect(find.text('October'), findsOneWidget);
  });

  for (final confirm in [false, true]) {
    testWidgets('confirmation returns ${confirm ? 'true' : 'false'}',
        (tester) async {
      bool? result;
      final theme = buildAppTheme(brightness: Brightness.light);
      await tester.pumpWidget(host(theme, (context, setState) async {
        final value = await showAppConfirm(
          context,
          title: 'Save changes?',
          message: 'Only this purchase will be updated.',
          confirmLabel: 'Save',
        );
        setState(() => result = value);
      }));
      await tester.tap(find.byKey(const Key('openDialog')));
      await tester.pumpAndSettle();

      expect(find.text('Save changes?'), findsOneWidget);
      expect(find.text('Only this purchase will be updated.'), findsOneWidget);
      await tester.tap(
          find.byKey(Key(confirm ? 'appConfirmConfirm' : 'appConfirmCancel')));
      await tester.pumpAndSettle();

      expect(result, confirm);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  testWidgets('busy confirmation blocks barrier, back and actions',
      (tester) async {
    final theme = buildAppTheme(brightness: Brightness.light);
    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppConfirm(
        context,
        title: 'Saving',
        message: 'Please wait while the purchase is written.',
        busy: true,
      );
    }));
    await tester.tap(find.byKey(const Key('openDialog')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('appConfirmBusy')), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('appConfirmConfirm')))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<TextButton>(find.byKey(const Key('appConfirmCancel')))
            .onPressed,
        isNull);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('appConfirmTitle')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('appConfirmTitle')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('destructive confirmation uses the error colour', (tester) async {
    final theme = buildAppTheme(brightness: Brightness.dark);
    final scheme = theme.colorScheme;
    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppConfirm(
        context,
        title: 'Discard changes?',
        message: 'Unsaved edits will be lost.',
        confirmLabel: 'Discard',
        destructive: true,
      );
    }));
    await tester.tap(find.byKey(const Key('openDialog')));
    await tester.pumpAndSettle();

    final confirm =
        tester.widget<FilledButton>(find.byKey(const Key('appConfirmConfirm')));
    expect(confirm.style?.backgroundColor?.resolve(const <WidgetState>{}),
        scheme.error);
    expect(find.text('Discard'), findsOneWidget);
  });
}
