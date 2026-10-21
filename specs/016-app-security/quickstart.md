# Quickstart: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Feature**: 016-app-security | **Date**: 2026-10-18
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

This guide proves the feature works end to end: unit and widget tests first, then the on-device checks the
tests cannot cover (the OS biometric prompt, the clock, the lifecycle, and two phones).

The at-rest half lives in `017-encrypted-storage`; nothing here makes a stored copy unreadable.

---

## Prerequisites

- Flutter SDK matching `pubspec.yaml`; no new package is added by this feature.
- A device or emulator with a screen lock (PIN/pattern) and, for the biometric checks, a fingerprint or
  face enrolled.
- For the two-phone checks: two Android devices that already share a space (the 015 pairing flow), or the
  project's existing two-device test setup.

---

## 1. Baseline

```powershell
flutter analyze
flutter test
```

Baseline recorded 2026-10-19, before any file of this feature was added: `flutter test` =
**759 passing, 1 skipped** ("All tests passed!"), and `flutter analyze` = no issues. (The `756`
quoted in `plan.md` predates the 015 Phase 7 polish; 759 is the real number on this tree.)

The suite must stay at or above that level once this feature's tests are added. The six existing
cases in `test/features/identity/app_lock_gate_test.dart` must keep passing unchanged - they pin the
cold-start behaviour when no PIN exists.

---

## 2. Unit-level (pure Dart, no device)

Write these first and watch them fail, as the project requires:

1. **`LockoutSchedule`** - the FR-013 table: 1-4 -> none; 5 and 6-9 -> 30 s; 10 -> 5 min; 11+ -> doubling
   capped at 60 min. Boundary cases at 4/5, 9/10, 13/14.
2. **Weak-PIN refusal** - all identical digits, runs, and the weak list are refused; a normal PIN is not.
3. **PIN verify** - a correct PIN clears the record; a wrong PIN increments it; the count is per subject.
4. **The clock** (R3) - a stepped fake monotonic clock: moving the wall clock back or forward does not
   change the remaining wait while the monotonic reading is unchanged; a reboot (reading goes backwards)
   re-imposes the remaining wait in full; the failure count is untouched in every case.
5. **Setting storage** - round-trip of `LockSetting`; an away-time outside the five choices is rejected;
   deleting a subject removes its setting.
6. **Composition** - a space's effective away-time is the shorter of the Owner's and the member's, and a
   member cannot turn the requirement off.

## 3. Widget-level (ProviderContainer overrides, fake seams)

Follow `test/features/identity/app_lock_gate_test.dart:75-102`:

- no identity, or no lock -> the gate is inert (regression: 015 behaviour unchanged);
- a lock with a PIN -> the lock screen shows only the avatar, the name and one Unlock action;
- a wrong PIN -> the error line, the count increments, and after the fifth failure the countdown runs and
  the keypad is disabled;
- a **cancelled** biometric -> no failure recorded, the PIN path is offered (FR-019);
- a biometric at **cold start** -> the PIN is still required (FR-018);
- every accessibility label from [contracts/security-settings-ui.md](./contracts/security-settings-ui.md)
  §5 is present on the lock and PIN screens.

---

## 4. Data-layer

- Schema migration 18 -> 19 leaves every existing row intact (money, seals, rates, memberships) and gives
  the new `SharedSpace` fields their defaults.
- `SharedSpaceCodec` round-trips the three new fields, and decodes a payload that lacks them to \"no
  requirement\".

---

## 5. On-device (what the tests cannot cover)

1. **Cold start with a PIN** - enter the PIN, then the single system prompt a cold start requires (FR-048),
   and reach the app. Force-close and reopen: the fingerprint cannot open it on its own, and the PIN is
   asked for first (FR-018). Repeat the cold start ten times: none is opened by the fingerprint alone
   (SC-011).
2. **Away-time** - set 30 s, background the app for 20 s (still open), then for 40 s (locked).
3. **Phone lock** - with the app open, lock the phone, wait past the away-time, unlock the phone: the app
   asks for the PIN.
4. **The app switcher** - open the app switcher and return immediately: it does **not** lock (`inactive`).
5. **Biometrics** - enable them, unlock with the fingerprint after the away-time, then cancel the prompt
   and confirm no failure was counted and the PIN is offered.
6. **Biometric at cold start** - force-close, reopen, and confirm the fingerprint cannot open the app: the
   PIN prompt comes first (FR-018).
7. **Lockout** - fail the PIN five times. The wait is 30 seconds with a visible countdown. Force-quit and
   reopen: the remaining wait is unchanged (SC-005). Repeat the force-quit/reopen cycle ten times and
   confirm the wait is never shortened (SC-005). Switch the device clock forward and back: the wait does
   not shorten.
