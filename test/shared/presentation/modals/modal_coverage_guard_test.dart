import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Detects raw overlay route calls and raw dialog content widgets.
///
/// The shared modal layer is the only place allowed to call these APIs
/// directly. The final guard requires an empty result outside that layer.
final _overlayCall = RegExp(
  r'\b(?:showDialog|showModalBottomSheet|showDatePicker|showTimePicker|showMenu)'
  r'\s*(?:<[^(\r\n]*>)?\s*\('
  r'|\b(?:AlertDialog|SimpleDialog)\s*\(',
);

/// Custom overlay content widgets listed in `overlay-inventory.md`. Each one is
/// hosted by a shared route or a shared dialog after the migration.
const _customOverlayContentFiles = [
  'lib/features/expenses/presentation/refund_dialog.dart',
  'lib/features/vault/presentation/vault_recovery_dialog.dart',
  'lib/features/finance/presentation/receipt_adoption_sheet.dart',
  'lib/features/finance/presentation/opening_balance_sheet.dart',
  'lib/features/finance/presentation/income_activation_sheet.dart',
  'lib/features/spaces/presentation/create_space_sheet.dart',
  'lib/features/spaces/presentation/invite_sheet.dart',
  'lib/features/finance/presentation/salary_receipt_sheet.dart',
  'lib/features/finance/presentation/income_receipt_sheet.dart',
  'lib/features/finance/presentation/balance_checkpoint_sheet.dart',
  'lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart',
];

Set<String> _scanLib() {
  final found = <String>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final normalized = entity.path.replaceAll('\\', '/');
    final marker = normalized.indexOf('/lib/');
    final relative = marker < 0 ? normalized : normalized.substring(marker + 1);
    if (relative.startsWith('lib/shared/presentation/modals/') ||
        relative.endsWith('.g.dart')) {
      continue;
    }
    if (_overlayCall.hasMatch(entity.readAsStringSync())) {
      found.add(relative);
    }
  }
  return found;
}

void main() {
  test('the scanner recognises every banned overlay call form', () {
    const source = '''
showDialog<void>(context: context);
showModalBottomSheet<bool>(context: context);
showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now);
showTimePicker(context: context, initialTime: now);
showMenu<int>(context: context, items: const []);
AlertDialog(title: const Text('x'));
SimpleDialog(title: const Text('y'));
''';
    expect(_overlayCall.allMatches(source), hasLength(7));
  });

  test('the production tree has no raw overlay calls', () {
    expect(
      _scanLib(),
      isEmpty,
      reason:
          'Every production overlay must use lib/shared/presentation/modals/',
    );
  });

  test('known custom overlay content widgets contain no raw dialogs', () {
    for (final path in _customOverlayContentFiles) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Missing $path');
      expect(
        _overlayCall.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: '$path still contains a raw overlay call',
      );
    }
  });

  test('the shared modal layer remains excluded from the guard', () {
    expect(
      _scanLib()
          .where((path) => path.startsWith('lib/shared/presentation/modals/')),
      isEmpty,
    );
  });
}
