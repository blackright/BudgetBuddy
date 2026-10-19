# Implementation Plan: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Branch**: `016-app-security` | **Date**: 2026-10-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/016-app-security/spec.md`

**Note**: This file is produced by `/speckit-plan`. It is the design; `/speckit-tasks` turns it into tasks.

## Summary

The app has exactly one lock today, and it is a gate rather than a lock. `AppLockGate`
(`lib/features/identity/presentation/app_lock_gate.dart:20-112`) decides **once**, when the identity and
consent streams first settle at a cold start, whether to ask for the phone's own PIN/biometrics
(`identityAsync.value != null && consentAsync.value?.deviceAuthGranted`, lines 73-78). A success releases
the identity private key from the keystore through `deviceKeySessionProvider`
(`lib/features/identity/providers/device_key_session.dart:55-112`), and everything downstream (sync,
pairing, people) reads that key without prompting again. There is no app PIN, no lockout, no away-time,
no per-subject setting, no way to re-arm the gate once it has decided, and no way for a space Owner to
require anything of a member.

Feature `016` turns that single cold-start gate into a real, per-subject lock:

1. a **PIN** per subject (a profile or a shared space) with a verifier that lives only in the OS secure
   storage (`SecretStore`, `lib/features/identity/repositories/secret_store.dart:9-13`), never beside the
   data - and the device's own authentication still gates the key at cold start (FR-048), so the PIN
   adds a factor rather than replacing one;
2. a **lockout** whose count and remaining wait survive force-quit, closure and a moved clock;
3. **biometrics** that re-unlock only inside a session the PIN already opened, reusing the single-prompt
   discipline already proven in `deviceKeySessionProvider`;
4. **lock behaviour** - cold start, away-time (five bounded choices, default 2 minutes), background/phone
   lock, subject switch, and on demand;
5. an **Owner requirement** for a shared space, carried between devices as a non-secret field on the space
   itself (the existing `SharedSpace` payload), enforced on each member's own device;
6. the **Settings surface** that manages all of it, including the plain statement of what forgetting the
   PIN means.

The at-rest guarantee - that a copy of the stored records is useless - is **not** delivered here. The
pinned storage engine (`isar 3.1.0+1`, and the maintained `isar_community` fork) exposes no encryption
API at all (research R0), so nothing in this feature makes the stored bytes unreadable. That half of the
original request, the key, and the reversible switch-over of existing data are delivered by
`017-encrypted-storage`, which depends on this feature.

## Technical Context

**Language/Version**: Dart / Flutter (SDK `>=3.0.0 <4.0.0`, `pubspec.yaml:8`); Kotlin for one small
platform channel (research R3).

**Primary Dependencies** (all already pinned - no new package is required):
- `flutter_riverpod ^2.4.3` - state and providers (`pubspec.yaml:21`)
- `local_auth ^3.0.2` - the device's own PIN/biometrics (`pubspec.yaml:31`)
- `flutter_secure_storage ^11.2.0` - the OS keystore seam (`pubspec.yaml:22`)
- `cryptography ^2.9.0` - PBKDF2-HMAC-SHA256 and constant-time comparison (`pubspec.yaml:13`)
- `isar ^3.1.0` + `isar_flutter_libs` - local rows (`pubspec.yaml:29-30`)
- `go_router ^18.0.2` - routing; the gate mounts in `MaterialApp.router`'s builder
  (`lib/main.dart:206-207`)

**Storage**: Isar 3.1 (`lib/core/database/isar_helper.dart:39-72`; 24 collections today, 25 once T009
registers `LockSetting`) for the non-secret
per-subject setting row; the OS secure storage for the PIN verifier, its salt and iteration count, and
the lockout state from `secretStoreProvider` (`lib/core/providers/identity_provider.dart:17-19`).
Schema version 18 today (`lib/core/database/schema_migrations.dart:21`).

**Testing**: `flutter test`; widget tests drive providers through `ProviderContainer` overrides with fake
seams (`test/features/identity/app_lock_gate_test.dart:75-102` is the pattern to follow). Current
baseline: 756 passing, 1 skipped.

**Target Platform**: Android first, iOS to follow - consistent with the constitution's Principle I. The
one native addition (R3) is Android-only, with a Dart fallback elsewhere.

**Project Type**: single Flutter application (mobile).

**Performance Goals**: unlock in under 300 ms after the user completes the prompt (FR-025, SC-004); the
PIN KDF must fit inside that budget (research R2).

**Constraints**: fully offline (SC-007 - no network in enrolment, verification or unlocking); at
most one OS prompt per unlock event (FR-021); no history of security events is kept (FR-046).

