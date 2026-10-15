/// The synthetic, collision-safe `SharedMember.profileId` for an identity
/// (`data-model.md` §3.1, `contracts/role-authorization.md` §2).
///
/// A paired person has no local `UserProfile`, so the membership that adds them
/// is keyed by a value derived deterministically from the peer's identity
/// fingerprint. Every device computes the same id from the same fingerprint, so
/// the signed membership converges; the value is always **negative**, which can
/// never collide with the positive autoIncrement ids of local profiles (FR-016).
///
/// Lives in the identity domain (not `features/pairing`) so both the spaces data
/// layer — which keys every membership by this value (T044a) — and the sync
/// engine — which resolves an author's membership by it — can use it without
/// importing the pairing feature.
int remoteProfileIdFor(String identityId) {
  final hex = identityId.replaceAll(RegExp('[^0-9a-fA-F]'), '');
  final source =
      hex.length >= 12 ? hex.substring(0, 12) : hex.padRight(12, '0');
  final value = int.parse(source, radix: 16);
  return -value - 1;
}
