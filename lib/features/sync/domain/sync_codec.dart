import 'dart:convert';

/// The canonical, lossless serializer for one covered entity type
/// (data-model §2.6, `contracts/sync-protocol.md` §5).
///
/// [toPayload] must be deterministic: the same entity always yields the same
/// string, so two devices compute the same bytes and the same HLC winner. The
/// canonical form sorts every map key, so key order in [toJson] is irrelevant.
abstract class SyncCodec<T> {
  const SyncCodec();

  /// One of the covered entity class names (data-model §2.6, FR-010).
  String get entityType;

  /// The entity as canonical-JSON primitives.
  Map<String, Object?> toJson(T value);

  /// Rebuilds the entity from [toJson] output.
  T fromJson(Map<String, Object?> json);

  /// The canonical string stored in `ChangeRecord.payload`.
  String toPayload(T value) => canonicalJsonEncode(toJson(value));

  /// Parses a `ChangeRecord.payload` back into an entity.
  T fromPayload(String payload) => fromJson(canonicalJsonDecode(payload));
}

/// Encodes [value] with every map key sorted, recursively — the canonical form
/// two devices must agree on.
String canonicalJsonEncode(Object? value) => jsonEncode(canonicalize(value));

/// Returns [value] with nested map keys sorted (list order is preserved).
Object? canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((k) => k.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: canonicalize(value[key])
    };
  }
  if (value is List) {
    return <Object?>[for (final item in value) canonicalize(item)];
  }
  return value;
}

/// Parses a canonical payload object.
Map<String, Object?> canonicalJsonDecode(String payload) =>
    (jsonDecode(payload) as Map).cast<String, Object?>();
