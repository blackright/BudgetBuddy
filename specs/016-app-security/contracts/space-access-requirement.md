# Contract: Space Access Requirement

**Feature**: 016-app-security | **Scope**: what an Owner may require of everyone entering a shared space,
how it travels, and what is enforced on a member's device. Complements [data-model.md](../data-model.md)
§4 and [research.md](../research.md) R6.

Actors: **Owner** (the member with `SharedMemberRole.owner`), **Member** (any other member), **Guard**
(`SpaceAccessGuard`, `lib/features/spaces/repositories/space_role_guard.dart:28-167`), **Codec**
(`SharedSpaceCodec`, `lib/features/sync/domain/codecs/shared_space_codec.dart:7-33`), **Applier**
(`SharedSpaceApplier`, `lib/features/sync/domain/entity_applier.dart:81-101`).

---

## 1. Who may set it (FR-027, FR-028)

- Only the Owner. The write is refused by the existing guard: `canManage` is Owner-only
  (`space_role_guard.dart:43-44`) and the applier-time rule refuses a non-Owner `SharedSpace` write
  (lines 132-137). No new authority is introduced.
- A Member sees the requirement and MUST NOT be able to switch it off (FR-028).
- The Owner may change or remove the requirement at any time; the change travels like any other space
  change.

---

## 2. What the requirement is

Three non-secret fields on `SharedSpace` ([data-model.md](../data-model.md) §4):

| Field | Meaning |
|---|---|
| `requirePin` | everyone entering must unlock with their own PIN |
| `forbidBiometrics` | the biometric shortcut is forbidden for this space; only the member's PIN is accepted |
| `awayTime` | the away-time for the space, one of the five bounded choices, or unset (`null`) when the Owner set none |

`forbidBiometrics` composes with `requirePin`: biometrics are a convenience *within* a session the PIN
already opened (FR-018), so requiring a PIN always applies, and forbidding biometrics removes the
shortcut without removing the PIN.

---

## 3. Composition on the member's device

The effective setting for a space subject is:

- **lock**: required if the Owner requires a PIN, or the member has switched their own lock on;
- **biometrics**: offered only if the Owner permits them **and** the member has them on **and** the device
  can satisfy FR-017;
- **away-time**: the **shorter** of the Owner's and the member's own choice when the Owner set one (the
  stricter one), so a member can lock sooner but never later; when the Owner set none, the member's own
  choice stands unchanged. `null` is not a hidden two-minute default.

A member cannot weaken any part of the requirement (FR-028).

---

## 4. What travels (FR-030)

The three fields are added to the existing `SharedSpace` payload
(`lib/features/sync/domain/codecs/shared_space_codec.dart:14-32`, literal maps) and applied by the existing
applier (`lib/features/sync/repositories/...` -> `entity_applier.dart:81-101`), which rewrites the row by
`syncGuid`. No new entity, codec, applier or migration step is introduced.

**Nothing secret ever travels.** No PIN, no verifier, no salt, no iteration count, no key material, and no
per-member setting is included. A device that receives the space row learns only the requirement - never
anything that would let it unlock another person's device.

---

## 5. Compatibility

- The fields are additive: Isar materialises the new columns with their defaults
  (`data-model.md` §4), and the codec decodes a missing key to \"no requirement\", so a member on an older
  build is not broken by a newer payload - it simply does not enforce the requirement until it updates.
- The Owner's build must be the one that carries the fields; a member's write of the space row is refused
  by the Guard regardless (FR-028).

---

## 6. When a member cannot meet the requirement (FR-031)

If the device cannot satisfy the requirement (for example biometrics are required by nothing, but the
member's device has no enrolment, or the space's rule cannot be honoured), the app explains what is
missing and offers the PIN path. It MUST NOT dead-end, and it MUST NOT silently downgrade the requirement.
The message names the missing thing, not an error code.
