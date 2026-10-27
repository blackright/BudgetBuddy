import '../../identity/providers/device_auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/lock_setting.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/identity_provider.dart';
import '../../identity/providers/device_key_session.dart';
import '../domain/away_time.dart';
import '../domain/lock_state.dart';
import '../domain/lock_subject.dart';
import '../domain/monotonic_clock.dart';
import '../domain/pin_policy.dart';
import '../domain/pin_result.dart';
import '../repositories/lock_setting_repository.dart';
import '../repositories/lock_settings_store.dart';
import '../repositories/lockout_store.dart';
import '../repositories/monotonic_clock_impl.dart';
import '../repositories/pin_verifier_store.dart';

/// The non-secret setting store, or `null` when no database is open.
///
/// A `null` here is what makes the whole lock chain inert in a widget test and
/// in any code path that runs before `IsarHelper.init()`: "no database" and
/// "no lock" behave identically, which is exactly the 015 behaviour the six
/// `app_lock_gate_test.dart` cases pin (T015).
///
/// The seam is the [LockSettingsStore] interface, not the Isar-backed
/// [LockSettingRepository], so a widget test can drive the card with an
/// in-memory double: a live Isar cannot run inside `testWidgets`' fake-async
/// zone (see `test/features/security/support/in_memory_lock_settings_store.dart`).
final lockSettingRepositoryProvider = Provider<LockSettingsStore?>((ref) {
  final isar = IsarHelper.maybeInstance;
  return isar == null ? null : LockSettingRepository(isar);
});

/// The key-derivation function behind the PIN verifier (research R2/R2b).
///
/// Production uses PBKDF2; the tests override it with a fast, deterministic fake
/// so the unlock path can be exercised without paying the KDF's deliberate cost.
final pinKdfProvider = Provider<PinKdf>((ref) => const Pbkdf2PinKdf());

/// The PIN verifier store, reading and writing the OS secure storage (FR-008).
final pinVerifierStoreProvider = Provider<PinVerifierStore>(
  (ref) => PinVerifierStore(
    ref.watch(secretStoreProvider),
    kdf: ref.watch(pinKdfProvider),
  ),
);

/// The persisted lockout store, reading and writing the OS secure storage
/// (FR-013, FR-014).
final lockoutStoreProvider = Provider<LockoutStore>(
  (ref) => LockoutStore(ref.watch(secretStoreProvider)),
);

/// The subject the app is acting as right now — the active shared space, else
/// the active personal profile — or `null` when there is none (data-model §1).
final lockSubjectProvider = Provider<LockSubject?>((ref) {
  if (IsarHelper.maybeInstance == null) return null;

  final space = ref.watch(activeSpaceProvider).valueOrNull;
  if (space != null) {
    return LockSubject.space(
      localId: space.id,
      syncGuid: space.syncGuid,
      name: space.displayName,
      avatar: space.avatar,
    );
  }

  final profile = ref.watch(activeProfileProvider).valueOrNull;
  if (profile == null) return null;
  return LockSubject.profile(
    id: profile.id,
    name: profile.name,
    avatar: profile.avatar,
  );
});

/// The active subject's setting row, or `null` when its lock was never
/// configured (the opt-in case, spec assumption).
final activeLockSettingProvider = StreamProvider<LockSetting?>((ref) {
  final subject = ref.watch(lockSubjectProvider);
  final repository = ref.watch(lockSettingRepositoryProvider);
  if (subject == null || repository == null) return Stream.value(null);
  return repository.watch(subject.key);
});

