# Phase 0 Research: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Feature**: 016-app-security | **Date**: 2026-10-18
**Status**: All unknowns resolved. No NEEDS CLARIFICATION remain.

Source-of-truth codebase facts verified on 2026-10-18 against `lib/`, `test/`, `pubspec.yaml` and the
packages actually locked in the pub cache. File:line is cited for every claim.

---

## Starting facts (verified - these are what the feature is built on)

- The only lock today is a cold-start gate. `AppLockGate`
  (`lib/features/identity/presentation/app_lock_gate.dart:20-112`) decides once, when the identity and
  consent streams first settle (lines 73-78), and never re-decides. It paints a lock screen, releases the
  identity key on success, and otherwise leaves the app untouched.
- The released key lives in `deviceKeySessionProvider`
  (`lib/features/identity/providers/device_key_session.dart:55-112`): one in-flight prompt, a failure is
  never remembered, and an unlocked key is free for later callers. `lock()` (lines 83-86) drops it. This
  is the single-prompt discipline FR-021 asks for, already proven on device (the T073 regression note,
  lines 30-54).
- The keystore seam is `SecretStore` (`lib/features/identity/repositories/secret_store.dart:9-13`) with a
  real `FlutterSecureStorageSecretStore` (lines 16-32) and an `InMemorySecretStore` for tests. It stores
  the identity seed under `identity_private_key` (`identity_service.dart:27,58`) and the device id under
  `sync_device_id` (`identity_provider.dart:14`).
- The biometric seam is `DeviceAuthenticator`
  (`lib/features/identity/repositories/device_authenticator.dart:5-11`). The real implementation calls
  `_auth.authenticate(biometricOnly: false, persistAcrossBackgrounding: true)` inside a `try` that maps
  **every** exception to `false` (lines 33-43), so a cancel is indistinguishable from a device that has no
  enrolment.
- `local_auth 3.0.2` reports failures as `LocalAuthException` with a `LocalAuthExceptionCode`
  (`local_auth_platform_interface/src/types/auth_exception.dart`), which includes `userCanceled`,
  `timeout`, `systemCanceled`, `noCredentialsSet`, `noBiometricsEnrolled`, `noBiometricHardware`,
  `temporaryLockout`, `biometricLockout`, `userRequestedFallback` and `deviceError`. The seam above throws
  all of that away.
- `cryptography 2.9.0` (already pinned, `pubspec.yaml:13`) provides `Pbkdf2`
  (`algorithms.dart:1505`), `Argon2id` (`algorithms.dart:502`), `Hmac` (`algorithms.dart:1377`) and
  `constantTimeBytesEquality` (`constant_time_equality.dart:25`).
- Local rows go through one storage path: `IsarHelper.init()`
  (`lib/core/database/isar_helper.dart:39-72`) opens 24 collections today (25 once this feature registers
  `LockSetting`, T009) and runs the migrations
  (`schema_migrations.dart`), at `schemaVersion = 18` (`schema_migrations.dart:21`). Adding a field is
  additive: Isar materialises the new column with its declared default, and the migration step is a
  documented no-op - exactly what step 16 did for `UserProfile.confirmSharedSave`
  (`schema_migrations.dart:250-260`).
- Settings is a plain `ListView` of section widgets (`settings_screen.dart:20-46`; `IdentitySection` is at
  `:27`, right after `SpaceSettingsSection` at `:25`), each a small
  ConsumerWidget card (e.g. `identity_section.dart:14-180`) - the pattern the Security section follows.
- A shared space is an Isar row (`lib/core/models/shared_space.dart:15-56`) with `syncGuid`, `name`,
  `avatar`, `currency`, `defaultIncome`, `createdByProfileId`, `createdAt`. It travels as a payload
  (`shared_space_codec.dart:7-33`) and is applied by `SharedSpaceApplier`
  (`entity_applier.dart:81-101`), which finds the local row by `syncGuid` and rewrites it.
- Who may write a space is already decided in one place: `SpaceAccessGuard`
  (`lib/features/spaces/repositories/space_role_guard.dart:28-167`). `canManage` is Owner-only (lines
  43-44), and the applier-time rule refuses a non-Owner `SharedSpace` write (lines 132-137).
