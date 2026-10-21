import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:flutter_test/flutter_test.dart';

/// T004: what a lock protects, and the key it is stored under (data-model §1).
///
/// The key is the load-bearing part. A space is keyed by its device-independent
/// `syncGuid`, never by its local Isar id: a restored device can hand the same
/// space a different local id, and a lock that followed the id would then protect
/// the wrong space — or, worse, silently stop protecting anything.
void main() {
  group('T004: LockSubject', () {
    test('a profile is keyed by its profile id', () {
      final subject = LockSubject.profile(id: 7, name: 'Ann', avatar: '👩');

      expect(subject.key, 'p7');
      expect(subject.localId, 7);
      expect(subject.guid, isEmpty);
    });

    test('a space is keyed by its syncGuid, not its local id', () {
      final subject = LockSubject.space(
        localId: 3,
        syncGuid: 'guid-abc',
        name: 'Our space',
      );

      expect(subject.key, 'sguid-abc');
      expect(subject.key, isNot('s3'),
          reason: 'the local id must never name the subject');
    });

    test(
        'two devices that hold the same space under different local ids agree '
        'on one subject', () {
      final onThisPhone = LockSubject.space(
        localId: 3,
        syncGuid: 'guid-abc',
        name: 'Our space',
      );
      final onRestoredPhone = LockSubject.space(
        localId: 91,
        syncGuid: 'guid-abc',
        name: 'Our space',
      );

      expect(onThisPhone, onRestoredPhone);
      expect(onThisPhone.hashCode, onRestoredPhone.hashCode);
    });

    test('a profile and a space never collide', () {
      final profile = LockSubject.profile(id: 7, name: 'Ann');
      final space = LockSubject.space(localId: 7, syncGuid: '7', name: 'Space');

      expect(profile.key, 'p7');
      expect(space.key, 's7');
      expect(profile, isNot(space));
    });

    test(
        'an empty avatar falls back to a plain glyph; a set one is kept '
        '(FR-037)', () {
      expect(LockSubject.profile(id: 1, name: 'Ann').displayAvatar, '👤');
      expect(
        LockSubject.profile(id: 1, name: 'Ann', avatar: '👩').displayAvatar,
        '👩',
      );
    });

    test('the key helpers produce the strings the secret keys are built from',
        () {
      expect(LockSubject.profileKey(12), 'p12');
      expect(LockSubject.spaceKey('xyz'), 'sxyz');
    });
  });
}
