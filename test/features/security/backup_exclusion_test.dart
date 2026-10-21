import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// T080 (FR-042, FR-043): the PIN and lockout records stay out of everything
/// that leaves the device.
///
/// Two independent ways a secret can travel: the OS backup/transfer (a restored
/// verifier would let a fresh install accept the old PIN), and any in-app path
/// that reads the key for its own purposes (an export, a share, a diagnostic).
/// Both are guarded here, because closing one and leaving the other is the same
/// as closing neither.
void main() {
  final root = Directory.current.path;

  Future<List<File>> dartFiles(String directory) async {
    final dir = Directory('$root/$directory');
    final files = <File>[];
    if (!dir.existsSync()) return files;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) files.add(entity);
    }
    return files;
  }

  group('T080: the OS cannot back up or transfer the secrets', () {
    test('the manifest disables backup and points at both rule files',
        () async {
      final manifest = await File(
        '$root/android/app/src/main/AndroidManifest.xml',
      ).readAsString();

      expect(manifest, contains('android:allowBackup="false"'),
          reason: 'cloud backup must be off for a lock feature');
      expect(
          manifest, contains('android:fullBackupContent="@xml/backup_rules"'),
          reason: 'Android 11 and lower read this file');
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
        reason: 'Android 12 and higher read this file instead',
      );
    });

    test('the Android 12 rules exclude the secure-storage preferences',
        () async {
      final rules = await File(
        '$root/android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsString();

      expect(rules, contains('<data-extraction-rules>'));
      expect(rules, contains('<cloud-backup>'));
      expect(rules, contains('<device-transfer>'));
      // flutter_secure_storage persists through shared preferences, so that is
      // the domain that carries the verifier and the lockout record.
      expect(
        RegExp(r'<exclude\s+domain="sharedpref"\s+path="\."\s*/>').hasMatch(
            rules.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ')),
        isTrue,
        reason: 'the secure-storage prefs must be excluded from every transfer',
      );
    });

    test('the Android 11 rules exclude the secure-storage preferences',
        () async {
      final rules = await File(
        '$root/android/app/src/main/res/xml/backup_rules.xml',
      ).readAsString();

      expect(rules, contains('<full-backup-content>'));
      expect(
        RegExp(r'<exclude\s+domain="sharedpref"\s+path="\."\s*/>').hasMatch(
            rules.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ')),
        isTrue,
        reason: 'the older backup format needs the same exclusion',
      );
    });
  });

  group('T080: only the two stores reach the secret keys', () {
    test('sec_pin_/sec_lockout_ are read and written in exactly one place',
        () async {
      // The key spellings themselves live in lock_secret_keys.dart, and the two
      // stores that own them use that class. Any *other* file touching the raw
      // prefixes **in code** is a path out of the device — an export, a share,
      // a log. Doc comments that explain the naming are not a leak, so they are
      // stripped before matching.
      final allowed = {
        'lib/features/security/domain/lock_secret_keys.dart',
        'lib/features/security/repositories/pin_verifier_store.dart',
        'lib/features/security/repositories/lockout_store.dart',
      };

      final offenders = <String>[];
      for (final file in await dartFiles('lib')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (allowed.any(normalized.endsWith)) continue;

        final lines = await file.readAsLines();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trimLeft();
          // Comments are explanations, not code paths.
          if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
          if (line.contains("'sec_pin_") ||
              line.contains('"sec_pin_') ||
              line.contains("'sec_lockout_") ||
              line.contains('"sec_lockout_')) {
            offenders.add('$normalized:${i + 1}: $trimmed');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'only the two stores may name the secret prefixes (FR-042)\n'
              '${offenders.join('\n')}');
    });

    test('no export, share or log path imports the secret keys', () async {
      // A narrower, more meaningful read: even the two allowed stores must not
      // hand their contents to an outbound path.
      final offenders = <String>[];
      final outbound = RegExp(
        r'\b(export|share|Share|Clipboard|toCsv|toJson|encode)\b',
      );

      for (final file in await dartFiles('lib/features/security')) {
        final lines = await file.readAsLines();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
          if (!line.contains('sec_pin_') && !line.contains('sec_lockout_')) {
            continue;
          }
          if (outbound.hasMatch(line)) {
            offenders.add('${file.path}:${i + 1}: $trimmed');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'a secret key must not be near an outbound call (FR-043)\n'
              '${offenders.join('\n')}');
    });

    test('the verifier record is stored only through the secret store',
        () async {
      final store = await File(
        '$root/lib/features/security/repositories/pin_verifier_store.dart',
      ).readAsString();

      // The one storage this class touches is the SecretStore (the OS keystore).
      expect(store, contains('SecretStore'),
          reason: 'the verifier lives in the OS keystore, nowhere else');

      // Comments legitimately *mention* Isar to explain why it is not used; the
      // assertion is about imports, which are code.
      final codeLines = store
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .where((l) => !l.trimLeft().startsWith('///'))
          .join('\n');
      expect(codeLines, isNot(contains("import 'package:isar/isar.dart'")),
          reason: 'a verifier in the database would travel with a sync/export');
      expect(codeLines, isNot(contains('.writeTxn')),
          reason: 'no database transaction may carry the verifier');
    });
  });
}
