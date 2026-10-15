import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../features/identity/repositories/consent_service.dart';
import '../../features/identity/repositories/device_authenticator.dart';
import '../../features/identity/repositories/identity_service.dart';
import '../../features/identity/repositories/secret_store.dart';
import '../database/isar_helper.dart';
import '../models/consent_record.dart';
import '../models/identity.dart';

/// Storage key for the stable per-install id (HLC tiebreaker, data-model §1.3).
const String kDeviceIdKey = 'sync_device_id';

/// The keystore-backed secret store (private key, device id).
final secretStoreProvider = Provider<SecretStore>(
  (ref) => const FlutterSecureStorageSecretStore(),
);

/// The device PIN/biometrics seam (FR-002).
final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>(
  (ref) => LocalAuthDeviceAuthenticator(),
);

/// The identity service: create, unlock, wipe (FR-001/014).
final identityServiceProvider = Provider<IdentityService>(
  (ref) => IdentityService(
    IsarHelper.instance,
    ref.watch(secretStoreProvider),
    deviceAuth: ref.watch(deviceAuthenticatorProvider),
  ),
);

/// The consent service: record/revoke device-auth consent (FR-002).
final consentServiceProvider = Provider<ConsentService>(
  (ref) => ConsentService(IsarHelper.instance),
);

/// The single local identity, or `null` before onboarding.
final identityProvider = StreamProvider<Identity?>((ref) {
  final isar = IsarHelper.instance;
  return isar.identitys.where().watch(fireImmediately: true).map(
        (rows) => rows.isEmpty ? null : rows.first,
      );
});

/// The single consent row, or `null` before the first decision.
final consentProvider = StreamProvider<ConsentRecord?>((ref) {
  final isar = IsarHelper.instance;
  return isar.consentRecords.where().watch(fireImmediately: true).map(
        (rows) => rows.isEmpty ? null : rows.first,
      );
});

/// Whether optional device auth is currently enabled (warning-only when off).
final deviceAuthEnabledProvider = Provider<bool>(
  (ref) => ref.watch(consentProvider).valueOrNull?.deviceAuthGranted ?? false,
);

/// A stable per-install id, generated once and kept in the secret store
/// (data-model §1.3). Used as the final HLC tiebreaker.
final deviceIdProvider = FutureProvider<String>((ref) async {
  final store = ref.watch(secretStoreProvider);
  final existing = await store.read(kDeviceIdKey);
  if (existing != null && existing.isNotEmpty) return existing;
  final created = const Uuid().v4();
  await store.write(kDeviceIdKey, created);
  return created;
});
