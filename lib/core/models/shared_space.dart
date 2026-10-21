import 'package:isar/isar.dart';

import '../../features/security/domain/away_time.dart';
import '../../features/sync/domain/sync_guid.dart';
import 'user_profile.dart';

part 'shared_space.g.dart';

/// One shared financial space (FR-002): a room several profiles collaborate in.
///
/// A space owns months via `MonthlyBudget.sharedSpaceId`, its own "Our income"
/// pot (FR-009) and a members list (`SharedMember`). Money rows are exactly-one-
/// context: a row belongs either to a personal profile or to a space, never both
/// and never neither (`data-model` §3).
@collection
class SharedSpace {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5). Generated on
  /// creation, never changed, shared by every device. Records and payloads refer
  /// to the row by this value, never by the local `Id`.
  ///
  /// Indexed but **not** unique: on Isar 3.1 a unique index would replace (or
  /// refuse) the rows that still carry the pre-migration default, so uniqueness
  /// is held by construction (`newSyncGuid()` per instance) and by migration
  /// step 17, which backfills every pre-existing row once.
  @Index()
  String syncGuid = newSyncGuid();

  /// Required, non-empty (FR-002).
  String name = '';

  /// Emoji avatar; defaults to a family glyph.
  String avatar = '👨‍👩‍👧';

  /// Shared display/default currency (FR-002).
  @enumerated
  late PrimaryCurrency currency;

  /// "Our income" default, in whole minor units of [currency] (FR-009).
  int defaultIncome = 0;

  /// The creating profile's id — provenance; the creator becomes the first
  /// Owner (FR-006).
  late int createdByProfileId;

  late DateTime createdAt;

  /// Whether this row is still the bare anchor `resolveLocalContext` stores on
  /// first sight, before the peer's full space record arrives (T071). A real
  /// space always carries a non-epoch [createdAt].
  bool get isPendingSync => createdAt.millisecondsSinceEpoch == 0;

  /// The Owner's requirement: everyone entering must unlock with their own PIN
  /// (FR-027). Authorable only by the Owner — the write is refused by
  /// `SpaceAccessGuard.canManage` (016 contracts §1).
  bool requirePin = false;

  /// The Owner forbids the in-session biometric shortcut for this space, so only
  /// the member's PIN is accepted here (FR-020, FR-027). Named for its effect:
  /// it never *requires* a biometric, which no device can be made to have.
  bool forbidBiometrics = false;

  /// The Owner's away-time for the space, or `null` when the Owner set **no**
  /// requirement — `null` is not a hidden two-minute default (FR-028, FR-033).
  ///
  /// Stored as the enum's index, because Isar 3.1 refuses to persist a
  /// *nullable* `@enumerated` field ("Bytes must not be nullable"). `-1` is the
  /// stored spelling of `null`; [awayTime] reads it back as `null`, so nothing
  /// above this line sees the encoding. The accessor lives in the extension
  /// below because Isar treats any public `AwayTime`-typed getter on the class
  /// itself as another property to persist.
  int awayTimeIndex = -1;

  /// The name to show in the switcher and headers: the real name, or a waiting
  /// hint while the full space row has not been delivered yet (T071) — so a
  /// freshly-added phone never flashes a blank "Shared space".
  String get displayName => isPendingSync ? 'Waiting for first sync…' : name;
}

/// The Owner's requirement as the rest of the app reads and writes it: `null`
/// means "the Owner set no requirement", never a hidden default.
extension SharedSpacePolicy on SharedSpace {
  AwayTime? get awayTime {
    final index = awayTimeIndex;
    if (index < 0 || index >= AwayTime.values.length) return null;
    return AwayTime.values[index];
  }

  set awayTime(AwayTime? value) => awayTimeIndex = value?.index ?? -1;
}
