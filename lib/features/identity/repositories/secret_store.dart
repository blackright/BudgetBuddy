import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A minimal key/value secret store, so the private identity key never touches
/// Isar (data-model §2.1, research R1).
///
/// Production uses [FlutterSecureStorageSecretStore] (Android Keystore / iOS
/// Keychain). Tests use [InMemorySecretStore] so no hardware/keystore is
/// required.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// The real keystore-backed store.
class FlutterSecureStorageSecretStore implements SecretStore {
  const FlutterSecureStorageSecretStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// An in-memory store for tests (and for a stable device id in unit tests).
class InMemorySecretStore implements SecretStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
