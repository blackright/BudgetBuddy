import 'package:uuid/uuid.dart';

/// A device-independent identity code for one shared record
/// (spec Key Entities → "Stable identity code (`syncGuid`)", research R5).
///
/// The code is a lowercase RFC-4122 version-4 UUID. It is generated once, when a
/// shared row is first created on a device, and never changes afterwards — so
/// two phones can agree which record a change is about even though each phone
/// stores that record under its **own** local row number.
///
/// Contract:
/// - **Stable** — assigned once. Migration step 17 backfills it for old rows and
///   nothing ever rewrites it.
/// - **Unique** — a random v4 UUID, so two devices cannot collide in practice.
/// - **Never reused** — a deleted row keeps its code on its tombstone; a brand
///   new row always gets a fresh code.
///
/// A v4 UUID needs unpredictable randomness, so this uses the `uuid` package
/// (already a project dependency, same as `identity_provider.dart`), which draws
/// from a cryptographically secure RNG.
String newSyncGuid() => const Uuid().v4();
