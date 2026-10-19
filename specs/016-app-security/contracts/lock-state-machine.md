# Contract: Lock State Machine

**Feature**: 016-app-security | **Scope**: when a subject is locked, what may be shown, and what a lock
does to the session. Complements [data-model.md](../data-model.md) §5 (the states) and
[pin-verifier-and-lockout.md](./pin-verifier-and-lockout.md) (how `locked` may be left).

Actors: **App** (the lifecycle observer in `lib/main.dart`), **Gate** (`AppLockGate`, the mount point at
`lib/main.dart:207`), **Lock** (the per-subject lock notifier), **Session**
(`deviceKeySessionProvider`, `lib/features/identity/providers/device_key_session.dart:55-112`),
**Screen** (what the user sees).

---

## 1. Subjects and the effective setting

A lock belongs to a **subject** - one profile or one shared space (`data-model.md` §1). For a space the
effective setting is the Owner's requirement composed with the member's own stricter choice
([space-access-requirement.md](./space-access-requirement.md) §3). A subject with `lockEnabled == false`
and no Owner requirement is **unprotected** and never enters this machine.

---

## 2. States

| State | Session key (FR-024) | What the Screen shows (FR-023, FR-037) |
|---|---|---|
| `locked` | absent | the subject's avatar and name, and one Unlock action. No figure, no list, no notification content, no deep-link target |
| `unlocking` | absent | the PIN screen (keypad, error line, countdown when locked out) or the OS biometric prompt |
| `unlocked` | present | the app |

`lockout` is not a fourth state; it constrains `locked -> unlocking` for a PIN
([pin-verifier-and-lockout.md](./pin-verifier-and-lockout.md) §4).

---

## 3. Events

| Event | From | To | Rules |
|---|---|---|---|
| cold start | - | `locked` (every protected subject) | FR-022. Nothing is read to decide this: the state is never persisted, so there is no stored "unlocked" flag to tamper with |
| app leaves the foreground | `unlocked` | `unlocked` + away window starts | `paused`, `hidden`, `detached` start the window; `inactive` does **not** (app switcher, incoming call - see §4) |
| app returns to the foreground before the away-time | `unlocked` | unchanged | the window is discarded |
| app returns after the away-time | `unlocked` | `locked` | FR-022 |
| the phone's screen is locked while the app is open | `unlocked` | `unlocked` + away window starts | the OS reports this as leaving the foreground; the same away-time applies |
| the user switches subject | `unlocked` | the left subject `locked`, the arriving subject `locked` if protected | FR-022, FR-032 |
| explicit lock requested | `unlocked` | `locked` | FR-022 |
| a correct PIN is entered | `locked` | `unlocked` | FR-011; clears the failure record |
| a successful biometric within an open session | `locked` | `unlocked` | FR-018; never from a cold start |
| a failed / cancelled PIN | `unlocking` | `locked` | FR-026; increments the failure count |
| a cancelled / failed / errored biometric | `unlocking` | `locked` | FR-019; must not count as a wrong PIN |
| the identity is wiped | `unlocked` | - | the gate becomes inert; no subject remains |

---

## 4. Away-time

- Exactly five choices per subject: `immediate`, `30 s`, `1 min`, `2 min` (default), `5 min`. There is no
  "never" (FR-033).
- The window is measured on the monotonic clock ([pin-verifier-and-lockout.md](./pin-verifier-and-lockout.md)
  §5), so moving the device clock neither shortens nor lengthens it.
- `inactive` is transient by construction in this app: the existing sync observer explicitly keeps running
  through it (`lib/main.dart:136-138`). The lock does the same, so pulling down the notification shade or
  taking a call does not lock the app.
- `immediate` locks on the next `paused`/`hidden`/`detached`, which is the "put the phone down" case.

---

## 5. The session key

- Entering `locked` MUST drop whatever the session released: `Lock` calls
  `deviceKeySessionProvider.notifier.lock()` (existing, `device_key_session.dart:83-86`), which is what
  `AppLockGate._lockWhenShut` already does after the frame
  (`app_lock_gate.dart:61-66`) - the write must stay out of the build pass, for the reason recorded there.
- Entering `unlocked` is the only thing that releases it.
- While `locked`, no code path may read the key; sync and pairing already demand it
  (`lib/features/identity/providers/device_key_session.dart` and its callers), so a locked app simply
  cannot sync.

---

## 6. One prompt (FR-021)

A single unlock event produces at most one OS prompt. The single-flight rule already implemented in
`DeviceKeySession.require` (one in-flight future shared by all concurrent callers, a failure never
remembered) is the contract; the lock screen must not add a second prompt of its own. Cold start costs
one PIN entry **and at most one system prompt** - the device's own authentication under FR-048 - and the
app never shows a second prompt of its own for the same event.

---

## 7. What the lock must never show

- No figure, name (other than the subject's own), list row, notification body, or deep-linked content
  behind the lock (FR-023).
- A notification or a link opened while locked MUST land on the lock screen, never on the content first
  (spec edge case).
- The lock screen is not a place for an error about the data, a "recover" link, or a hidden way in
  (FR-038).

---

## 8. Invariants

1. At most one subject is `unlocked` at any moment.
2. `locked` implies the session key is absent.
3. The machine never persists "unlocked"; every cold start is `locked`.
4. An unprotected subject is outside the machine entirely - the app behaves as it did before this feature
   (opt-in, spec assumption).
5. A lockout on one subject never blocks another (FR-016).
