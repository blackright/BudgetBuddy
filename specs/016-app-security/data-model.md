# Data Model: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Feature**: 016-app-security | **Date**: 2026-10-18
**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

**Scope**: the lock spine only. The data key, its memory lifetime and the boot manifest of the original
draft belong to `017-encrypted-storage` and are not modelled here.

---

## 1. Subject

A **subject** is what a lock protects: one personal profile (`UserProfile`, `lib/core/models/user_profile.dart:12-52`)
or one shared space (`SharedSpace`, `lib/core/models/shared_space.dart:15-56`). The lock introduces no new
notion of account - it attaches to the subjects the app already has.

- **SubjectKey**: `p<profileId>` for a profile; `s<syncGuid>` for a shared space.
- A space is keyed by its device-independent `syncGuid`, not by its local Isar `Id`, because a restored
  device can hand the row a different local id while the guid is what every device agrees on.
- Subjects are personal and never exchanged. The *requirement a space Owner sets* is the one exception,
  and it is non-secret (§4).

**Validation rules**

- A subject key MUST resolve to exactly one existing subject.
- Removing a profile or a space MUST remove its lock setting with it (FR-034).
- A setting whose subject no longer exists MUST NOT be enforced anywhere.

---

## 2. LockSetting (new Isar collection, local only)

One row per subject. Everything here is **non-secret** and safe to stream into the UI.

| Field | Type | Default | Meaning and rule |
|---|---|---|---|
| `id` | `Id` | autoIncrement | local row id |
| `subjectKey` | `String` `@Index(unique)` | - | `p<profileId>` or `s<syncGuid>` (§1) |
| `subjectKind` | `enum {profile, space}` `@enumerated` | `profile` | how to resolve the subject for the lock screen |
| `subjectLocalId` | `int` | - | the profile id, or the space's local id at write time (display only) |
| `subjectGuid` | `String` | `''` | the space's `syncGuid` when `subjectKind == space`, else `''` |
| `lockEnabled` | `bool` | `false` | the user's own on/off switch (FR-035) |
| `biometricsEnabled` | `bool` | `false` | per subject (FR-020) |
| `awayTime` | `enum AwayTime` `@enumerated` | `twoMinutes` | the five bounded choices, no "never" (FR-033) |
| `createdAt` | `DateTime` | now | local |
| `updatedAt` | `DateTime` | now | local |

**Validation rules**

- `awayTime` MUST be one of `immediate`, `thirtySeconds`, `oneMinute`, `twoMinutes`, `fiveMinutes`
  (FR-033). There is deliberately no value that disables automatic locking.
- `lockEnabled == false` MUST leave the app behaving exactly as it did before this feature: no PIN screen,
  no gate, no prompt (the feature is opt-in per subject).
- Whether a PIN is **set** is *not* a column here: the keystore record (§3) is the source of truth, so the
  row cannot claim a PIN that is not there. The runtime state carries it.
- `biometricsEnabled == true` is only meaningful while the device can satisfy FR-017; the setting is kept,
  but the prompt is not offered when it cannot be honoured, and the UI says why (FR-019).

---

## 3. Secret material (OS secure storage - never Isar)

Written through `SecretStore` (`lib/features/identity/repositories/secret_store.dart:9-13`), the same seam
that already holds the identity seed.

**PIN record** under `sec_pin_<subjectKey>`:

| Field | Type | Rule |
|---|---|---|
| `v` | int | layout version, starts at 1 |
| `kdf` | String | `pbkdf2-hmac-sha256` |
| `salt` | base64 of 16 random bytes | unique per subject; never reused |
| `iterations` | int | calibrated at set time (research R2b); stored so it can be raised later |
| `verifier` | base64 of 32 bytes | the derived key, compared in constant time |

**Lockout record** under `sec_lockout_<subjectKey>`:

| Field | Type | Rule |
|---|---|---|
| `v` | int | layout version, starts at 1 |
| `failCount` | int | consecutive failures since the last success (FR-013) |
| `waitMs` | int | the wait the current `failCount` prescribes |
| `appliedAtElapsedMs` | int | the monotonic reading when the wait started (research R3) |
| `appliedAtUtc` | ISO string | fallback only, for platforms without a monotonic source |

**Validation rules**

- Neither record may ever be written to Isar, to a log, to a crash report, to a backup, or to the wire
  (FR-008, FR-042, FR-043).
- A correct PIN MUST clear the lockout record entirely (FR-011, FR-046).
- The lockout record MUST hold nothing but the current count and the current wait - no history of events
  (FR-046).
- Changing a PIN MUST NOT touch any stored record other than this PIN record (FR-012).

---

## 4. SharedSpace additions (synced)

Three fields are added to `SharedSpace`:

