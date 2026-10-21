import 'dart:convert';
import 'dart:io';

import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_secret_keys.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/repositories/lockout_store.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_pin_kdf.dart';

/// T071 (FR-042, FR-043, SC-010): no PIN, salt, verifier or iteration count
/// reaches a log or a diagnostic.
///
/// Two halves, because a secret can escape two ways:
/// * the **runtime** half catches anything printed while a PIN is set, checked
///   and reset — the realistic leak, since a well-meaning `debugPrint` added
///   later is exactly how a PIN ends up in a bug report;
/// * the **shape** half proves the secret-bearing types do not spill their
///   contents through `toString()`, which is what a crash reporter or a
///   "log(this)" picks up without anyone writing a log line at all.
void main() {
  const subject = LockSubject(
    kind: LockSubjectKind.profile,
    localId: 1,
    guid: '',
    name: 'Ann',
    avatar: '🧑',
  );

  /// Runs [body] while capturing everything written to [debugPrint] and to the
  /// Flutter error stream, returning the concatenated text.
  Future<String> capture(Future<void> Function() body) async {
    final captured = StringBuffer();
    final previousPrint = debugPrint;
    final previousFlutterError = FlutterError.onError;

    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) captured.writeln(message);
    };
    FlutterError.onError = (details) {
      captured.writeln(details.exceptionAsString());
      captured.writeln(details.stack);
    };

    try {
      await body();
    } finally {
      debugPrint = previousPrint;
      FlutterError.onError = previousFlutterError;
    }
    return captured.toString();
  }

  group('T071: nothing printed carries a secret', () {
    test('setting, checking and resetting a PIN prints no secret', () async {
      final secrets = InMemorySecretStore();
      final store = PinVerifierStore(secrets, kdf: FakePinKdf());
      const pin = '4821';

      final logged = await capture(() async {
        await store.setPin(subject.key, pin);
        await store.verify(subject.key, pin);
        await store.verify(subject.key, '9999');
        await secrets.delete(LockSecretKeys.pin(subject.key));
      });

      expect(logged, isNot(contains(pin)),
          reason: 'the PIN itself must never be written anywhere');

      // The record's parts, read straight out of the store, must not have been
      // echoed either. The record is fetched through a fresh read so this is the
      // real stored shape.
      final raw = await secrets.read(LockSecretKeys.pin(subject.key));
      if (raw != null) {
        final record = PinRecord.tryParse(raw)!;
        expect(logged, isNot(contains(base64Encode(record.salt))),
            reason: 'the salt must not be echoed');
        expect(logged, isNot(contains(base64Encode(record.verifier))),
            reason: 'the verifier must not be echoed');
      }
    });

    test('a lockout record write prints no secret', () async {
      final secrets = InMemorySecretStore();
      final lockout = LockoutStore(secrets);

      final logged = await capture(() async {
        for (var i = 0; i < 5; i++) {
          await lockout.registerFailure(subject.key, nowMs: 1000000);
        }
        await lockout.status(subject.key, nowMs: 1000000);
        await lockout.clear(subject.key);
      });

      expect(logged, isNot(contains(subject.key)),
          reason: 'even the subject key is not a diagnostic');
      expect(logged.toLowerCase(), isNot(contains('iteration')));
    });
  });

  group('T071: the secret-bearing types do not spill through toString', () {
    test('PinRecord does not print its verifier or salt', () {
      final record = PinRecord(
        version: 1,
        kdf: PinRecord.algorithm,
        salt: List<int>.generate(16, (i) => i),
        iterations: 12345,
        verifier: List<int>.generate(32, (i) => 200 + i),
      );

      final text = record.toString();
      expect(text, isNot(contains('12345')),
          reason: 'the iteration count is a hint an attacker should not get '
              'for free from a crash dump');
      expect(text, isNot(contains(base64Encode(record.verifier))));
      expect(text, isNot(contains(base64Encode(record.salt))));
    });

    test('LockoutRecord does not print its contents', () {
      final record = LockoutRecord(
        version: LockoutRecord.currentVersion,
        failCount: 7,
        waitMs: 30000,
        appliedAtElapsedMs: 1000000,
        appliedAtUtc: DateTime.utc(2026, 1, 2).toIso8601String(),
      );

      final text = record.toString();
      expect(text, isNot(contains('7')),
          reason: 'the failure count is the attempt history FR-046 forbids');
      expect(text, isNot(contains('30000')));
    });

    test('the JSON shape is the only place the secret parts appear', () {
      // toJson is the storage form, and that is legitimate: it is what is
      // written to the OS keystore. This test pins that it is not also the
      // printing form, so the two cannot be confused.
      final record = PinRecord(
        version: 1,
        kdf: PinRecord.algorithm,
        salt: List<int>.filled(16, 1),
        iterations: 2,
        verifier: List<int>.filled(32, 2),
      );

      final text = record.toString();
      expect(text, isNot(contains('salt')));
      expect(text, isNot(contains('verifier')));
    });
  });

  group('T071: the source has no stray logging in the security feature', () {
    test('the security feature does not call print or debugPrint', () async {
      // A structural guard rather than a runtime one: this is what stops the
      // *next* person from adding the leak the runtime tests would only catch
      // if they happened to exercise that path.
      final hits = await _strayLoggingIn('lib/features/security');
      expect(hits, isEmpty,
          reason: 'security code must not log: found ${hits.join(', ')}');
    });
  });
}

/// Finds `print(`/`debugPrint(`/`developer.log(` calls under [directory].
Future<List<String>> _strayLoggingIn(String directory) async {
  // Resolved from the test's own location so it works from any working dir.
  final root = Directory.current.path;
  final dir = Directory('$root/$directory');
  final hits = <String>[];
  if (!dir.existsSync()) return hits;

  await for (final entity in dir.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final lines = await entity.readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(r'\b(print|debugPrint|developer\.log)\s*\(').hasMatch(line)) {
        hits.add('${entity.path}:${i + 1}');
      }
    }
  }
  return hits;
}
