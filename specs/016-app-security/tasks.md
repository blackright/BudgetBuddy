# Tasks: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Feature**: 016-app-security | **Branch**: `016-app-security` | **Date**: 2026-10-18

**Input**: Design documents from `/specs/016-app-security/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: included, and written first. This project's practice is test-first (the medical work in 011 and
the sync work in 015 both followed it), and `quickstart.md` §2 says "write these first and watch them
fail". Test tasks come before implementation inside every story.

**Organization**: tasks are grouped by user story so each story is independently implementable and
testable. Story numbers match `spec.md` (US1 = PIN and lockout, US2 = biometrics, US3 = lock behaviour,
US4 = the Owner's requirement, US5 = settings and honesty).

## Path conventions

- Source: `lib/features/security/` (new module), with the existing files it edits named in full.
- Tests mirror the module they exercise: the new lock tests live in `test/features/security/`, and the two
  that extend existing modules stay beside them (`test/features/spaces/space_policy_guard_test.dart`,
  `test/features/sync/shared_space_policy_codec_test.dart`).
- One native file: `android/app/src/main/kotlin/com/example/budget_buddy/MainActivity.kt`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: create the module and the shared test scaffolding.

- [ ] T001 Create the security module tree `lib/features/security/{domain,repositories,providers,presentation}/` and the test mirror `test/features/security/{support}/` per [plan.md](./plan.md) §Project Structure
- [ ] T002 [P] Add the widget-key constants from [contracts/security-settings-ui.md](./contracts/security-settings-ui.md) §6 in `lib/features/security/presentation/lock_keys.dart`
- [ ] T003 [P] Record the pre-change baseline by running `flutter test` and `flutter analyze`, writing the counts into `specs/016-app-security/quickstart.md` §1

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: the subject model, the clock, the setting collection and the state machine. No story can be
implemented before this is done.

**CRITICAL**: no user story work can begin until this phase is complete.

- [ ] T004 [P] Implement `LockSubject` (profile/space, `p<id>` / `s<guid>` subject keys) in `lib/features/security/domain/lock_subject.dart` per [data-model.md](./data-model.md) §1, with unit tests in `test/features/security/lock_subject_test.dart`
- [ ] T005 [P] Define `LockState` and the machine's events in `lib/features/security/domain/lock_state.dart` per [data-model.md](./data-model.md) §5 and [contracts/lock-state-machine.md](./contracts/lock-state-machine.md) §2
- [ ] T006 [P] Define the `MonotonicClock` seam (`int nowMs()`) and its provider in `lib/features/security/domain/monotonic_clock.dart` per research R3
- [ ] T007 Add the Android monotonic source: `SystemClock.elapsedRealtime()` on a method channel in `android/app/src/main/kotlin/com/example/budget_buddy/MainActivity.kt`, with `MethodChannelMonotonicClock` and the clamped wall-clock fallback in `lib/features/security/repositories/monotonic_clock_impl.dart`
- [ ] T008 [P] Create the `LockSetting` Isar collection in `lib/core/models/lock_setting.dart` per [data-model.md](./data-model.md) §2 (fields, defaults, unique `subjectKey` index)
- [ ] T009 Register `LockSetting` in `lib/core/database/isar_helper.dart` and add migration step 19, bumping `schemaVersion` to 19, in `lib/core/database/schema_migrations.dart` per [data-model.md](./data-model.md) §4
- [ ] T010 [P] Add the migration test in `test/features/security/schema_migration_19_test.dart`, asserting existing rows (money, seals, rates, memberships) survive and the new defaults apply
- [ ] T011 [P] Implement `LockSettingRepository` (read/stream/upsert one row per subject) in `lib/features/security/repositories/lock_setting_repository.dart` and expose `lockSettingProvider`
- [ ] T012 [P] Cascade a subject's security setting on removal: delete the `LockSetting` row and `SecretStore.delete('sec_pin_<subjectKey>')` / `delete('sec_lockout_<subjectKey>')` from the profile deletion path (`lib/features/settings/presentation/profile_switcher_section.dart:157`) and the space paths (`lib/features/spaces/repositories/spaces_repository.dart:229` deleteSpace, `:434` leaveSpace), with the cascade test in `test/features/security/lock_setting_cascade_test.dart` (FR-034)
- [ ] T013 [P] Assert the lock ignores an orphan setting: a `LockSetting` whose subject no longer exists is treated as unprotected and is never read by the lock, in `test/features/security/orphan_setting_test.dart` (FR-034, data-model.md §1)
- [ ] T014 Implement `LockController` (the per-subject notifier) and its providers in `lib/features/security/providers/lock_providers.dart`, with the state machine from T005 and the away-window hooks stubbed
- [ ] T015 Rework `lib/features/identity/presentation/app_lock_gate.dart` to consume `LockController` while keeping today's behaviour byte-for-byte when no lock exists (the six cases in `test/features/identity/app_lock_gate_test.dart` must pass untouched)
- [ ] T016 [P] Add the shared test doubles in `test/features/security/support/`: an in-memory `SecretStore`, a stepping fake `MonotonicClock`, and a fake `DeviceAuthenticator` per [contracts/pin-verifier-and-lockout.md](./contracts/pin-verifier-and-lockout.md) §8
- [ ] T017 Verify the rework in T015 by running `flutter test test/features/identity/` and confirming zero behaviour change

**Checkpoint**: foundation ready - every story can now start.

---

## Phase 3: User Story 1 - My PIN is the way in, and guessing is punished (Priority: P1) - MVP

**Goal**: a 4-8 digit PIN per subject, a verifier that lives only in the OS secure storage, and a lockout
whose count and wait survive force-quit and a moved clock. Cold start costs the PIN plus one system
prompt, so the device's own authentication still gates the key (FR-048).

**Independent test**: set a PIN, fail it repeatedly with the app closed in between, and confirm the exact
wait, the visible countdown, and that no reopen or clock change shortens it.

### Tests for User Story 1 - write first, watch them fail

- [ ] T018 [P] [US1] Weak-PIN rules test in `test/features/security/weak_pin_test.dart` (all-identical, runs, the weak list, and a normal PIN accepted) for FR-010
- [ ] T019 [P] [US1] PIN set/verify test in `test/features/security/pin_verifier_test.dart`: match unlocks and clears the record, mismatch increments, and a PIN change touches no other record (FR-011, FR-012)
- [ ] T020 [P] [US1] Lockout schedule test in `test/features/security/lockout_schedule_test.dart` pinning boundaries 4/5, 9/10 and the 60-minute cap (FR-013)
- [ ] T021 [P] [US1] Lockout persistence and clock test in `test/features/security/lockout_store_test.dart`: survives a restart, a backwards clock does not shorten, a reboot re-imposes the wait, the count is untouched, a lockout on one subject leaves another subject usable, and ten force-quit/reopen cycles never shorten the wait (FR-014, FR-015, FR-016, SC-005)
- [ ] T022 [P] [US1] PIN screen widget test in `test/features/security/pin_screen_test.dart`: keypad, error line, disabled keypad plus countdown while locked out (FR-036)
- [ ] T023 [P] [US1] PIN setup widget test in `test/features/security/pin_setup_test.dart`: entered twice, mismatch refused, and the forgotten-PIN warning shown before acceptance (FR-009, FR-039)
- [ ] T024 [P] [US1] Cold-start two-factor test in `test/features/security/cold_start_two_factor_test.dart`: across ten cold starts a correct PIN is followed by exactly one system prompt, the app is not usable before it succeeds, no second prompt is shown for the same event, and no cold start is openable by the biometric alone (FR-021, FR-048, SC-011)

### Implementation for User Story 1

- [ ] T025 [P] [US1] Add the weak-PIN list and the checker in `lib/features/security/domain/weak_pins.dart` (FR-010)
- [ ] T026 [P] [US1] Add the PIN policy (4-8 digits, twice on set, current on change) in `lib/features/security/domain/pin_policy.dart` (FR-007, FR-009)
- [ ] T027 [US1] Implement `PinVerifierStore` (PBKDF2-HMAC-SHA256, per-subject salt, calibrated iterations, constant-time compare) in `lib/features/security/repositories/pin_verifier_store.dart` per research R2/R2b
- [ ] T028 [P] [US1] Implement the pure `LockoutSchedule.waitFor(int failCount)` in `lib/features/security/domain/lockout_schedule.dart` (FR-013)
- [ ] T029 [US1] Implement `LockoutStore` (count + wait persisted through `SecretStore`, monotonic baseline, reboot detection) in `lib/features/security/repositories/lockout_store.dart` (FR-014, FR-015)
- [ ] T030 [US1] Wire PIN set/change/verify and the lockout into `LockController` in `lib/features/security/providers/lock_providers.dart`, clearing the record on success (FR-011, FR-016)
- [ ] T031 [US1] Enforce FR-048 on the unlock path in `lib/features/security/providers/lock_providers.dart`: after a PIN match, release the key only through `deviceKeySessionProvider.notifier.require(reason:)` so the device's own authentication is the second factor, keep the write out of the build pass as `AppLockGate._lockWhenShut` already does, and add no prompt of the app's own (FR-021, FR-048)
- [ ] T032 [US1] Build the lock screen (`lock_screen.dart`): subject avatar and name plus one Unlock action, nothing else (FR-023, FR-037)
- [ ] T033 [US1] Build the PIN screen `lib/features/security/presentation/pin_screen.dart` with the keypad, error line, countdown and disabled state (FR-036)
- [ ] T034 [US1] Build the PIN setup/change screen `lib/features/security/presentation/pin_setup_screen.dart` including the mandatory warning from [contracts/security-settings-ui.md](./contracts/security-settings-ui.md) §3 (FR-039)

**Checkpoint**: US1 is independently testable - a PIN locks the app and guessing is punished.

---

## Phase 4: User Story 2 - My face or finger is enough (Priority: P2)

**Goal**: the device's own biometric re-unlocks the app inside a session the PIN already opened, and never
on its own from a cold start; a cancel costs nothing.

**Independent test**: turn biometrics on, cancel the prompt, fail it, and confirm nothing was counted and
the PIN path is available; then cold-start and confirm the biometric cannot open the app alone.

### Tests for User Story 2 - write first, watch them fail

- [ ] T035 [P] [US2] Classified-outcome unit test in `test/features/security/biometric_outcome_test.dart`, mapping `LocalAuthExceptionCode` values to outcomes per research R5
- [ ] T036 [P] [US2] Biometric unlock widget test in `test/features/security/biometric_unlock_test.dart`: a cancel records no failure, a cold start still demands the PIN, and one prompt per event (FR-018, FR-019, FR-021)
- [ ] T037 [P] [US2] Biometric availability test in `test/features/security/biometric_availability_test.dart`: not offered on an unsupported or unenrolled device, and the reason is stated (FR-017)

### Implementation for User Story 2

- [ ] T038 [US2] Extend `lib/features/identity/repositories/device_authenticator.dart` with an outcome-classifying call, leaving the existing `authenticate()` signature and call sites intact
- [ ] T039 [P] [US2] Map `LocalAuthExceptionCode` to the outcome enum in `lib/features/identity/repositories/local_auth_outcome.dart` (new file; `local_auth_platform_interface` types)
- [ ] T040 [US2] Add the biometric availability provider (supported plus enrolled) in `lib/features/security/providers/lock_providers.dart` (FR-017)
- [ ] T041 [US2] Add the biometric path to `lib/features/security/presentation/pin_screen.dart`, enforcing that it can never satisfy FR-048 on its own and allowing one prompt per event (FR-018, FR-021)

**Checkpoint**: US1 and US2 both work independently.

---

## Phase 5: User Story 3 - It locks itself when I put the phone down (Priority: P2)

**Goal**: the app re-arms at cold start, after the away-time, when the phone is locked or the app is put
in the background, when the user switches to another profile or shared space, and on demand.

**Independent test**: set the away-time, background the app for just under and just over it, lock the
phone while the app is open, and switch between two profiles - confirming the state in each case.

### Tests for User Story 3 - write first, watch them fail

- [ ] T042 [P] [US3] Away-time transition test in `test/features/security/away_time_test.dart` for the five bounded choices and the 2-minute default (FR-022, FR-033)
- [ ] T043 [P] [US3] Lifecycle observer test in `test/features/security/lock_lifecycle_observer_test.dart`: `inactive` does not start the window, `paused`/`hidden` do, and returning after the away-time locks (FR-022)
- [ ] T044 [P] [US3] Subject switch test in `test/features/security/subject_switch_test.dart`: leaving a subject locks it, entering a protected subject asks for its own unlock, re-selecting the same profile is a no-op, and an unprotected subject never prompts (FR-022, FR-032)
- [ ] T045 [P] [US3] Session-key test in `test/features/security/lock_drops_session_key_test.dart`: locking drops the released key and no code path can read it while locked (FR-024)

### Implementation for User Story 3

- [ ] T046 [US3] Implement `LockLifecycleObserver` in `lib/features/security/providers/lock_lifecycle_observer.dart`, modelled on the seal/sync observers (`lib/main.dart`), with the away window measured on `MonotonicClock`
- [ ] T047 [US3] Register the observer in `lib/main.dart` alongside the existing two, after the first frame
- [ ] T048 [US3] Enforce the away-time in `lib/features/security/providers/lock_providers.dart` (compare on `MonotonicClock`, no wall-clock dependence) (FR-022)
- [ ] T049 [US3] Lock the departed subject and gate the arriving one in the subject switching path (`lib/core/providers/active_profile_provider.dart` and `lib/core/providers/active_space_provider.dart` consumers) (FR-032, FR-022)
- [ ] T050 [US3] Add the explicit lock action to `lib/features/security/presentation/lock_screen.dart` and wire it to `LockController`, which drops the released key through `deviceKeySessionProvider.notifier.lock()` so locking really removes the material from memory (FR-022, FR-024)
- [ ] T051 [US3] Enforce the locked-presentation rule in `lib/features/security/presentation/lock_screen.dart`: no figure, list row or deep-link target behind the lock (FR-023)

**Checkpoint**: US1, US2 and US3 work independently.

---

## Phase 6: User Story 4 - An Owner can require a lock for a shared space (Priority: P2)

**Goal**: an Owner requires a PIN and (optionally) forbids the biometric shortcut for a space; every member
is answered on their own device; nothing secret crosses.

**Independent test**: as Owner set the requirement, as member confirm it is enforced and cannot be switched
off, then confirm nothing secret crossed.

### Tests for User Story 4 - write first, watch them fail

- [ ] T052 [P] [US4] Codec test in `test/features/sync/shared_space_policy_codec_test.dart`: the three fields round-trip, and a payload lacking them decodes to "no requirement" (FR-030)
- [ ] T053 [P] [US4] Authoring test in `test/features/spaces/space_policy_guard_test.dart`: a non-Owner's write is refused by `SpaceAccessGuard` (FR-027, FR-028)
- [ ] T054 [P] [US4] Composition test in `test/features/security/space_policy_composition_test.dart`: the effective away-time is the shorter of the two when the Owner set one, the member's own choice stands when the Owner left it unset, a member cannot weaken the requirement, and the member satisfies it with their own PIN - never the Owner's (FR-028, FR-029)
- [ ] T055 [P] [US4] No-secrets-in-transit test in `test/features/security/space_policy_payload_test.dart`: the payload contains no PIN, verifier, salt or key material (FR-030)
- [ ] T056 [P] [US4] Forbidden-biometrics test in `test/features/security/space_forbid_biometrics_test.dart`: when the Owner forbids the shortcut, only the member's PIN is accepted for that space and the member's biometric switch cannot turn it back on (FR-020, FR-027, FR-028)

### Implementation for User Story 4

- [ ] T057 [US4] Add `requirePin`, `forbidBiometrics` and a nullable `awayTime` to `lib/core/models/shared_space.dart` per [data-model.md](./data-model.md) §4 (`awayTime == null` means the Owner set none)
- [ ] T058 [US4] Extend `lib/features/sync/domain/codecs/shared_space_codec.dart` to carry the three fields, decoding missing keys to "no requirement" and a missing `awayTime` to `null`
- [ ] T059 [US4] Compose the effective setting (Owner requirement plus the member's stricter choice) in `lib/features/security/providers/lock_providers.dart` (FR-028)
- [ ] T060 [US4] Add the Owner card to `lib/features/spaces/presentation/space_settings_section.dart`, read-only for a member (FR-027, FR-028)
- [ ] T061 [US4] Add the explain-and-offer-PIN path in `lib/features/security/presentation/lock_screen.dart` for a member who cannot meet the requirement (FR-031)

**Checkpoint**: US1, US2, US3 and US4 work independently.

---

## Phase 7: User Story 5 - Managing it, and being told what forgetting the PIN means (Priority: P3)

**Goal**: the Settings surface that manages the lock, the biometrics, the away-time and the lockout status,
and the plain statement of what forgetting the PIN means.

**Independent test**: walk the security settings, fail the PIN to see the countdown, change the PIN, turn
the lock off, and confirm the warning appears before a PIN is ever accepted.

### Tests for User Story 5 - write first, watch them fail

- [ ] T062 [P] [US5] Security section widget test in `test/features/security/security_section_test.dart`: state, biometric state, away-time and lockout status are visible and changeable, and turning the lock off without the current PIN is refused (FR-009, FR-035)
- [ ] T063 [P] [US5] Recovery test in `test/features/security/pin_recovery_test.dart`: another unlocked subject resets the PIN and keeps every record; with nothing able to unlock, the clean start warns first and the wording never implies anything survives an uninstall (FR-039, FR-045)
- [ ] T064 [P] [US5] Away-time options test in `test/features/security/away_time_options_test.dart`: exactly the five choices, no "never" (FR-033, SC-013)

### Implementation for User Story 5

- [ ] T065 [US5] Build `lib/features/security/presentation/security_section.dart` (lock switch, biometric switch, away-time, lockout status, change PIN)
- [ ] T066 [US5] Build `lib/features/security/presentation/security_settings_screen.dart` for the deeper flows (change PIN, biometrics, the reset path)
- [ ] T067 [US5] Add `SecuritySection` to `lib/features/settings/presentation/settings_screen.dart` after `IdentitySection`
- [ ] T068 [US5] Implement the five-choice away-time control with no "never" option in `lib/features/security/presentation/security_settings_screen.dart` (FR-033)
- [ ] T069 [US5] Implement the reset path for a forgotten PIN from another unlocked subject, keeping every record, and the clean-start path with its advance warning, in `lib/features/security/presentation/security_settings_screen.dart` (FR-045)

**Checkpoint**: all five stories are independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T070 [P] Add the accessibility labels for the lock and PIN screens from [contracts/security-settings-ui.md](./contracts/security-settings-ui.md) §5, and confirm they keep the app's theme and dark mode (constitution VI), verified by a widget test in `test/features/security/lock_accessibility_test.dart`
- [ ] T071 [P] Add the plaintext guard test in `test/features/security/no_secret_in_logs_test.dart`: no PIN, salt, verifier or iteration count reaches a log or a diagnostic (FR-042, FR-043, SC-010)
- [ ] T072 [P] Confirm the feature never reads or writes an amount, seal, rate or total and that the migration in T009 touched no figure (constitution IV), by the assertions in `test/features/security/schema_migration_19_test.dart`
- [ ] T073 Run `dart format` and `flutter analyze` across `lib/` and `test/` and resolve everything they report
- [ ] T074 Run the full `flutter test` suite and confirm the 6 pre-existing cases in `test/features/identity/app_lock_gate_test.dart` still pass unchanged
- [ ] T075 Walk [quickstart.md](./quickstart.md) §5 (on-device) with the FR-048 system prompt at cold start, the away-time, the phone lock, the biometric cancel, the 5th-failure countdown, the clock change, airplane mode (SC-007) and the timed first-time enrolment (SC-008), and record the observed schedule
- [ ] T076 Walk [quickstart.md](./quickstart.md) §6 on two phones (Owner requirement enforced, member cannot switch it off, nothing secret in the payload) and record the result
- [ ] T077 Run the SC-004 benchmark and record it in [quickstart.md](./quickstart.md) §5 item 12: at least 20 unlocks on the reference device (the oldest supported Android phone on hand, named in the result) with the real KDF in the loop, reporting the 95th percentile from the completion of the last prompt, and adjusting the calibrated target in `lib/features/security/repositories/pin_verifier_store.dart` if the 300 ms budget is missed
- [ ] T078 [P] Add the state-minimality test in `test/features/security/no_history_test.dart`: the only stored security state is the failure count and the wait-until, there is no event log, timestamp or attempt history anywhere, and a correct PIN clears the record (FR-046, SC-010)
- [ ] T079 [P] Add the no-bypass guard test in `test/features/security/no_bypass_test.dart`: no factory, default or service PIN exists in the sources, and every route paints through the gate mounted in `MaterialApp.router`'s builder (`lib/main.dart`), so no link, notification or settings entry reaches content without the lock (FR-038)
- [ ] T080 [P] Keep the PIN and lockout records out of everything that leaves the device: exclude the secure-storage preferences from Android auto-backup in `android/app/src/main/AndroidManifest.xml` and assert in `test/features/security/backup_exclusion_test.dart` that only `PinVerifierStore`/`LockoutStore` read `sec_pin_*`/`sec_lockout_*` (no export, log or share path touches them) (FR-042, FR-043)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: depends on Setup; BLOCKS every story (the model, the clock, the state machine).
- **User stories (Phases 3-7)**: all depend on Foundational. US1 is P1 and lands first; US2, US3, US4 and US5 follow in priority order.
- **Polish (Phase 8)**: depends on all five stories.

### Story dependencies

- **US1 (P1)**: none beyond Foundational. MVP.
- **US2 (P2)**: needs US1's `pin_screen.dart` (T033) and `LockController` (T014), so run US1 first or merge the edits to that screen.
- **US3 (P2)**: needs Foundational's state machine (T014) and US1's lock screen (T032).
- **US4 (P2)**: needs Foundational's `LockController` (T014) for the effective setting; independent of US1-US3 otherwise.
- **US5 (P3)**: composes US1 (PIN set/change), US2 (biometrics toggle) and US3 (away-time) into the settings surface.

### Within each story

- Tests are written first and must fail before the implementation tasks in the same story.
- Domain (pure) before repositories, repositories before providers, providers before presentation.
- Each story ends at its checkpoint and is validated on its own before the next begins.

### Parallel opportunities

- **Phase 1**: T002, T003.
- **Phase 2**: T004, T005, T006, T008, T010, T011, T012, T013, T016 (different files, no ordering between them). T007, T009, T014, T015 are sequential.
- **Phase 3**: all seven test tasks T018-T024 in parallel; then T025, T026, T028 in parallel, then T027, T029, then T030, then T031, then T032-T034.
- **Phases 4-7**: the test tasks of each story are parallel among themselves.
- **Phase 8**: T070, T071, T072, T078, T079 in parallel.

---

## Parallel example: User Story 1 tests

```text
Task: "Weak-PIN rules test in test/features/security/weak_pin_test.dart"
Task: "PIN set/verify test in test/features/security/pin_verifier_test.dart"
Task: "Lockout schedule test in test/features/security/lockout_schedule_test.dart"
Task: "Lockout persistence and clock test in test/features/security/lockout_store_test.dart"
Task: "PIN screen widget test in test/features/security/pin_screen_test.dart"
Task: "PIN setup widget test in test/features/security/pin_setup_test.dart"
Task: "Cold-start two-factor test in test/features/security/cold_start_two_factor_test.dart"
```

## Parallel example: Foundational

```bash
Task: "Add the LockSubject domain type in lib/features/security/domain/lock_subject.dart"
Task: "Define LockState and its events in lib/features/security/domain/lock_state.dart"
Task: "Define the MonotonicClock seam in lib/features/security/domain/monotonic_clock.dart"
Task: "Create the LockSetting Isar collection in lib/core/models/lock_setting.dart"
```

---

## Implementation strategy

### MVP first (User Story 1 only)

1. Phase 1 (setup) and Phase 2 (foundational).
2. Phase 3 (US1: PIN, lockout and the cold-start second factor).
3. **Stop and validate**: run `test/features/security/` and walk `quickstart.md` §5 items 1, 2 and 7.
4. The app is now genuinely lockable, which is the deliverable value of the whole feature.

### Incremental delivery

1. US1 - a PIN locks the app, the device's own authentication still gates the key, and guessing is punished.
2. US2 - the biometric shortcut, inside a session only.
3. US3 - it re-arms by itself (away-time, phone lock, subject switch).
4. US4 - an Owner can require a lock for a shared space.
5. US5 - the settings surface and the honest statement about forgetting a PIN.

`017-encrypted-storage` does not begin until 016 is complete: it makes the stored records depend on the PIN
this feature introduces.

---

## Notes

- `[P]` marks tasks that touch different files and can run in parallel.
- Story labels map every story task back to `spec.md` for traceability.
- Test tasks are first in each story and must be seen failing before the implementation follows.
- The only native change is T007, and its limit (non-Android fallback) is recorded in research R3.
- The one existing native call the feature reuses is `DeviceKeySession.require`, which becomes FR-048's
  second factor at cold start; the feature adds no prompt of its own (FR-021).
- No new package is added by any task; every dependency is already pinned in `pubspec.yaml`.
- FR-042 and FR-043 here cover the PIN and its lockout records (T071, T080); the separate duty to keep the
  017 data key out of backups and the wire belongs to `017-encrypted-storage`, as the spec's deferral
  paragraph states.