/// Whether **any** lock exists on this device, read **synchronously**.
///
/// The lock's subject is derived from the active-space and active-profile
/// *streams*, so on the first frame after `runApp` the app cannot yet say whose
/// lock applies. This is the piece that can still answer, because `main.dart`
/// awaits `IsarHelper.init()` before `runApp`; the two `countSync` calls are the
/// whole point of the provider. It is `false` without a database, so it never
/// changes what a test with no Isar sees.
///
/// It is not a lock in its own right — nothing may be *unlocked* on the strength
/// of it (FR-034: an orphan setting protects nothing). It only decides whether
/// the gate may paint content before the subject is known.
final anyLockConfiguredProvider = Provider<bool>((ref) {
  final isar = IsarHelper.maybeInstance;
  if (isar == null) return false;

  // Re-read whenever a subject's own setting or a space's policy changes, so the
  // answer cannot go stale while the app is open.
  ref.watch(activeLockSettingProvider);
  ref.watch(activeSpaceProvider);

  final ownerRequiresPin =
      isar.sharedSpaces.filter().requirePinEqualTo(true).build().countSync() >
          0;
  if (ownerRequiresPin) return true;

  return isar.lockSettings
          .filter()
          .lockEnabledEqualTo(true)
          .build()
          .countSync() >
      0;
});

/// Whether the gate must hide its content because a lock is configured but the
/// app cannot yet say **whose** (FR-023).
///
/// Fails closed for the resolving window only. Once both streams that name the
/// subject have answered, the answer is definitive and this is `false` for good —
/// otherwise an orphaned setting could hold the app shut with no way in, which
/// would contradict FR-034 rather than serve FR-023.
final lockResolutionPendingProvider = Provider<bool>((ref) {
  if (IsarHelper.maybeInstance == null) return false;
  if (!ref.watch(anyLockConfiguredProvider)) return false;

  return !ref.watch(activeSpaceProvider).hasValue ||
      !ref.watch(activeProfileProvider).hasValue;
});

/// The setting that actually applies to the active subject.
///
/// For a personal profile this is simply its own row. For a shared space it is
/// the Owner's requirement composed with the member's own, stricter choice
/// (FR-028, data-model §4, contracts §3):
///
/// * the lock is required if the Owner requires a PIN **or** the member turned
///   their own lock on;
/// * biometrics are forbidden outright when the Owner forbids them;
/// * the away-time is the **shorter** of the two when the Owner set one, and the
///   member's own value when the Owner set none — never a hidden default.
class EffectiveLock {
  const EffectiveLock({
    required this.subject,
    required this.lockRequired,
    required this.forbidBiometrics,
    required this.memberBiometricsEnabled,
    required this.awayTime,
  });

  final LockSubject subject;

  /// Whether this subject must be unlocked before its content may be shown.
  final bool lockRequired;

  /// The Owner forbids the in-session biometric shortcut for this space.
  final bool forbidBiometrics;

  /// The member's own biometric choice (only meaningful when not forbidden).
  final bool memberBiometricsEnabled;

  /// The away-time that applies, already composed.
  final AwayTime awayTime;
}

/// Whether this device can satisfy a biometric / device-credential prompt at
/// all (FR-017): supported **and** at least one biometric enrolled.
final deviceBiometricsAvailableProvider = FutureProvider<bool>((ref) async {
  final auth = ref.read(deviceAuthenticatorProvider);
  if (!await auth.isAvailable()) return false;
  return auth.isEnrolled();
});

final effectiveLockProvider = Provider<EffectiveLock?>((ref) {
  final subject = ref.watch(lockSubjectProvider);
  if (subject == null) return null;

  final setting = ref.watch(activeLockSettingProvider).valueOrNull;
  final space = ref.watch(activeSpaceProvider).valueOrNull;

  final ownerRequiresPin = space?.requirePin ?? false;
  final ownerForbidsBiometrics = space?.forbidBiometrics ?? false;
  final ownerAwayTime = space?.awayTime;

  final memberAwayTime = setting?.awayTime ?? AwayTime.twoMinutes;

  // The shortcut is no longer a member preference: it is on whenever the phone
  // itself can satisfy it. The Owner's forbid still overrides it.
  final deviceAvailable =
      ref.watch(deviceBiometricsAvailableProvider).valueOrNull ?? false;

  return EffectiveLock(
    subject: subject,
    lockRequired: ownerRequiresPin || (setting?.lockEnabled ?? false),
    forbidBiometrics: ownerForbidsBiometrics,
    memberBiometricsEnabled: deviceAvailable,
    awayTime: ownerAwayTime == null
        ? memberAwayTime
        : AwayTime.stricter(ownerAwayTime, memberAwayTime),
  );
});

