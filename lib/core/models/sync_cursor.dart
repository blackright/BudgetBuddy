import 'package:isar/isar.dart';

part 'sync_cursor.g.dart';

/// A per-peer exchange watermark (data-model §2.7, FR-013).
///
/// Records how far each direction has progressed so an interrupted or repeated
/// exchange resumes cleanly and never half-applies (sync-protocol §7). A
/// [conflictCount] surfaces losing changes rather than hiding them (FR-007).
@collection
class SyncCursor {
  Id id = Isar.autoIncrement;

  /// Links to `PairedPeer.id`.
  @Index(
      composite: [CompositeIndex('contextLocalId')],
      unique: true,
      replace: true)
  late int peerId;

  /// The `SharedSpace.id`.
  late int contextLocalId;

  int lastSentHlcMillis = 0;
  int lastSentCounter = 0;
  String lastSentDeviceId = '';

  int lastReceivedHlcMillis = 0;
  int lastReceivedCounter = 0;
  String lastReceivedDeviceId = '';

  /// How many incoming changes lost to the local head (surfaced, never silent).
  int conflictCount = 0;

  late DateTime updatedAt;
}
