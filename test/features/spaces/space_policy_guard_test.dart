import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:flutter_test/flutter_test.dart';

/// T053 (FR-027, FR-028): only the Owner may author the space's security policy.
///
/// The policy lives on `SharedSpace`, and `SpaceAccessGuard` names `SharedSpace`
/// an Owner-only entity type — so a non-Owner's write is refused at apply time
/// even if it somehow reached the engine. These cases pin that the refusal is by
/// role, not by luck.
SharedMember _member(SharedMemberRole role) => SharedMember()
  ..sharedSpaceId = 1
  ..profileId = 2
  ..role = role
  ..joinedAt = DateTime(2026);

ChangeRecord _spaceChange({int hlcMillis = 1000}) => ChangeRecord()
  ..entityType = 'SharedSpace'
  ..hlcMillis = hlcMillis;

void main() {
  const guard = SpaceAccessGuard();

  group('T053: the Owner may author a SharedSpace policy change', () {
    test('an Owner is allowed', () {
      final author = _member(SharedMemberRole.owner);

      expect(guard.canAuthor(author, 'SharedSpace'), isTrue);
      expect(
        () => guard.assertAuthorizedAt(
          _spaceChange(),
          membershipHead: author,
          sealed: false,
        ),
        returnsNormally,
      );
    });
  });

  group('T053: a non-Owner is refused', () {
    test('an Editor cannot author the policy', () {
      final author = _member(SharedMemberRole.editor);

      expect(guard.canAuthor(author, 'SharedSpace'), isFalse);
      expect(
        () => guard.assertAuthorizedAt(
          _spaceChange(),
          membershipHead: author,
          sealed: false,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('a Viewer cannot author the policy', () {
      final author = _member(SharedMemberRole.viewer);

      expect(guard.canAuthor(author, 'SharedSpace'), isFalse);
      expect(
        () => guard.assertAuthorizedAt(
          _spaceChange(),
          membershipHead: author,
          sealed: false,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('a non-member cannot author the policy', () {
      expect(guard.canAuthor(null, 'SharedSpace'), isFalse);
      expect(
        () => guard.assertAuthorizedAt(
          _spaceChange(),
          membershipHead: null,
          sealed: false,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });
  });
}