/// What the gate and the security screens read.
///
/// A snapshot with no [subject] means this feature is not gating anything right
/// now: the app behaves exactly as it did before 016 (opt-in, spec assumption).
class LockSnapshot {
  const LockSnapshot({
    this.subject,
    this.state = LockState.unlocked,
    this.effective,
    this.failCount = 0,
    this.waitUntilMs,
  });

  final LockSubject? subject;

  final LockState state;

  /// The composed setting, when a subject is present.
  final EffectiveLock? effective;

  /// The consecutive PIN failures since the last success (FR-013).
  final int failCount;

  /// The monotonic reading at which the current wait ends, or `null` when no
  /// wait is running (FR-014, research R3).
  final int? waitUntilMs;

  /// Whether any subject is gated by this feature at all.
  bool get isProtected => subject != null;

  /// Whether the app must be showing its lock rather than its content.
  bool get isLocked => isProtected && state != LockState.unlocked;

  /// Whether the in-session biometric shortcut may be offered. The device check
  /// is folded in by the settings surface, not here.
  bool get biometricsAllowed =>
      (effective?.memberBiometricsEnabled ?? false) &&
      !(effective?.forbidBiometrics ?? false);

  /// The remaining wait at [nowMs], or `null` when none is running.
  Duration? remainingWait(int nowMs) {
    final until = waitUntilMs;
    if (until == null) return null;
    final left = until - nowMs;
    return left <= 0 ? Duration.zero : Duration(milliseconds: left);
  }
}

/// The lock's live state for the active subject (data-model §5).
final lockControllerProvider =
    NotifierProvider<LockController, LockSnapshot>(LockController.new);

/// Holds the session's lock state and drives the state machine
/// (`contracts/lock-state-machine.md`).
///
/// The state is **never persisted** and always starts `locked` for a protected
/// subject, so there is no stored "unlocked" flag to tamper with. Dropping the
/// released key is deliberately *not* done here: the gate keeps doing it in a
/// post-frame callback (the `_lockWhenShut` discipline), because a provider must
/// never be written during a build pass.
class LockController extends Notifier<LockSnapshot> {
  LockSubject? _subject;
  int _operationGeneration = 0;
  bool _alive = false;
  String? _activeKey;
  LockState _state = LockState.locked;

  /// The monotonic reading at which the app left the foreground, or `null` when
  /// it is foregrounded (the away window, FR-022).
  int? _awaySinceMs;

  /// Whether the phone's own screen lock engaged while the app was open.
  ///
  /// When this is true, [noteResumed] re-locks unconditionally — the phone's
  /// lock is a stronger signal than the away-time, so unlocking the phone
  /// always requires the app's PIN/biometric regardless of how long it was
  /// locked (FR-022, "when the phone is locked").
  bool _phoneWasLocked = false;

  /// The consecutive PIN failures since the last success (FR-013). Mirrors the
  /// persisted lockout record; it is never the source of truth, only a cache the
  /// UI reads so the countdown does not wait on an async read every frame.
  int _failCount = 0;

  /// The monotonic reading at which the current wait ends, or `null` (FR-014).
  int? _waitUntilMs;

  /// The key of a subject whose PIN was *just* set by the user in this session,
  /// or `null` (FR-009).
  ///
  /// Setting the PIN is the moment the lock is born: the row arrives a frame
  /// later, `build()` sees a subject it has never seen, and "protected means
  /// locked" would demand the PIN the user typed seconds ago a *third* time
  /// (once to set it, once to confirm it). The mark makes that one entry keep
  /// the state the session already had, and nothing else: it is consumed by the
  /// first `build()` that sees the subject, exact-key, so any later
  /// `subjectSwitched`, `explicitLock`, `returnedAfterAwayTime` or cold start
  /// still locks normally. It skips a spurious lock; it never opens one.
  String? _justConfiguredKey;

  @override
  LockSnapshot build() {
    _alive = true;
    _activeKey = ref.read(lockSubjectProvider)?.key;
    ref.onDispose(() {
      _alive = false;
      _operationGeneration++;
    });
    ref.listen(lockSubjectProvider, (previous, next) {
      if (_activeKey != next?.key) {
        _activeKey = next?.key;
        _operationGeneration++;
      }
    });
    ref.listen(effectiveLockProvider, (previous, next) {
      if (_alive) state = _reconcile(next);
    });
    return _reconcile(ref.read(effectiveLockProvider));
  }

