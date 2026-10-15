import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Signs the canonical bytes of a [ChangeRecord] on behalf of one identity
/// (data-model §2.6, research R3/R5).
///
/// The recorder depends on this interface, not on the identity service, so tests
/// can sign with a fixed in-memory keypair and production can sign with the
/// unlocked keystore key.
abstract class ChangeSigner {
  /// The signer's identity fingerprint (`Identity.fingerprint`), recorded as the
  /// change's author for apply-time authorization (role-authorization §3).
  String get authorIdentityId;

  /// Returns the base64 ed25519 signature over [message].
  Future<String> sign(List<int> message);
}

/// The real ed25519 signer over an unlocked keypair.
class Ed25519ChangeSigner implements ChangeSigner {
  Ed25519ChangeSigner({
    required this.authorIdentityId,
    required SimpleKeyPair keyPair,
    Ed25519? algorithm,
  })  : _keyPair = keyPair,
        _ed25519 = algorithm ?? Ed25519();

  @override
  final String authorIdentityId;

  final SimpleKeyPair _keyPair;
  final Ed25519 _ed25519;

  @override
  Future<String> sign(List<int> message) async {
    final signature = await _ed25519.sign(message, keyPair: _keyPair);
    return base64Encode(signature.bytes);
  }
}