**Scale/Scope**: one app, a handful of subjects per device (profiles plus shared spaces); this feature
touches the lock path, the settings surface, one model + one sync codec, and `main.dart`'s lifecycle
observers.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | Why |
|---|---|---|
| I. Cross-Platform & Mobile First | PASS | Flutter throughout; the only native piece (R3, the monotonic clock) is a small Android channel with a Dart fallback, so iOS/web keep working. |
| II. Clean Architecture & Testability | PASS | The lock is a Riverpod notifier plus pure-Dart policies behind seams (`VerifierStore`, `MonotonicClock`, the existing `DeviceAuthenticator`/`SecretStore`); every rule is unit-testable without hardware (the pattern of `SpaceAccessGuard`, `lib/features/spaces/repositories/space_role_guard.dart:28-167`). |
| III. Offline-First & Synchronization | PASS | Nothing in the lock path uses the network; the one thing that travels is the non-secret space requirement on the existing `SharedSpace` payload. |
| IV. Modular Financial Logic & Real-time Availability | PASS | The feature touches no money math: no amount, seal, rate or total is read or written by the lock. The schema step is additive and rewrites no figure. |
| V. Security & Privacy First | PASS | Defence in depth. Clause 1 ("native phone PIN and biometrics like fingerprint/face") holds without amendment: the app PIN is an additional lock, and releasing a subject's key still requires the device's own authentication at every cold start (FR-048), so the app is gated by both. Clause 2 (sensitive data not visible until authenticated) is FR-023/FR-026. Clause 3 ("the design MUST account for future encryption") is specified and planned as `017-encrypted-storage`. |
| VI. Playful & Modern Design | PASS | Lock and PIN screens keep the app's Material 3 theming and dark mode; showing *nothing* behind the lock (FR-023) is the requirement, not a style regression. |

**Result**: all gates pass, with no violations to justify. Complexity Tracking records the five changes
that are not free.

## Project Structure

### Documentation (this feature)

```text
specs/016-app-security/
  spec.md                          # the lock spine (approved, trimmed 2026-10-18)
  plan.md                          # this file
  research.md                      # Phase 0: the decisions and their evidence
  data-model.md                    # Phase 1: entities, fields, state transitions
  contracts/                       # Phase 1: the interfaces this feature fixes
    lock-state-machine.md          #   states, triggers, what the lock shows
    pin-verifier-and-lockout.md    #   the verifier, the schedule, the clock defence
    space-access-requirement.md    #   the Owner's requirement and how it travels
    security-settings-ui.md        #   the Settings surface and its keys
  quickstart.md                    # Phase 1: how to prove it works end to end
  checklists/requirements.md       # spec quality gate
```

### Source Code (repository root)

```text
lib/features/security/                     # NEW - the lock module (Clean Architecture, as elsewhere)
  domain/                                  #   pure rules, no Isar, no Riverpod
    lock_subject.dart                      #     what a subject is (profile or space) + its stable key
    lock_state.dart                        #     the state machine's states and events
    monotonic_clock.dart                   #     the clock seam: `int nowMs()`, monotonic (R3)
    lockout_schedule.dart                  #     the FR-013 table, as a pure function
    weak_pins.dart                         #     the refused list (FR-010)
    pin_policy.dart                        #     4-8 digits, twice on set, current on change (FR-007, FR-009)
  repositories/
    pin_verifier_store.dart                #     seal/unseal a PIN verifier in the OS secure storage
    lockout_store.dart                     #     failure count + remaining wait, persisted
    lock_setting_repository.dart           #     read/stream/upsert the setting row (T011)
    monotonic_clock_impl.dart              #     the Android channel + the clamped wall-clock fallback (R3)
  providers/
    lock_providers.dart                    #     the notifier, per-subject setting, biometric availability
    lock_lifecycle_observer.dart           #     the third observer: away-time and the phone's own lock (R4)
  presentation/
    lock_keys.dart                         #     the widget keys the tests drive
    lock_screen.dart                       #     avatar + name + one Unlock action (FR-037)
    pin_screen.dart                        #     keypad, error, countdown, biometric option (FR-036)
    security_section.dart                  #     the Settings card (FR-035)
    security_settings_screen.dart          #     change PIN, biometrics, away-time, lockout status
    pin_setup_screen.dart                  #     enable/change with the warning (FR-009, FR-039)

lib/features/identity/presentation/app_lock_gate.dart   # EDIT - mount point; now consumes the lock state
lib/features/settings/presentation/settings_screen.dart # EDIT - add the Security section (the section list is lines 20-46; IdentitySection is at :27)
lib/features/spaces/presentation/space_settings_section.dart # EDIT - the Owner's requirement card, Owner only
lib/features/identity/repositories/device_authenticator.dart # EDIT - add an outcome-classifying call
lib/features/identity/repositories/local_auth_outcome.dart   # NEW - LocalAuthExceptionCode mapped to outcomes (R5)
lib/core/models/lock_setting.dart          # NEW - the per-subject setting row (Isar)
lib/core/models/shared_space.dart          # EDIT - three non-secret policy fields
lib/core/database/isar_helper.dart         # EDIT - register the new schema (lines 42-67)
lib/core/database/schema_migrations.dart   # EDIT - schemaVersion 18 -> 19, additive step
lib/features/sync/domain/codecs/shared_space_codec.dart # EDIT - carry the requirement
lib/features/sync/domain/entity_applier.dart            # no change needed (codec-decoded row rewrite)
lib/main.dart                              # EDIT - a lock lifecycle observer beside the seal/sync ones

android/app/src/main/kotlin/.../MainActivity.kt        # EDIT - the monotonic-clock channel (R3)

test/features/security/                    # NEW - domain tests, store tests, notifier tests, widget tests
test/features/spaces/space_policy_guard_test.dart       # NEW - a non-Owner's requirement write is refused (FR-027)
test/features/sync/shared_space_policy_codec_test.dart  # NEW - the three fields round-trip (FR-030)
test/features/identity/app_lock_gate_test.dart          # EDIT - keep the six existing cases green
```