  LockSnapshot _reconcile(EffectiveLock? effective) {
    if (effective == null || !effective.lockRequired) {
      if (_subject != null) _operationGeneration++;
      _subject = null;
      _state = LockState.unlocked;
      _awaySinceMs = null;
      _failCount = 0;
      _waitUntilMs = null;
      _justConfiguredKey = null;
      return const LockSnapshot();
    }

    // A subject that is entered (including every cold start) starts locked
    // (FR-022, FR-032). Re-entering the *same* subject keeps the session's
    // state, so a settings change does not slam the lock in the user's face.
    if (_subject?.key != effective.subject.key) {
      _operationGeneration++;
      final justConfigured = _justConfiguredKey == effective.subject.key;
      _justConfiguredKey = null;
      _subject = effective.subject;
      // The user is already past the PIN — they only just chose it — so this
      // entry keeps the open state rather than treating itself as a cold start.
      if (!justConfigured) {
        _state = LockState.locked;
      }
      _awaySinceMs = null;
      _failCount = 0;
      _waitUntilMs = null;
    }

    return _snapshot(effective);
  }

  LockSnapshot _snapshot(EffectiveLock effective) => LockSnapshot(
        subject: effective.subject,
        state: _state,
        effective: effective,
        failCount: _failCount,
        waitUntilMs: _waitUntilMs,
      );

  bool _validOperation(int generation, String key) =>
      _alive && generation == _operationGeneration && _activeKey == key;

  void _applyEvent(LockEvent event) =>
      _transition(ref.read(effectiveLockProvider), event);

  /// The reducer step shared by the synchronous events and the asynchronous PIN
  /// paths. The async callers pass [effective] in because a notifier's `ref`
  /// must not be read after an `await` (see [_checkPin]).
  void _transition(EffectiveLock? effective, LockEvent event) {
    if (effective == null || !effective.lockRequired) return;
    _state = reduceLockState(_state, event);
    state = _snapshot(effective);
  }

  /// Re-reads the persisted lockout for the active subject (FR-014, FR-036).
  ///
  /// A cold start rebuilds this controller with no memory, so the wait that
  /// survived a force-quit would otherwise be invisible until the first attempt.
  /// The lock screen calls this once it is mounted; the read is asynchronous
  /// because it goes through the OS secure storage.
  Future<void> refreshLockout() async {
    final subject = _subject;
    if (subject == null) return;
    final operation = _operationGeneration;
    final effective = ref.read(effectiveLockProvider);
    if (effective == null || !effective.lockRequired) return;

    final nowMs = ref.read(monotonicClockProvider).nowMs();
    final status =
        await ref.read(lockoutStoreProvider).status(subject.key, nowMs: nowMs);
    if (!_validOperation(operation, subject.key)) return;
    _failCount = status.failCount;
    _waitUntilMs =
        status.isWaiting ? nowMs + status.remaining.inMilliseconds : null;
    state = _snapshot(effective);
  }

  /// The user asked to unlock: show the PIN screen.
  void beginUnlock() => _applyEvent(LockEvent.unlockRequested);

  /// A correct PIN or a successful in-session biometric.
  void markUnlocked(LockEvent event) => _applyEvent(event);

  /// The subject failed or cancelled; it stays locked (FR-026).
  void markRejected(LockEvent event) => _applyEvent(event);

  /// On-demand lock (FR-022).
  void lockNow() {
    _operationGeneration++;
    // Drop the key first, before the state write triggers a rebuild.
    ref.read(deviceKeySessionProvider.notifier).lock();
    _applyEvent(LockEvent.explicitLock);
  }

  /// The app left the foreground: start the away window. `inactive` never
  /// reaches here (contracts §4, R4).
  void noteLeftForeground() {
    _awaySinceMs ??= ref.read(monotonicClockProvider).nowMs();
  }

  /// The phone's own screen lock, which the OS reports as leaving the
  /// foreground.
  void notePhoneLocked() {
    _phoneWasLocked = true;
    noteLeftForeground();
  }