8. **Subject switch** - with two profiles (and a shared space), switch between them; the left subject locks
   and the arriving protected subject asks for its own PIN.
9. **No network needed (SC-007)** - turn on airplane mode, then unlock, fail a PIN (the countdown still
   runs), and set a PIN on a fresh subject: nothing in enrolment, verification or unlocking waits on the
   network.
10. **Enrol-and-use under a minute (SC-008)** - hand the phone to someone who has not seen the app; they
    enable a PIN unaided and unlock with it in under a minute, and no existing record is missing.
11. **Plaintext check** - `adb logcat` shows no PIN, salt, verifier or iteration count at any point
    (FR-042, SC-010).
12. **Timings** - record the measured KDF and unlock times against SC-004 (under 300 ms from the last
    prompt to the app being usable) on the reference device - the oldest supported Android phone on hand,
    whose model is recorded with the result. Run at least 20 unlocks with the real KDF in the loop and
    report the 95th percentile, not a single sample.

### Recording sheet (T075) - fill in on a real device

Walk every item above and record what you actually saw. Leave a row blank rather than guessing: a
blank row is an honest "not run", a filled-in guess is not.

| Item | What to record | Reference device | Observed | Pass? |
|---|---|---|---|---|
| 1 | Cold-start PIN + single system prompt, 10× | | | |
| 2 | Away-time 30 s: 20 s open, 40 s locked | | | |
| 3 | Phone lock past away-time asks for PIN | | | |
| 4 | App switcher return does not lock | | | |
| 5 | Biometric cancel counts no failure | | | |
| 6 | Cold start: fingerprint cannot open it | | | |
| 7 | 5 failures = 30 s wait; force-quit 10× never shortens; clock change never shortens | | | |
| 8 | Subject switch locks the left subject | | | |
| 9 | Airplane mode: unlock, fail, set PIN - no network wait | | | |
| 10 | SC-008: enrol-and-use under a minute | | | |
| 11 | `adb logcat` shows no PIN/salt/verifier/iterations | | | |
| 12 | SC-004 timings (see the sheet below) | | | |

**Reference device (oldest supported Android phone on hand):** ______________________
(model and Android version)

### SC-004 timing sheet (T077) - at least 20 unlocks, real KDF

| # | Unlock time from last prompt (ms) | # | Unlock time from last prompt (ms) |
|---|---|---|---|
| 1 | | 11 | |
| 2 | | 12 | |
| 3 | | 13 | |
| 4 | | 14 | |
| 5 | | 15 | |
| 6 | | 16 | |
| 7 | | 17 | |
| 8 | | 18 | |
| 9 | | 19 | |
| 10 | | 20 | |

**95th percentile:** ____________ ms   **Budget (SC-004):** under 300 ms   **Result:** pass / fail

> **Note on the two budgets.** SC-004's 300 ms is the **unlock** budget measured here. The KDF's own
> `targetMs` in `lib/features/security/repositories/pin_verifier_store.dart` is a separate, stricter
> **150 ms** set-side calibration budget; the two are different jobs and both are intentional. If this
> benchmark fails, re-read that file before changing either number - the fix may be the calibration, not
> the budget.

---

## 6. Two-phone check (Owner requirement)

1. As the **Owner**, set \"require a PIN\" for the space and an away-time.
2. **Member** device: enter the space and confirm the unlock is required and that the requirement cannot be
   switched off.
3. Owner forbids biometrics for the space; the member's device accepts only the PIN for that space.
4. Confirm the member's device received **only** the three fields - no PIN, verifier or key material - by
   inspecting the exchanged payload in the app's own diagnostic trace (FR-030).
5. Confirm a **non-Owner** cannot change the requirement (the Guard refuses the write).

### Recording sheet (T076) - fill in with two phones

| Item | What to record | Phone A (Owner) | Phone B (Member) | Pass? |
|---|---|---|---|---|
| 1 | Owner sets "require a PIN" + away-time | | | |
| 2 | Member is asked for a PIN; the requirement cannot be switched off | | | |
| 3 | Owner forbids biometrics; member's device accepts PIN only | | | |
| 4 | Payload carries only the three fields - paste the trace here | | | |
| 5 | A non-Owner cannot change the requirement | | | |

---

## 7. Sign-off

- `flutter analyze` clean; `flutter test` green (baseline plus the new cases).
- Every acceptance scenario in [spec.md](./spec.md) walked, with the exact wait schedule observed.
- The honest limits stated in research R3 (the fallback platform) and the spec's assumptions (an Owner's
  requirement is enforced per device) are recorded as accepted, not silently dropped.

Only then does implementation begin for `017-encrypted-storage`.
