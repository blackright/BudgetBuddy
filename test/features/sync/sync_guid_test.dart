import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the identity contract of `newSyncGuid()` (research R5): a lowercase
/// RFC-4122 version-4 UUID, unique across many calls.
void main() {
  // 8-4-4-4-12 lowercase hex, version nibble `4`, variant nibble `8`–`b`.
  final v4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('returns a lowercase RFC-4122 v4 UUID', () {
    final guid = newSyncGuid();
    expect(v4.hasMatch(guid), isTrue, reason: guid);
    expect(guid, guid.toLowerCase());
  });

  test('is unique across many calls', () {
    final seen = <String>{};
    for (var i = 0; i < 10000; i++) {
      expect(seen.add(newSyncGuid()), isTrue, reason: 'duplicate at $i');
    }
  });
}