| Field | Type | Default | Authored by |
|---|---|---|---|
| `requirePin` | `bool` | `false` | Owner only (FR-027, FR-028) |
| `forbidBiometrics` | `bool` | `false` | Owner only; `true` suppresses the biometric shortcut for this space (FR-020, FR-027) |
| `awayTime` | `enum AwayTime?` `@enumerated` | `null` | Owner only; `null` = the Owner set no away-time requirement. A shorter time is stricter, so a member MUST NOT weaken it (FR-028, FR-033) |

**Rules**

- Only the non-secret requirement travels. No PIN, verifier or key material may be present in the payload
  (FR-030).
- Authoring is refused unless `SpaceAccessGuard.canManage` returns true, i.e. the acting profile is the
  Owner - the guard already refuses a non-Owner `SharedSpace` write
  (`lib/features/spaces/repositories/space_role_guard.dart:132-137`).
- The fields are carried by the existing `SharedSpace` payload
  (`lib/features/sync/domain/codecs/shared_space_codec.dart:14-32`) and applied by the existing
  `SharedSpaceApplier` (`lib/features/sync/domain/entity_applier.dart:81-101`). No new entity, codec or
  applier.
- A payload that omits the fields decodes to "no requirement", so a member on an older build is not
  broken by a newer payload.
- A payload that omits the fields decodes to "no requirement", so a member on an older build is not
  broken by a newer payload.
- `awayTime == null` is **not** a hidden default of two minutes: it means the Owner set no away-time
  requirement, so the member's own away-time applies unchanged and the member still owns the choice
  (FR-028, FR-033). The same applies to a missing `awayTime` key in a payload (§4 above).
- **Effective setting for a space** = the Owner's requirement, plus the member's own stricter choice. The
  member's own lock can be *more* strict than the requirement and never less; the effective away-time is
  the shorter of the two when the Owner set one, and the member's own value when the Owner did not.

**Migration**: `schemaVersion` 18 -> 19 (`lib/core/database/schema_migrations.dart:21`), an additive step
in the shape of step 16 (`schema_migrations.dart:250-260`). Isar materialises the new columns with their
declared defaults before the step runs; the step rewrites no money figure, seal or rate.

---

## 5. Lock state

Three states, evaluated per subject.

| State | Meaning | Invariants while in it |
|---|---|---|
| `locked` | the subject is closed | the session key is absent (FR-024); no figure, name or record is on screen beyond the subject's own avatar and name (FR-023, FR-037); the biometric prompt may be offered only as a way to leave this state, and only within a session the PIN already opened (FR-018) |
| `unlocking` | a PIN check or a biometric prompt is in flight | at most one prompt is outstanding (FR-021); a failure or cancel returns to `locked` with the data still unavailable (FR-026) |
| `unlocked` | the subject is open for this session | exactly one subject is `unlocked` at a time; the session key is present |

**Lockout** is a property of `locked`, not a fourth state: it bounds how soon `locked -> unlocking` may be
attempted with a PIN (§6).

**Transition triggers** (the authoritative event table is
[contracts/lock-state-machine.md](./contracts/lock-state-machine.md)):

- cold start -> every configured subject starts `locked` (FR-022)
- away-time elapsed while the app was not in the foreground -> `locked` (FR-022)
- the phone's screen locked / the app backgrounded -> the away window starts (FR-022)
- the user switches subject -> the subject being left becomes `locked`, the arriving subject starts
  `locked` if protected (FR-022)
- an explicit lock request -> `locked` (FR-022)
- a correct PIN / a successful biometric in an open session -> `unlocked` (FR-011, FR-018)

**State is not persisted as such**: the app always starts `locked`, and only the lockout record (§3)
survives a restart. There is no stored "unlocked" flag to be tampered with.

---

## 6. Lockout schedule (FR-013)

A pure function of the consecutive failure count. Per subject (FR-016).

| Consecutive failures | Wait before the next attempt |
|---|---|
| 1 - 4 | none |
| 5 | 30 seconds |
| 6 - 9 | 30 seconds |
| 10 | 5 minutes |
| 11 and beyond | double the previous wait, capped at 60 minutes |

**Rules**

- The schedule is a function, not a table of states: given `failCount`, the wait is computed, so a
  corrupted or partial record cannot invent a shorter wait than the count allows.
- The failure count and the remaining wait MUST survive app closure, phone restart and force-quit
  (FR-014).
- A moved clock MUST NOT shorten the wait (FR-015; research R3).
- A lockout on one subject MUST NOT block another (FR-016).
- A correct PIN resets the count to zero and deletes the lockout record (FR-011).

---

## 7. Relationships

```text
UserProfile --1:1-- LockSetting (subjectKind = profile, subjectKey = p<id>)
SharedSpace --1:1-- LockSetting (subjectKind = space,   subjectKey = s<guid>)
                    \-- SharedSpace also carries the Owner's requirement (section 4)

LockSetting -- names --> sec_pin_<subjectKey>      (OS secure storage, section 3)
LockSetting -- names --> sec_lockout_<subjectKey>  (OS secure storage, section 3)
```

No relationship is added between the lock and any money row: the feature reads and writes no amount,
budget, seal or rate (constitution IV).
