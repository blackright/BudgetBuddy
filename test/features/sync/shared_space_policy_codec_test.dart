import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_space_codec.dart';
import 'package:flutter_test/flutter_test.dart';

/// T052 (FR-030): the Owner's security requirement round-trips through the sync
/// payload, and a payload written by an older build — one that never knew these
/// fields — decodes to "no requirement" rather than to a hidden default.
///
/// The codec is the only thing that crosses the wire, so this is where "the
/// member learns the Owner's choice" and "an old payload stays safe" are pinned.
SharedSpace _space({
  bool requirePin = false,
  bool forbidBiometrics = false,
  AwayTime? awayTime,
}) {
  final space = SharedSpace()
    ..syncGuid = 'guid-policy'
    ..name = 'Home'
    ..avatar = '🏠'
    ..currency = PrimaryCurrency.usd
    ..defaultIncome = 250000
    ..createdByProfileId = 3
    ..createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5)
    ..requirePin = requirePin
    ..forbidBiometrics = forbidBiometrics;
  space.awayTime = awayTime;
  return space;
}

void main() {
  const codec = SharedSpaceCodec();

  group('T052: the three policy fields round-trip', () {
    test('a full requirement survives toJson -> fromJson', () {
      final original = _space(
        requirePin: true,
        forbidBiometrics: true,
        awayTime: AwayTime.oneMinute,
      );

      final restored = codec.fromJson(codec.toJson(original));

      expect(restored.requirePin, isTrue);
      expect(restored.forbidBiometrics, isTrue);
      expect(restored.awayTime, AwayTime.oneMinute);
    });

    test('a set away-time survives through the canonical payload string', () {
      final original = _space(awayTime: AwayTime.fiveMinutes);

      final restored = codec.fromPayload(codec.toPayload(original));

      expect(restored.awayTime, AwayTime.fiveMinutes);
    });

    test('an unset away-time round-trips as null, never as a default', () {
      final original = _space();

      final restored = codec.fromPayload(codec.toPayload(original));

      expect(restored.awayTime, isNull,
          reason: 'null is "the Owner set none", not a hidden two minutes');
      expect(restored.awayTimeIndex, -1);
    });
  });

  group('T052: a payload without the fields means "no requirement"', () {
    test('missing requirePin and forbidBiometrics decode to false', () {
      final legacy = <String, Object?>{
        'syncGuid': 'guid-legacy',
        'name': 'Old space',
        'avatar': '🏠',
        'currency': 'usd',
        'defaultIncome': 0,
        'createdByProfileId': 1,
        'createdAt': DateTime.utc(2026, 1, 2, 3, 4, 5).millisecondsSinceEpoch,
      };

      final restored = codec.fromJson(legacy);

      expect(restored.requirePin, isFalse);
      expect(restored.forbidBiometrics, isFalse);
      expect(restored.awayTime, isNull,
          reason: 'a missing awayTime is "none", not a default window');
    });
  });
}
