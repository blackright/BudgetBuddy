import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';

/// Existing key-release regressions explicitly model an identity-present actor.
/// The separate personal-only test uses real absent metadata and no fake key.
Identity nativeFixtureIdentity() => Identity()
  ..id = 1
  ..localProfileId = 1
  ..username = 'Test actor'
  ..publicKey = 'test-public-key'
  ..createdAt = DateTime(2026)
  ..updatedAt = DateTime(2026);
NativeAccessBinding nativeFixtureBinding(Ref ref) {
  final subject = ref.watch(lockSubjectProvider);
  return NativeAccessBinding(
      key: subject?.key ?? 'p1',
      identity: nativeFixtureIdentity(),
      isShared: subject?.kind == LockSubjectKind.space);
}
