import 'package:cryptography/cryptography.dart';

/// The short, human-comparable fingerprint of a raw ed25519 public key
/// (data-model §2.1, FR-004).
///
/// The first 16 hex characters (64 bits) of the SHA-256 of the key: long enough
/// to disambiguate peers, short enough to read aloud. Kept as a free function so
/// both [IdentityService] and the pairing code compute the *exact same* value
/// and can cross-check a scanned key against the fingerprint it claims.
Future<String> fingerprintOfPublicKeyBytes(List<int> publicKeyBytes) async {
  final hash = await Sha256().hash(publicKeyBytes);
  final hex = hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return hex.substring(0, 16);
}
