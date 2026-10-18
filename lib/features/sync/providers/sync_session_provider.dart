import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/identity.dart';
import '../../../core/providers/identity_provider.dart';
import '../../identity/providers/device_key_session.dart';
import '../repositories/change_signer.dart';

/// The unlocked local identity for this app session: the identity row plus the
/// ed25519 keypair released from the keystore (research R2).
///
/// A session exists only while the identity is unlocked; the coordinator starts
/// and the recorder signs only when one is present, and both go quiet the moment
/// it disappears (contract `runtime-orchestration.md` §1).
class SyncSession {
  SyncSession({required this.identity, required this.keyPair});

  /// The local identity row (username + fingerprint + public key).
  final Identity identity;

  /// The private keypair, held only in memory for this session (never persisted).
  final SimpleKeyPair keyPair;

  /// A signer bound to this identity's fingerprint, used by the recorder so a
  /// change-record verifies on the peer (`change_signer.dart`).
  ChangeSigner get signer => Ed25519ChangeSigner(
        authorIdentityId: identity.fingerprint,
        keyPair: keyPair,
      );
}

/// The unlocked identity for this session, or `null` while locked / before
/// onboarding (research R2).
///
/// Reads [deviceKeySessionProvider]'s **value**, never a future, so the sync
/// layer can never originate a keystore prompt of its own: it simply stays
/// quiet (`null` → no coordinator → nothing transmitted) until the app-lock
/// gate has released the key, and picks up automatically the moment it does
/// (T074). That is the "at most one keystore prompt per launch" contract this
/// file always promised — the old `unlockedKeyPairProvider.future` read broke
/// it by firing a second, racing prompt at cold start.
final syncSessionProvider = FutureProvider<SyncSession?>((ref) async {
  final identity = ref.watch(identityProvider).valueOrNull;
  if (identity == null) return null;
  final keyPair = ref.watch(deviceKeySessionProvider);
  if (keyPair == null) return null;
  return SyncSession(identity: identity, keyPair: keyPair);
});
