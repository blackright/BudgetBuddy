import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/shared/presentation/modals/app_date_picker.dart';
import 'package:budget_buddy/shared/presentation/modals/app_picker_sheet.dart';
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
              key: const Key('openPicker'),
              onPressed: () => open(context, setState),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  const entries = [
    AppPickerEntry(value: 'Apple', title: 'Apple'),
    AppPickerEntry(value: 'Banana', title: 'Banana', subtitle: 'Yellow fruit'),
    AppPickerEntry(value: 'Cherry', title: 'Cherry'),
  ];

  testWidgets('search filters and selection returns the chosen value',
      (tester) async {
    String? result;
    final theme = buildAppTheme(brightness: Brightness.light);
    await tester.pumpWidget(host(theme, (context, setState) async {
      final value = await showAppPickerSheet<String>(
        context,
        title: 'Choose a fruit',
        items: entries,
      );
      setState(() => result = value);
    }));
    await tester.tap(find.byKey(const Key('openPicker')));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    await tester.enterText(find.byKey(AppPickerSheet.searchKey), 'yellow');
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
    expect(find.text('Banana'), findsOneWidget);
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(result, 'Banana');
    expect(find.text('Choose a fruit'), findsNothing);
  });

  testWidgets('empty, loading and error states are explicit', (tester) async {
    final theme = buildAppTheme(brightness: Brightness.light);

    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppPickerSheet<String>(
        context,
        title: 'Empty picker',
        items: const [],
      );
    }));
    await tester.tap(find.byKey(const Key('openPicker')));
    await tester.pumpAndSettle();
    expect(find.byKey(AppPickerSheet.emptyKey), findsOneWidget);
    await tester.tap(find.byKey(const Key('appSheetClose')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppPickerSheet<String>(
        context,
        title: 'Loading picker',
        items: entries,
        loading: true,
      );
    }));
    await tester.tap(find.byKey(const Key('openPicker')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byKey(const Key('appSheetClose')));
    await tester.pumpAndSettle();

    var retries = 0;
    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppPickerSheet<String>(
        context,
        title: 'Error picker',
        items: entries,
        errorText: 'Could not load choices.',
        onRetry: () => retries++,
      );
    }));
    await tester.tap(find.byKey(const Key('openPicker')));
    await tester.pumpAndSettle();
    expect(find.text('Could not load choices.'), findsOneWidget);
    await tester.tap(find.byKey(AppPickerSheet.retryKey));
    await tester.pumpAndSettle();
    expect(retries, 1);
  });

  testWidgets('picker stays usable at 320 wide and 200% text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final theme = buildAppTheme(brightness: Brightness.dark);
    await tester.pumpWidget(host(theme, (context, setState) async {
      await showAppPickerSheet<String>(
        context,
        title: 'Choose a fruit',
        items: entries,
      );
    }));
    await tester.tap(find.byKey(const Key('openPicker')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a fruit'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('date wrapper returns the picked date', (tester) async {
    DateTime? result;
    final theme = buildAppTheme(brightness: Brightness.light);
    await tester.pumpWidget(host(theme, (context, setState) async {
      final value = await showAppDatePicker(
        context: context,
        initialDate: DateTime(2026, 10, 15),
        firstDate: DateTime(2026, 10, 1),
        lastDate: DateTime(2026, 10, 31),
      );
      setState(() => result = value);
    }));
    await tester.tap(find.byKey(const Key('openPicker')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('20').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(result, DateTime(2026, 10, 20));
  });
}
