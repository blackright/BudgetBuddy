/// What a lock protects: exactly one personal profile or one shared space
/// (data-model §1).
///
/// The lock introduces no new notion of account — it attaches to subjects the
/// app already has. Pure Dart: no Isar, no Riverpod.
enum LockSubjectKind { profile, space }

/// One subject a [LockSetting] can belong to.
class LockSubject {
  const LockSubject({
    required this.kind,
    required this.localId,
    required this.guid,
    required this.name,
    required this.avatar,
  });

  /// A personal profile.
  factory LockSubject.profile({
    required int id,
    required String name,
    String avatar = '',
  }) =>
      LockSubject(
        kind: LockSubjectKind.profile,
        localId: id,
        guid: '',
        name: name,
        avatar: avatar,
      );

  /// A shared space, keyed by its device-independent `syncGuid` — never by its
  /// local Isar id, which a restored device can hand a different value while the
  /// guid is what every device agrees on (data-model §1, research R1).
  factory LockSubject.space({
    required int localId,
    required String syncGuid,
    required String name,
    String avatar = '',
  }) =>
      LockSubject(
        kind: LockSubjectKind.space,
        localId: localId,
        guid: syncGuid,
        name: name,
        avatar: avatar,
      );

  final LockSubjectKind kind;

  /// The profile id, or the space's local id (display only, data-model §2).
  final int localId;

  /// The space's `syncGuid` when [kind] is [LockSubjectKind.space], else `''`.
  final String guid;

  final String name;

  /// The stored avatar; empty means "render the default" (FR-037).
  final String avatar;

  /// The stable key the verifier and lockout records are stored under
  /// (`sec_pin_<key>` / `sec_lockout_<key>`, contracts §1).
  String get key =>
      kind == LockSubjectKind.space ? spaceKey(guid) : profileKey(localId);

  /// The avatar to render; a profile with no avatar falls back to a plain glyph.
  String get displayAvatar => avatar.isEmpty ? '👤' : avatar;

  static String profileKey(int profileId) => 'p$profileId';

  static String spaceKey(String syncGuid) => 's$syncGuid';

  @override
  bool operator ==(Object other) => other is LockSubject && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'LockSubject($key, $name)';
}
