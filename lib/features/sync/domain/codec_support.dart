/// Shared helpers for the per-entity [SyncCodec]s (data-model §2.6).
///
/// Payloads are canonical JSON built from `int` / `double` / `String` / `bool` /
/// `null` / `List` / `Map` only. Money fields stay byte-identical (FR-010), and
/// dates travel as UTC milliseconds and enums as their [Enum.name], both stable
/// across devices.
///
/// **Identity (015)**: a payload carries the row's own `syncGuid` and refers to
/// other rows by GUID, never by a local integer `Id` (`entity-identity.md` §2).
/// A codec is pure, so it cannot look a reference up — it leaves the numeric
/// foreign keys out entirely, the `SyncRecorder` injects the GUID references
/// when it has a database, and the applier resolves them back to local ids at
/// apply time. Every scalar (money, dates, enums) still round-trips losslessly.
library;

/// A `DateTime` encoded as UTC milliseconds, or `null`.
int? encodeDate(DateTime? value) => value?.toUtc().millisecondsSinceEpoch;

/// Decodes [value] as a UTC `DateTime`, or `null` when absent.
DateTime? decodeDate(Object? value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(_asInt(value), isUtc: true);

/// Decodes [value] as a `DateTime`, falling back to the epoch sentinel.
DateTime decodeDateRequired(Object? value) =>
    decodeDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

/// Reads an integral value.
int decodeInt(Object? value) => _asInt(value);

/// Reads a double value (accepts an integral JSON number too).
double decodeDouble(Object? value) => (value as num).toDouble();

/// Reads an optional integral value.
int? decodeIntOrNull(Object? value) => value == null ? null : _asInt(value);

/// Reads an optional double value.
double? decodeDoubleOrNull(Object? value) =>
    value == null ? null : (value as num).toDouble();

/// Reads the device-independent identity (`syncGuid`).
///
/// A missing value yields the empty string, which never matches a real GUID, so
/// the engine can treat the record as malformed (`entity-identity.md` §8).
String decodeGuid(Object? value) => value as String? ?? '';

/// Reads a GUID **reference**, or `null` when absent/empty.
///
/// An absent reference is legal on the wire: the target may not exist on this
/// device yet (it may arrive later), and the applier leaves the local field
/// unset rather than inventing a value (`entity-identity.md` §4 R2).
String? decodeGuidOrNull(Object? value) {
  final guid = value as String?;
  return guid == null || guid.isEmpty ? null : guid;
}

/// Resolves an enum member by its [Enum.name], falling back to the first member
/// for an unknown value so a payload from a newer peer never crashes a reader.
T decodeEnum<T extends Enum>(List<T> values, Object? name) =>
    values.firstWhere((e) => e.name == name, orElse: () => values.first);

int _asInt(Object? value) => (value as num).toInt();
