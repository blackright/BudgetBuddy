import 'dart:convert';

import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_space_codec.dart';
import 'package:flutter_test/flutter_test.dart';

/// T055 (FR-030): the space-policy payload carries the Owner's *choice* and
/// nothing that could open the lock.
///
/// FR-030 is a negative requirement: no PIN, no verifier, no salt, no key
/// material ever crosses the wire. A member learns "you must use a PIN" — never
/// the bytes that satisfy it. This reads the exact string a device would send and
/// proves the secret-shaped things are absent.
SharedSpace _lockedSpace() {
  final space = SharedSpace()
    ..syncGuid = 'guid-secret'
    ..name = 'Home'
    ..avatar = '🏠'
    ..currency = PrimaryCurrency.usd
    ..defaultIncome = 0
    ..createdByProfileId = 1
    ..createdAt = DateTime.utc(2026, 1, 2)
    ..requirePin = true
    ..forbidBiometrics = true;
  space.awayTime = AwayTime.thirtySeconds;
  return space;
}

void main() {
  const codec = SharedSpaceCodec();

  group('T055: the payload carries only the Owner\'s choice', () {
    late String payload;
    late Map<String, Object?> decoded;

    setUp(() {
      payload = codec.toPayload(_lockedSpace());
      decoded = jsonDecode(payload) as Map<String, Object?>;
    });

    test('the three policy fields are present as plain values', () {
      expect(decoded['requirePin'], isTrue);
      expect(decoded['forbidBiometrics'], isTrue);
      expect(decoded['awayTimeIndex'], AwayTime.thirtySeconds.index);
    });

    test('no key names hint at a stored secret', () {
      // The policy field `requirePin` legitimately names the *requirement*; what
      // must never appear is a key that names secret *material* (a value we hold
      // and compare against, not a rule we enforce). So the check is on whole
      // key names, and `requirePin`/`forbidBiometrics` are the only `pin`/
      // `biometric` names allowed.
      const allowed = {'requirePin', 'forbidBiometrics'};
      const secretKeys = {
        'pin',
        'pinhash',
        'pinverifier',
        'verifier',
        'salt',
        'kdf',
        'iterations',
        'key',
        'keymaterial',
        'secret',
        'password',
        'hash',
      };
      for (final key in decoded.keys) {
        if (allowed.contains(key)) continue;
        expect(secretKeys.contains(key.toLowerCase()), isFalse,
            reason: 'the payload must never name a secret via "$key"');
      }
    });

    test('the payload has no value that looks like a digest or a PIN', () {
      // No long hex/base64 blobs, and no bare 4-8 digit number that could be a
      // PIN written by mistake. `requirePin` is a bool, never a value.
      final digits = RegExp(r'^\d{4,8}$');
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is String) {
          expect(value.length, lessThan(64),
              reason: 'no field is long enough to be a hash: ${entry.key}');
          expect(value, isNot(matches(RegExp(r'^[0-9a-fA-F]{32,}$'))),
              reason: 'no hex digest appears: ${entry.key}');
        }
        if (value is num) {
          expect(digits.hasMatch(value.toString()), isFalse,
              reason: 'no bare PIN-shaped number appears: ${entry.key}');
        }
      }
    });
  });
}
