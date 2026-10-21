# Contract: Security Settings Surface

**Feature**: 016-app-security | **Scope**: where the lock is managed, what each control does, the wording
the user must see, and the widget keys the tests bind to. Complements [spec.md](../spec.md) FR-035 to
FR-039 and FR-045.

Actors: **User**, **Settings** (`lib/features/settings/presentation/settings_screen.dart:13-49`),
**SecuritySection** (new), **SpaceSettingsSection**
(`lib/features/spaces/presentation/space_settings_section.dart`, Owner card), **Tests**.

---

## 1. Where it lives

A new `SecuritySection` is added to the Settings list, after `IdentitySection`
(`settings_screen.dart:27`). It is always visible. When the current subject has no lock configured it
offers one action: set a PIN. When a lock exists it shows the state and the controls below.

The Owner's requirement card lives in the existing `SpaceSettingsSection`, which already renders only in a
shared-space context (`settings_screen.dart:23-25`) and already gates Owner-only controls.

---

## 2. What the card shows (FR-035, FR-036)

| Control | Shown when | What it does |
|---|---|---|
| Lock on / off | always | turns this subject's lock on or off; turning it **on** starts PIN setup; turning it **off** requires the current PIN |
| Change PIN | a PIN is set | current PIN, then new PIN twice (FR-009) |
| Biometrics on / off | the device can satisfy FR-017 | enables or disables the in-session shortcut; the reason is stated when unavailable |
| Away-time | a lock is on | the five bounded choices, default 2 minutes, no \"never\" (FR-033) |
| Lockout status | a lockout is active | the remaining wait, read-only (the count itself is never shown as a history) |

The card MUST NOT show a security-event log or a list of past attempts (FR-046).

---

## 3. The words the user must see (FR-039, FR-045)

Before the first PIN is accepted, and again where a reset is offered, the app states plainly:

- the PIN cannot be recovered through the app;
- another subject on this same phone can reset it and keep every record;
- when nothing on this phone can open the app, the only way forward is to erase the local data and start
  clean, and the user will be told before that happens.

When another subject on the device can unlock (FR-045), the reset path is offered from that unlocked
subject and keeps every record. When nothing can unlock, the clean-start path is offered and the user is
told exactly what will be removed first.

---

## 4. The lock and PIN screens (FR-036, FR-037)

- **Lock screen**: the subject's avatar and name, and a single Unlock action. No figures, no lists
  ([lock-state-machine.md](./lock-state-machine.md) §7).
- **PIN screen**: numeric keypad, a clear error line, the lockout countdown and disabled keypad while a
  wait runs, and the biometric option when enabled.
- At most one OS prompt per unlock event (FR-021); the PIN screen never triggers a prompt of its own.
- A cancelled biometric returns to the PIN screen with no attempt recorded and no accusation (FR-019).

---

## 5. Accessibility and text

- The app's UI text is English, written inline, consistent with every other screen; this feature adds no
  localization framework.
- The lock and PIN screens MUST carry semantic labels (avatar/name, each keypad digit, the unlock action,
  the countdown as a live region) so a screen reader can operate them, and MUST keep the app's theme and
  dark-mode support (constitution VI).
- The keypad MUST be operable with a screen reader: every digit is independently labelled and the error
  line is announced.

---

## 6. Widget keys (for tests)

Following the existing `Key(...)` convention used by the repo's widget tests:

| Key | Widget |
|---|---|
| `securitySection` | the Settings card |
| `lockSwitch` | lock on / off |
| `changePinButton` | change PIN |
| `biometricSwitch` | biometrics on / off |
| `awayTimeDropdown` | away-time |
| `lockoutStatus` | the active-wait row |
| `pinSetupScreen` | PIN setup |
| `pinKeypad` | the numeric keypad |
| `pinError` | the error line |
| `lockoutCountdown` | the countdown |
| `unlockButton` | the single Unlock action |
| `biometricUnlockButton` | the in-session biometric path |
| `spaceRequirePinSwitch` | Owner card: require a PIN |
| `spaceForbidBiometricsSwitch` | Owner card: forbid the biometric shortcut |
| `spaceAwayTimeDropdown` | Owner card: away-time |

---

## 7. Owner card (FR-027, FR-028)

In a shared-space context the card lets the **Owner** require a PIN and, separately, forbid the biometric
shortcut, and set the space's away-time. A **Member** sees the requirement as a read-only statement and
cannot switch it off. The card never shows or asks for the Owner's own PIN.
