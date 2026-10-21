# Contract: PIN Verifier and Lockout

**Feature**: 016-app-security | **Scope**: where the PIN verifier lives, how a PIN is set and checked,
and how a lockout is measured and survived. Complements [data-model.md](../data-model.md) §§3, 6 and
[research.md](../research.md) R1, R2, R2b, R3.

Actors: **Store** (`SecretStore`, `lib/features/identity/repositories/secret_store.dart:9-13`),
**Verifier** (the pure rules this contract fixes), **Clock** (the monotonic seam, R3), **UI** (the PIN
screen).

---

## 1. Where the verifier lives (FR-008)

- The verifier record is written to the OS secure storage under `sec_pin_<subjectKey>` through `Store`.
  `<subjectKey>` is `p<profileId>` or `s<spaceSyncGuid>` (`data-model.md` §1).
- It MUST NOT be written to Isar, to the app's data directory, to a log, to a crash report, to a device
  backup, or to anything sent to another device (FR-008, FR-042, FR-043).
- The raw PIN is never stored anywhere, at any time, in any form (FR-008).

Record layout and validation: [data-model.md](../data-model.md) §3.

---

## 2. Setting a PIN (FR-009, FR-010, FR-039)

1. The first time, the PIN is entered twice and the two entries must match (FR-009).
2. Clearly guessable PINs are refused with a plain message: all identical digits, simple runs, and a short
   maintained weak list (FR-010). The list is a constant in the domain layer, unit-tested.
3. The KDF parameters are chosen at this moment (R2b): a fresh 16-byte salt from a CSPRNG and an iteration
   count calibrated so the derivation stays under the 150 ms target on this device, never below a
   documented floor.
4. The verifier is derived and written; the lockout record is cleared.
5. Before the first PIN is accepted, the user has been shown what forgetting it means (FR-039), in the
   wording of [security-settings-ui.md](./security-settings-ui.md) §3.

The PIN is 4-8 digits (FR-007).

---

## 3. Verifying a PIN (FR-011, FR-012)

- Derive with the stored salt and iteration count, then compare with
  `constantTimeBytesEquality` (`package:cryptography`, `constant_time_equality.dart:25`). Timing MUST NOT
  reveal how many leading digits matched.
- **Match**: enter `unlocked`, delete the lockout record entirely (FR-011), and, if the stored iteration
  count is below the current target, transparently re-derive at the higher count and rewrite the record
  (so cost can be raised with the app, without a migration).
- **Mismatch**: increment the failure count, apply the schedule (§4), stay `locked` (FR-026).
- **Changing a PIN** requires the current PIN, then writes a fresh salt and verifier. It MUST NOT touch any
  other stored record, so a PIN change carries no data risk (FR-012).

---

## 4. The schedule (FR-013, FR-016)

| Consecutive failures | Wait before the next PIN attempt |
|---|---|
| 1 - 4 | none |
| 5 | 30 s |
| 6 - 9 | 30 s |
| 10 | 5 min |
| 11+ | double the previous wait, capped at 60 min |

- The wait is computed from `failCount` by a pure function, not read from a stored deadline, so a partial
  or edited record cannot produce a shorter wait than the count allows.
- The countdown is visible and the keypad is disabled while it runs (FR-036).
- The count and the remaining wait belong to the subject being unlocked; another subject is unaffected
  (FR-016).
- A correct PIN is the only thing that clears the count (FR-011, FR-046).

---

## 5. The clock (FR-014, FR-015; research R3)

- The wait is measured with the monotonic seam. On Android that is `SystemClock.elapsedRealtime()`, which
  counts real time since boot and ignores clock changes.
- If the reading now is **smaller** than the reading stored when the wait began, the device rebooted: the
  remaining wait is re-imposed in full from that moment - the safe direction.
- On a platform without the monotonic source, the wall clock is used but is clamped so it can never run
  backwards relative to the last recorded reading; a forward change can then end that wait early there,
  and the limit is recorded in research R3 rather than hidden.
- The failure **count** is never affected by any clock event on any platform, so the escalating schedule
  still applies.

---

## 6. Surviving a restart (FR-014)

- The lockout record is re-read at cold start; force-quit, app closure and phone restart MUST NOT reset the
  count or shorten the remaining wait.
- Nothing about an `unlocked` session survives: only the lockout record is persisted (see
  [lock-state-machine.md](./lock-state-machine.md) §8.3).

---

## 7. What is never done

- No history of unlocks, failures, lockouts or PIN changes is kept; only the current count and the current
  wait (FR-046).
- No PIN, verifier, salt or iteration count appears in a log, a crash report, a backup or the wire
  (FR-042, FR-043).
- No factory, default or service PIN exists, and no hidden route bypasses the check (FR-038).

---

## 8. Seams this feature fixes

| Seam | Responsibility | Test double |
|---|---|---|
| `PinVerifierStore` (new, `features/security/repositories`) | read/write/delete the `sec_pin_<key>` record through `SecretStore` | in-memory fake |
| `LockoutStore` (new) | read/write/clear the `sec_lockout_<key>` record | in-memory fake |
| `MonotonicClock` (new) | `int nowMs()`, monotonic, boot-safe | fake stepping clock |
| `LockoutSchedule` (new, `domain/`) | `Duration waitFor(int failCount)` - pure | unit test |

`SecretStore` itself is reused unchanged; the two new stores are the only new writers to it.