  /// The app came back: relock if it was away longer than the subject's
  /// away-time (FR-022).
  void noteResumed() {
    final since = _awaySinceMs;
    _awaySinceMs = null;
    final effective = ref.read(effectiveLockProvider);
    if (since == null || effective == null || !effective.lockRequired) {
      _phoneWasLocked = false;
      return;
    }
    if (_state != LockState.unlocked) {
      _phoneWasLocked = false;
      return;
    }

    final phoneLocked = _phoneWasLocked;
    _phoneWasLocked = false;

    if (phoneLocked) {
      _applyEvent(LockEvent.returnedAfterAwayTime);
      return;
    }

    final away = ref.read(monotonicClockProvider).nowMs() - since;
    if (away >= effective.awayTime.window.inMilliseconds) {
      _applyEvent(LockEvent.returnedAfterAwayTime);
    }
  }

  /// Checks [pin] against [subject]'s verifier, applying the lockout schedule
  /// (FR-011, FR-013).
  ///
  /// Every dependency is passed in rather than read here: a notifier's `ref`
  /// must not be used after an `await`, because a dependency change during the
  /// await would leave the element outdated until its next `build`. This is the
  /// same discipline `DeviceKeySession._authenticate` follows.
  ///
  /// Returns [PinResult.accepted] on a match — deliberately **without**
  /// clearing the record, because an accepted PIN is not the same as a
  /// completed unlock: [submitPin] still has to pass FR-048's second factor
  /// before the record may be cleared. A mismatch is recorded and returns
  /// [PinResult.wrongPin]; a wait in progress returns [PinResult.lockedOut]
  /// without touching the verifier.
  Future<PinResult> _checkPin(
    LockSubject subject,
    String pin, {
    required EffectiveLock? effective,
    required MonotonicClock clock,
    required LockoutStore lockout,
    required PinVerifierStore verifiers,
  }) async {
    final operation = _operationGeneration;
    final status = await lockout.status(subject.key, nowMs: clock.nowMs());
    if (!_validOperation(operation, subject.key)) {
      return PinResult.deviceRefused;
    }
    _failCount = status.failCount;
    if (status.isWaiting) {
      _waitUntilMs = clock.nowMs() + status.remaining.inMilliseconds;
      _publish(effective);
      return PinResult.lockedOut;
    }
    _waitUntilMs = null;

    final matches = await verifiers.verify(subject.key, pin);
    if (!_validOperation(operation, subject.key)) {
      return PinResult.deviceRefused;
    }
    if (matches) return PinResult.accepted;

    final after =
        await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
    if (!_validOperation(operation, subject.key)) {
      return PinResult.deviceRefused;
    }
    _failCount = after.failCount;
    _waitUntilMs =
        after.isWaiting ? clock.nowMs() + after.remaining.inMilliseconds : null;
    _state = reduceLockState(_state, LockEvent.pinRejected);
    _publish(effective);
    return PinResult.wrongPin;
  }

  void _publish(EffectiveLock? effective) {
    if (effective == null || !_alive) return;
    state = _snapshot(effective);
  }

  /// A PIN submitted from the lock screen (FR-011, FR-048).
  ///
  /// A match is only the first factor: the session key is released through the
  /// one prompt [DeviceKeySession] owns, so a cold start costs one PIN plus at
  /// most one system prompt (FR-021) and a declined prompt leaves the app
  /// locked (FR-048). Nothing here shows a prompt of its own.
  Future<PinResult> submitPin(String pin) async {
    final subject = _subject;
    if (subject == null) return PinResult.notConfigured;

    // Every seam is read before the first `await` (see `_checkPin`).
    final clock = ref.read(monotonicClockProvider);
    final lockout = ref.read(lockoutStoreProvider);
    final verifiers = ref.read(pinVerifierStoreProvider);
    final session = ref.read(deviceKeySessionProvider.notifier);
    final effective = ref.read(effectiveLockProvider);

    final binding = ref.read(nativeAccessBindingProvider);
    final native = ref.read(deviceAuthSessionProvider.notifier);
    final epoch = _operationGeneration, authEpoch = native.generation;
    bool current() =>
        _validOperation(epoch, subject.key) && native.isCurrent(authEpoch);
    final result = await _checkPin(subject, pin,
        effective: effective,
        clock: clock,
        lockout: lockout,
        verifiers: verifiers);
    if (result != PinResult.accepted) return result;
    if (!current() || !binding.resolved || binding.key != subject.key) {
      return PinResult.deviceRefused;
    }
    final verified = binding.identity == null &&
            !binding.isShared &&
            subject.kind == LockSubjectKind.profile
        ? await native.require(reason: 'Unlock BudgetBuddy')
        : await session.require(reason: 'Unlock BudgetBuddy') != null;
    if (!verified || !current()) return PinResult.deviceRefused;
    await lockout.clear(subject.key);
    if (!current()) return PinResult.deviceRefused;
    _failCount = 0;
    _waitUntilMs = null;
    _transition(effective, LockEvent.pinAccepted);
    return PinResult.accepted;
  }

