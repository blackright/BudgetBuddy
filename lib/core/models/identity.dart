import 'package:isar/isar.dart';

part 'identity.g.dart';

/// The local person, with no account (data-model §2.1, FR-001/016).
///
/// A [username] is a **label only** — never unique anywhere and never a lookup
/// key. The username ⇄ key binding is established solely by scanning a QR in
/// person (`contracts/pairing.md` §1). Exactly one identity links to exactly one
/// personal profile via [localProfileId] (FR-016).
///
/// The **private key is not stored here**: it lives only in the device keystore
/// (`flutter_secure_storage`, research R1). This row keeps the public half and a
/// human-comparable [fingerprint].
@collection
class Identity {
  Id id = Isar.autoIncrement;

  /// Display name chosen by the user. Non-empty, but not unique anywhere
  /// (FR-001/004).
  String username = '';

  /// Base64-encoded ed25519 public key (FR-001).
  String publicKey = '';

  /// The signing algorithm, so a future rotation is representable (R1).
  String keyAlgorithm = 'ed25519';

  /// The single personal profile this identity acts for (FR-016). The unique
  /// index makes a second identity-for-one-profile impossible.
  @Index(unique: true, replace: true)
  int localProfileId = 0;

  /// Short human-comparable hash of [publicKey], shown next to a username
  /// everywhere a peer appears (pairing disambiguation, FR-004).
  String fingerprint = '';

  late DateTime createdAt;

  late DateTime updatedAt;
}
