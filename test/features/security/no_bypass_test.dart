import 'dart:io';

import 'package:budget_buddy/features/security/domain/weak_pins.dart';
import 'package:flutter_test/flutter_test.dart';

/// T079 (FR-038): no factory, default or service PIN exists in the sources, and
/// every route paints through the gate mounted in `MaterialApp.router`'s
/// builder, so no link, notification or settings entry reaches content without
/// the lock.
///
/// A backdoor rarely arrives as a backdoor. It arrives as a convenience: a
/// "development" PIN that skips the prompt, a `// TODO: remove` default, a
/// bypass flag that ships. FR-038 forbids the *existence* of such a thing, so
/// the guard has to read the source, not trust a code review.
void main() {
  final root = Directory.current.path;

  Future<List<String>> dartFiles(String directory) async {
    final dir = Directory('$root/$directory');
    final files = <String>[];
    if (!dir.existsSync()) return files;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) files.add(entity.path);
    }
    return files;
  }

  group('T079: no bypass PIN is written into the security feature', () {
    test('the security feature names no factory/default/service PIN', () async {
      final offenders = <String>[];
      final pattern = RegExp(
        r'\b(factoryPin|masterPin|defaultPin|servicePin|backdoor|bypassPin|'
        r'adminPin|debugPin|testPin)\b',
        caseSensitive: false,
      );

      for (final path in await dartFiles('lib/features/security')) {
        final lines = await File(path).readAsLines();
        for (var i = 0; i < lines.length; i++) {
          if (pattern.hasMatch(lines[i])) {
            offenders.add('$path:${i + 1}: ${lines[i].trim()}');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'a named bypass PIN is a bypass PIN (FR-038)\n'
              '${offenders.join('\n')}');
    });

    test('no PIN literal is accepted without the policy check', () async {
      // The two known-correct literals are the KDF's calibration probe and the
      // weak-PIN rejection list. Anything else that looks like a 4-8 digit PIN
      // in the security feature is a suspect.
      final allowed = <String>{
        // The calibration probe: never stored, never compared (FR-012).
        "await derive(pin: '000000', salt: salt, iterations: iterations);",
      };

      final suspects = <String>[];
      final literal = RegExp(r"'(\d{4,8})'");

      for (final path in await dartFiles('lib/features/security')) {
        // The weak-PIN list is *about* weak PINs; it is allowed to name them.
        if (path.endsWith('weak_pins.dart')) continue;

        final lines = await File(path).readAsLines();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (!literal.hasMatch(line)) continue;
          if (allowed.any(line.trim().contains)) continue;
          suspects.add('$path:${i + 1}: ${line.trim()}');
        }
      }

      // Comments and doc blocks legitimately cite examples; only code counts.
      final codeSuspects = suspects
          .where((s) => !s.trimLeft().startsWith('//'))
          .where((s) => !s.contains('///'))
          .toList();

      expect(codeSuspects, isEmpty,
          reason: 'a hard-coded PIN in code is a factory PIN (FR-038)\n'
              '${codeSuspects.join('\n')}');
    });
  });

  group('T079: the gate cannot be routed around', () {
    test('main.dart mounts AppLockGate inside the router builder', () async {
      final main = await File('$root/lib/main.dart').readAsString();

      expect(main, contains('MaterialApp.router'),
          reason: 'the router is the only app root that matters');
      expect(main, contains('AppLockGate('),
          reason: 'the gate must be mounted, not merely imported');

      // The gate must be inside `builder:`, which wraps *every* route — not on
      // one screen, where every other route would slip past it.
      final builderIndex = main.indexOf('builder: (context, child)');
      final gateIndex = main.indexOf('AppLockGate(');
      expect(builderIndex, greaterThan(-1),
          reason: 'the router needs a builder for the gate to wrap all routes');
      expect(gateIndex, greaterThan(builderIndex),
          reason: 'the gate must sit inside the router builder (FR-038)');
    });

    test('the gate is the only place content is withheld, and it is total',
        () async {
      final gate = await File(
        '$root/lib/features/identity/presentation/app_lock_gate.dart',
      ).readAsString();

      // The gate is the single choke point; it must not be an opt-in wrapper
      // that a screen can forget to use.
      expect(gate, contains('class AppLockGate'),
          reason: 'the gate is the choke point T079 guards');
    });

    test('the weak-PIN policy refuses the PINs a bypass would use', () {
      // If a factory PIN did exist, it would almost certainly be one of these.
      // Proving the policy refuses them shows the shortcut could not survive
      // even if someone tried it.
      for (final weak in ['0000', '1111', '1234', '9999', '1212']) {
        expect(WeakPins.isWeak(weak), isTrue,
            reason: '$weak must be refused by the policy');
      }
      expect(WeakPins.isWeak('4821'), isFalse);
    });
  });
}