- The lifecycle pattern already exists twice: `_SealLifecycleObserver` and `_SyncLifecycleObserver`
  (`main.dart:57-141`). Both are `WidgetsBindingObserver`s registered after `runApp`, both treat
  `inactive` as transient (lines 136-138), and the sync one stops the exchange whenever the app is not
  foregrounded. The gate mounts in the router's builder (`main.dart:206-207`).

---

## R0 - The pinned storage engine cannot encrypt at rest

**Decision**: The at-rest guarantee is **not** delivered by this feature. `016` is the lock; the key, the
unreadable-at-rest property, and the reversible switch-over of existing data are delivered by
`017-encrypted-storage`, whose own planning phase selects the storage approach.

**Rationale**: the plan assumed the local store could be opened with a key. It cannot:

- `isar 3.1.0+1` (the locked version, `pubspec.yaml:29-30`) contains **no occurrence of the string
  `encrypt`** anywhere - not in `lib/`, not in `CHANGELOG.md`, not in `README.md`.
- `Isar.open(...)` (`lib/src/isar.dart:107`) calls `openIsar({schemas, directory, name, maxSizeMiB,
  relaxedDurability, compactOnLaunch})` (`lib/src/native/open.dart:73-80`). There is no key parameter and
  the native instance is created without one.
- The maintained fork `isar_community 3.4.1` publishes `Isar.open` with the **same** parameter list - no
  `encryptionKey` (pub.dev API reference, checked 2026-10-18). So this is not "we pinned an old version".
- `IsarHelper.init()` therefore opens all 24 collections in the clear today (25 once this feature registers
  `LockSetting`, T009) (`isar_helper.dart:41-69`), and the
  only cryptography anywhere in `lib/` is the LAN transport's TLS
  (`lib/features/sync/transport/lan_transport.dart:25`).

**Alternatives considered**:

- *Pass an encryption key to the store* - impossible; the API does not exist in either package.
- *Encrypt sensitive fields by hand* - breaks the indexed queries, sums, sorts and seals the money math
  depends on, and would spread the single source of truth (constitution IV) across call sites. Rejected.
- *Swap the engine now (SQLCipher via drift/sqflite, or ObjectBox with a box key)* - the only route to
  true page-level AES-256, but it means rewriting 24 collections (25 once this feature registers
  `LockSetting`), nineteen migration steps, every repository,
  the sync codecs and roughly fifty test harnesses. That is its own feature with its own risk profile,
  and it is exactly the decision `017` begins with. Rejected for `016`.

**Consequence**: the split is recorded in the spec's scope note, in the checklist, and in the report to
the owner on 2026-10-18. The requirement numbers that moved stay reserved in `016` so the split is
traceable.

---

## R1 - Where the lock's state lives

**Decision**: the non-secret per-subject setting is a new Isar collection `LockSetting`, one row per
subject. The PIN verifier (salt + iterations + derived verifier) and the lockout state (failure count +
remaining wait) live in the OS secure storage under subject-scoped keys.

**Rationale**: FR-008 requires the verifier to live in the device's secure storage, never beside the data
it protects and never in the data store. The setting around it - lock on/off, biometrics on/off,
away-time, and the status the Settings screen renders - is not secret and must be streamed and queried
like every other row, so Isar is the right home for it (and the app already has exactly one storage path,
which the sync and integrity work depends on). The lockout count, by contrast, is a tamper target: it must
survive force-quit and closure (FR-014), and putting it in the clear would let a rooted device reset it
trivially, so it goes to the secure storage with the verifier.

**Keys**: `sec_pin_<subjectKey>` and `sec_lockout_<subjectKey>`. The subject key is `p<profileId>` for a
profile and `s<spaceSyncGuid>` for a shared space. The space key uses the **syncGuid**, not the local
Isar id, because the local id is not stable across a restore while the guid is.

