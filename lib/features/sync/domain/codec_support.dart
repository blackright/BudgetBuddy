/// Shared helpers for the per-entity [SyncCodec]s (data-model §2.6).
///
/// Payloads are canonical JSON built from `int` / `double` / `String` / `bool` /
/// `null` / `List` / `Map` only, so a `toPayload`→`fromPayload` round-trip is
/// lossless and money fields stay byte-identical (FR-010). Dates travel as UTC
/// milliseconds and enums as their [Enum.name], both stable across devices.
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

/// Resolves an enum member by its [Enum.name], falling back to the first member
/// for an unknown value so a payload from a newer peer never crashes a reader.
T decodeEnum<T extends Enum>(List<T> values, Object? name) =>
    values.firstWhere((e) => e.name == name, orElse: () => values.first);

int _asInt(Object? value) => (value as num).toInt();