  /// Sets (or replaces) the active subject's PIN and turns its lock on
  /// (FR-009). The verifier is written first, so an enabled lock can never be
  /// left with no way in.
  ///
  /// The lock itself is not forced here: writing the setting row makes
  /// [effectiveLockProvider] recompute, and [build] then starts the subject
  /// locked (FR-022) — one place decides "protected means locked", race-free.
  Future<void> enableLock(String pin) async {
    final subject = _subject ?? ref.read(lockSubjectProvider);
    if (subject == null) {
      throw StateError('No subject is active; there is nothing to lock.');
    }

    // The screen already refused a weak or short PIN, but this is the last
    // point before a verifier is written, so the policy is enforced here too.
    final problem = PinPolicy.inspect(pin);
    if (problem != null) throw ArgumentError(PinPolicy.message(problem));

    final store = ref.read(lockSettingRepositoryProvider);
    if (store == null) {
      throw StateError('No database is open; the lock cannot be enabled.');
    }
    final verifiers = ref.read(pinVerifierStoreProvider);
    final lockout = ref.read(lockoutStoreProvider);

    final binding = ref.read(nativeAccessBindingProvider);
    final native = ref.read(deviceAuthSessionProvider.notifier);
    if (!binding.resolved || binding.key != subject.key) {
      throw StateError('Wait for the exact profile protection to resolve.');
    }
    final existing = await store.find(subject.key);
    final hasVerifier = await verifiers.isSet(subject.key);
    if (hasVerifier || existing?.lockEnabled == true) {
      throw StateError(
          'Existing or incomplete PIN protection needs review; use its existing change/recovery flow.');
    }
    if (!await native.require(
        reason: 'Verify phone security before enabling the app PIN',
        force: true)) {
      throw StateError(
          'Phone verification did not succeed. The new PIN was not enabled.');
    }
    final authEpoch = native.generation, operation = _operationGeneration;
    bool current() =>
        _validOperation(operation, subject.key) && native.isCurrent(authEpoch);
    if (!current()) {
      throw StateError('The active profile changed. Retry enrollment.');
    }
    await verifiers.setPin(subject.key, pin);
    if (!current()) {
      throw StateError(
          "Enrollment was interrupted. Review this profile protection before retrying.");
    }
    await lockout.clear(subject.key);

    final row =
        await store.find(subject.key) ?? LockSetting.forSubject(subject);
    if (!current()) {
      throw StateError("The active profile changed. Review saved protection.");
    }
    row.lockEnabled = true;
    // Ask for the PIN once, not three times: this mark tells the next `build()`
    // that the user is already past the PIN they just chose (FR-009).
    _justConfiguredKey = subject.key;
    await store.upsert(row);
  }