**Alternatives considered**: the whole setting in the secure storage (cannot be streamed, moves the lock
outside the app's single storage path); the verifier in Isar (violates FR-008 outright); the lockout in
Isar (a rooted device resets the counter, and FR-014's whole point is that nothing resets it).

---

## R2 - How the PIN is verified

**Decision**: PBKDF2-HMAC-SHA256 with a 256-bit output, a fresh 16-byte random salt per subject, and an
iteration count calibrated at the moment the PIN is set to a target that keeps the whole unlock inside the
300 ms budget (FR-025/SC-004). Salt, iteration count and verifier are stored together in the secure
storage; comparison is by `constantTimeBytesEquality`.

**Rationale**: `Pbkdf2` and a constant-time comparator are already available in a pinned, pure-Dart
package, so the choice adds no dependency and no native surface. Storing the iteration count beside the
verifier means the cost can be raised on a future device without a data migration. The verifier never
leaves the keystore, so the KDF is a second line behind the hardware and the lockout (R3/FR-013) is the
first.

**Alternatives considered**:

- *Argon2id* (also available, `algorithms.dart:502`) - memory-hard and stronger against an offline
  attacker who somehow extracts the verifier, but pure-Dart Argon2id is slow with an unpredictable cost on
  low-end hardware, which fights the 300 ms budget (FR-025 and SC-004 are both hard requirements). Kept as
  a recorded alternative: if a measurement shows the budget is comfortable, Argon2id is the better KDF.
- *A plain hash* - far too cheap, and the 4-8 digit space (10,000 values at the short end) means the KDF
  cost matters.
- *Storing the PIN itself* - forbidden by FR-008 and FR-042.

**Honest note**: a 4-digit PIN has only 10,000 values, so no KDF makes an offline attack expensive on its
own. This is precisely why the lockout schedule is a hard requirement and why the verifier is kept in
hardware-protected storage.

---

## R2b - Fitting the unlock budget

**Decision**: the KDF iteration count is calibrated **when the PIN is set** to the highest value that
keeps the derivation under 150 ms on that device, with a floor that is never lowered below a documented
minimum; the target and the measured time are recorded so SC-004 can be measured with the real KDF in the
loop.

**Rationale**: the same APK runs on hardware whose speed varies by an order of magnitude; a fixed count
either misses the budget on a slow phone or under-protects on a fast one. Calibrating once at set time,
storing the result, and measuring the real unlock path keeps FR-025 and SC-004 meaningful rather than
aspirational.

---

## R3 - The clock

**Decision**: a `MonotonicClock` seam. On Android it is backed by `SystemClock.elapsedRealtime()` through a
one-method platform channel; on any platform without it, the wall clock is used, clamped so it can never
run backwards.

**Rationale**: FR-015 is a hard requirement, and the wall clock cannot satisfy it. It cannot tell "the app
was closed for ten minutes" from "the user moved the clock forward ten minutes", so a wall-clock lockout
is escaped by moving the clock forward. `elapsedRealtime()` counts real elapsed time since boot
(including sleep) and is immune to clock changes. Boot detection needs no extra source: if the monotonic
value read now is *smaller* than the value stored when the lockout was applied, the device rebooted, and
the remaining wait is re-imposed in full from that point - the safe direction. The absolute wall-clock
deadline stays only as a fallback for the platforms without the monotonic source.

**Alternatives considered**:

- *Freeze the countdown while the app is not foregrounded* - needs no native code and satisfies FR-015
  completely, but a 60-minute wait becomes 60 minutes of watching a countdown, which fights FR-014's
  intent and the spec's own "a lockout is a wait, not a trap" assumption. Rejected as the primary design.
- *Trust the wall clock* - fails FR-015 outright.
- *A trusted network time source* - forbidden by SC-007 (offline).

**Honest limit recorded**: the monotonic source is Android-only for now. On a platform without it the
fallback uses the wall clock with the backwards clamp, so a forward clock move can end that wait early
there; the failure count is never reset, so the escalating schedule still applies. Android - the platform
this feature ships on - is fully covered.

---

## R4 - Away-time and the phone's own lock

**Decision**: one `LockLifecycleObserver` in `main.dart`, modelled on the two observers already there
(`main.dart:57-141`, registered after `runApp`). It records a timestamp when the app leaves `resumed` and
re-evaluates the subject's away-time on `resumed`; `inactive` is treated as transient, exactly as the sync
observer does (lines 136-138).

**Rationale**: the pattern, the registration order and the plugin-safety rule (nothing blocks startup) are
already settled in this codebase; a third observer of the same shape is the least surprising design. The
away-time is compared against the monotonic clock (R3) so backgrounding cannot be gamed either.
`inactive` is what Android sends for the app switcher and an incoming call - locking there would be
hostile and is not what "put the phone down" means.

**Alternatives considered**: a widget-level observer inside the gate - the gate is mounted inside the
router builder (`main.dart:206-207`) and is rebuilt as the router changes, so an app-lifetime observer is
both simpler and able to drop the session key when the app is backgrounded.

---

## R5 - Biometric outcomes (FR-017, FR-019, FR-021)

**Decision**: add an outcome-classifying call to the biometric seam that catches `LocalAuthException` and
maps `LocalAuthExceptionCode` to a small result enum (unlocked / cancelled / unavailable / notEnrolled /
temporarily-locked-out / error). The existing `authenticate()` keeps its signature and its callers.

**Rationale**: the settings screen must offer biometrics only when the device supports it *and* an
enrolment exists (FR-017), and a cancel or an error must never be counted as a wrong PIN or dead-end the
user (FR-019). The current seam returns a bare `bool` and swallows every exception
(`device_authenticator.dart:33-43`), so neither requirement can be honoured today. The exception taxonomy
needed is already published by `local_auth_platform_interface`.

**Alternatives considered**: change `authenticate()` to return the enum - it ripples into 015's pairing and
gate call sites and their tests for no benefit; `isAvailable()` / `isDeviceSupported()` alone - answers
"capable", not "enrolled", so FR-017 could not be honoured.

---

## R6 - How the Owner's requirement travels

**Decision**: three non-secret fields on `SharedSpace` (`requirePin`, `forbidBiometrics`, and a nullable
`awayTime` - `null` means the Owner set no away-time requirement), authored only by the Owner, carried in
the existing `SharedSpace` payload, applied by
the existing `SharedSpaceApplier`. `forbidBiometrics` is named for its effect: `true` suppresses the
biometric shortcut for the space; it never *requires* a biometric, which no device can be made to have.

**Rationale**: the requirement must reach every member (FR-030) and is non-secret by definition, so the
space row is its natural carrier; the applier already rewrites the row by `syncGuid`
(`entity_applier.dart:81-101`), and who may author it is already decided in one place - `canManage` is
Owner-only (`space_role_guard.dart:43-44`) and the applier-time rule refuses a non-Owner `SharedSpace`
write (lines 132-137), which is exactly FR-027/FR-028. Adding fields is additive (R1's schema note): Isar
materialises the defaults and the codec decodes missing keys to "no requirement", so a member running an
older build is not broken by a newer payload.

**Alternatives considered**: a new synced `SpaceSecurityPolicy` entity - a codec, an applier, a migration
step and its own versioning for three fields; attaching the requirement to the invite only - breaks the
moment the Owner changes their mind after the members have joined.

---

## Summary of decisions

| # | Decision | Requirement it serves |
|---|---|---|
| R0 | At-rest split out to `017`; the engine cannot encrypt | scope honesty |
| R1 | Setting in Isar, verifier + lockout in the OS secure storage | FR-008, FR-014, FR-032 |
| R2 | PBKDF2-HMAC-SHA256, per-subject salt, stored iterations, constant-time compare | FR-008, FR-010, FR-025 |
| R2b | Iterations calibrated at set time to the 300 ms budget | FR-025, SC-004 |
| R3 | Monotonic clock (Android channel) + no-backwards wall fallback | FR-014, FR-015 |
| R4 | A third lifecycle observer beside the seal/sync ones | FR-022, FR-023 |
| R5 | Classified biometric outcomes via `LocalAuthExceptionCode` | FR-017, FR-019, FR-021 || R6 | Policy fields on `SharedSpace`, Owner-authored, codec-carried | FR-027, FR-030 |