**Structure decision**: a new `lib/features/security/` module rather than growing `lib/features/identity/`.
The identity module is 015's seam for the private key (create/unlock/wipe) and must stay untouched; the
lock is about *subjects and access*, and it is the same shape as the repo's other feature modules
(`domain/`, `repositories/`, `providers/`, `presentation/`). `AppLockGate` stays exactly where it is - it
is the widget `main.dart:207` mounts and six existing tests pump - but it becomes a consumer of the new
lock state instead of a one-shot decision.

## Complexity Tracking

| Change | Why it is needed | What keeps it honest |
|---|---|---|
| New Isar collection `LockSetting`, schema 18 -> 19 | The setting is per subject (FR-032) and must survive restarts | Additive only, exactly like step 16 (`schema_migrations.dart:250-260`): Isar materialises the new columns with their defaults and the step rewrites no money figure |
| `SharedSpace` gains three fields | The Owner's requirement must reach every member (FR-027/FR-030) | Only the non-secret requirement travels; no PIN, verifier or key is in the payload (FR-030). The codec decodes missing fields to "no requirement", so an older peer is not broken by the new payload |
| `DeviceAuthenticator` grows an outcome-classifying call | FR-019 needs to tell "cancelled" from "not enrolled" (`LocalAuthExceptionCode`, `local_auth_platform_interface`) | The existing `authenticate()` keeps its signature and its existing cases in `test/features/identity/app_lock_gate_test.dart`; the new call is additive |
| Android platform channel for a monotonic clock (R3) | FR-015 (a moved clock must not shorten a wait) cannot be met with the wall clock alone | One method, one value; a Dart fallback for platforms without it, and the fallback's limit is written down in R3 rather than hidden |
| Cold start keeps the device's own authentication as well as the app PIN (FR-048) | Principle V requires access to be secured by native device authentication, so the app PIN must not become the sole gate to the key | One system prompt per cold start; the in-session biometric shortcut is unchanged, and the lock adds no prompt of its own (FR-021) |

No constitution violation is being justified here: every row above is scope, not a shortcut.

## Phasing

Phase 0 and Phase 1 below produce the design artifacts. Implementation then follows the spec's own order:
the lock spine lands before `017` begins, because `017` depends on the PIN that releases its key.

## Phase 0: Outline & Research

Unknowns carried into research, all resolved in [research.md](./research.md):

- **R0** - whether the pinned storage engine can encrypt at rest (it cannot; this is why the feature was
  split and why `017` exists).
- **R1** - where the per-subject setting and the lockout state live.
- **R2** - how the PIN is verified: KDF choice, salt, iteration count, comparison, and fitting the 300 ms
  budget.
- **R3** - how FR-015 is actually satisfied when the user moves the clock.
- **R4** - how the lock observes "away" and the phone's own lock, given the observers already in
  `main.dart`.
- **R5** - how biometric outcomes are classified without changing 015's seam.
- **R6** - how the Owner's requirement travels and who may author it.

## Phase 1: Design & Contracts

- [data-model.md](./data-model.md) - the `LockSetting` entity, the `SharedSpace` additions, the lock
  state machine, the lockout schedule, and the validation rules each field carries.
- [contracts/lock-state-machine.md](./contracts/lock-state-machine.md)
- [contracts/pin-verifier-and-lockout.md](./contracts/pin-verifier-and-lockout.md)
- [contracts/space-access-requirement.md](./contracts/space-access-requirement.md)
- [contracts/security-settings-ui.md](./contracts/security-settings-ui.md)
- [quickstart.md](./quickstart.md) - the runnable proof, on one device and on two phones.

### Re-evaluated Constitution Check (post-design)

Unchanged: all six principles still pass. The design added no money-path contact, no network use, and no
new package. The one native surface is the Android clock channel, recorded above.