  /// Replaces the PIN after checking the current one (FR-009, FR-012). Only the
  /// `sec_pin_<key>` record is touched, so a change carries no data risk.
  Future<PinResult> changePin(String currentPin, String newPin) async {
    final subject = _subject ?? ref.read(lockSubjectProvider);
    if (subject == null) return PinResult.notConfigured;

    final problem = PinPolicy.inspect(newPin);
    if (problem != null) throw ArgumentError(PinPolicy.message(problem));

    final effective = ref.read(effectiveLockProvider);
    final clock = ref.read(monotonicClockProvider);
    final lockout = ref.read(lockoutStoreProvider);
    final verifiers = ref.read(pinVerifierStoreProvider);

    final result = await _checkPin(
      subject,
      currentPin,
      effective: effective,
      clock: clock,
      lockout: lockout,
      verifiers: verifiers,
    );
    if (result != PinResult.accepted) return result;

    await verifiers.setPin(subject.key, newPin);
    await lockout.clear(subject.key);
    _failCount = 0;
    _waitUntilMs = null;
    return PinResult.accepted;
  }

  /// Resets the active subject's PIN without checking the current one (FR-045).
  ///
  /// Used for forgotten-PIN recovery: another subject on the same phone must be
  /// unlocked first (the caller verifies this by checking that the session key
  /// is present). Keeps every record; only the verifier and lockout state are
  /// replaced. Sets the `_justConfiguredKey` mark so the subject does not
  /// immediately re-lock.
  Future<void> resetPin(String newPin) async {
    final subject = _subject ?? ref.read(lockSubjectProvider);
    if (subject == null) {
      throw StateError('No subject is active; there is nothing to reset.');
    }

    final problem = PinPolicy.inspect(newPin);
    if (problem != null) {
      throw ArgumentError(PinPolicy.message(problem));
    }

    final store = ref.read(lockSettingRepositoryProvider);
    if (store == null) {
      throw StateError('No database is open; the PIN cannot be reset.');
    }

    final verifiers = ref.read(pinVerifierStoreProvider);
    final lockout = ref.read(lockoutStoreProvider);

    await verifiers.setPin(subject.key, newPin);
    await lockout.clear(subject.key);

    final row =
        await store.find(subject.key) ?? LockSetting.forSubject(subject);
    row.lockEnabled = true;
    row.updatedAt = DateTime.now();
    await store.upsert(row);

    _justConfiguredKey = subject.key;
    _failCount = 0;
    _waitUntilMs = null;
  }

  /// Records the user's own away-time for the active subject (FR-033).
  ///
  /// This writes the *member's* value, never the Owner's: in a shared space the
  /// two compose at read time by "the stricter wins" (`AwayTime.stricter`), so a
  /// member who picks a longer window than the Owner asked for is answered with
  /// the Owner's shorter one regardless. The setting is non-secret and needs no
  /// PIN — the worst a wrong value can do is lock the app sooner.
  Future<void> setAwayTime(AwayTime awayTime) async {
    final subject = _subject ?? ref.read(lockSubjectProvider);
    if (subject == null) {
      throw StateError('No subject is active; there is nothing to set.');
    }

    final store = ref.read(lockSettingRepositoryProvider);
    if (store == null) {
      throw StateError('No database is open; the away-time cannot be saved.');
    }

    final row =
        await store.find(subject.key) ?? LockSetting.forSubject(subject);
    row.awayTime = awayTime;
    row.updatedAt = DateTime.now();
    await store.upsert(row);
  }

  /// Turns the lock off, but only for a caller who knows the current PIN
  /// (FR-009). The verifier is deleted outright — a stored record with no way
  /// to check it would be dead weight.
  Future<PinResult> disableLock(String pin) async {
    final subject = _subject ?? ref.read(lockSubjectProvider);
    if (subject == null) return PinResult.notConfigured;

    final effective = ref.read(effectiveLockProvider);
    final clock = ref.read(monotonicClockProvider);
    final lockout = ref.read(lockoutStoreProvider);
    final verifiers = ref.read(pinVerifierStoreProvider);
    final store = ref.read(lockSettingRepositoryProvider);

    final result = await _checkPin(
      subject,
      pin,
      effective: effective,
      clock: clock,
      lockout: lockout,
      verifiers: verifiers,
    );
    if (result != PinResult.accepted) return result;

    await verifiers.delete(subject.key);
    await lockout.clear(subject.key);

    final row = await store?.find(subject.key);
    if (row != null) {
      row.lockEnabled = false;
      row.biometricsEnabled = false;
      await store?.upsert(row);
    }

    _failCount = 0;
    _waitUntilMs = null;
    return PinResult.accepted;
  }
}
