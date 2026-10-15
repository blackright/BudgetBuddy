import 'package:isar/isar.dart';

import 'context_kind.dart';

part 'change_record.g.dart';

/// The signed, versioned unit of exchange (data-model §2.6, FR-006).
///
/// Appended by the `SyncRecorder` seam on every write to a **paired shared
/// context**. Exchanged in HLC order, applied idempotently; a [op] of `delete`
/// is a tombstone whose [payload] is empty and which is retained so a record is
/// never resurrected (`contracts/sync-protocol.md` §1/§4).
@collection
class ChangeRecord {
  Id id = Isar.autoIncrement;

  /// `shared` in v1 (FR-016).
  @enumerated
  late ContextKind contextKind;

  /// The `SharedSpace.id`.
  @Index(composite: [
    CompositeIndex('entityType'),
    CompositeIndex('entityLocalId'),
  ])
  late int contextLocalId;

  /// One of the covered entity class names (data-model §2.6, FR-010).
  late String entityType;

  /// The row's Isar id within the context.
  late int entityLocalId;

  /// `upsert` or `delete` (a delete is a retained tombstone).
  late String op;

  /// Canonical serialized row (empty on delete) — produced by the entity's
  /// `SyncCodec` (`contracts/sync-protocol.md` §1).
  String payload = '';

  late int hlcMillis;

  late int hlcCounter;

  /// Stable per-install id (final HLC tiebreaker).
  late String deviceId;

  /// The signer's fingerprint (`Identity.fingerprint`), indexed so apply-time
  /// authorization can resolve the author cheaply (role-authorization §3).
  @Index()
  late String authorIdentityId;

  /// Base64 ed25519 over the canonical serialization of every field above
  /// except this one (`contracts/sync-protocol.md` §1).
  late String signature;

  late DateTime createdAt;
}
