# Feature Specification: Encrypted Storage at Rest (Make Stored Records Unreadable)

**Feature Branch**: `017-encrypted-storage`

**Created**: 2026-10-18

**Status**: Draft

**Input**: Carried from the original security request: "All sensitive data must be stored using encrypted storage, with secure key management via the OS keystore and zero plaintext storage." This is the at-rest half of that request; the visible lock half is feature `016-app-security`.

**Scope note (2026-10-18)**: Feature `016` delivers the lock (PIN, biometrics, lock behaviour, protected spaces). This feature delivers the guarantee that the records themselves are unreadable without the user's unlock, plus the switch-over that carries the data already on the phones into the encrypted form. It depends on `016`. The requirement numbers below are fresh for this feature; the mapping to the original draft is recorded in the assessments (the original FR-001 to FR-006, the data-key clause of FR-024, FR-040, FR-041, FR-044, and FR-047).

This specification states the security *standard*, not the technology that meets it. The app's current local storage provides no way to make records unreadable at rest, so the approach that can (which local store, and how existing data is carried over) is chosen during this feature's planning, before any implementation. No engine, library, or API is named here.

## Clarifications

### Session 2026-10-18

- Q: When a user resets after forgetting a PIN, and another profile on the same phone can still be unlocked, should that other profile be able to recover the lock and keep all data? -> A: **The other unlocked subject can reset the PIN and keep all data.** Because that phone can already read the data, the lock is what is reset - the records are never destroyed to reset a lock.
- Q: Should a first launch after the switch-over nag the user to add a PIN? -> A: **One skippable invitation only.** Declining leaves every record reachable and enables no lock, and the invitation never reappears unless the app is reinstalled or all local data is erased.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Nobody can read my records without my unlock (Priority: P1)

The person who owns the phone is the only one who can make the stored records readable. If the app's data is copied off the device - a device backup, a copy of the app folder, a restore onto another phone - the copy is useless. This holds whether the app is open, locked, or absent.

**Why this priority**: It is the only story that changes *what an attacker gets*. Without it, a PIN screen and a two-minute timer are presentation over a readable store. Every other story in this feature serves this one.

**Independent Test**: With a lock configured, read the app's own stored data directly with a developer tool, and separately restore a device backup onto a second device, confirming in both cases that no amount, name, medical detail, or currency value is recoverable without the user's unlock.

**Acceptance Scenarios**:

1. **Given** the app has been set up with this feature, **When** any record is written, **Then** reading the store outside the app with the app locked yields no readable value.
2. **Given** a device backup taken while the app was locked, **When** it is restored onto a different device, **Then** no budget record can be read or rendered there, and the user is told plainly that the data could only be read on the original device.
3. **Given** the app is locked, **When** the device is used, **Then** no screen shows any stored figure.

---

### User Story 2 - The change is safe, and I am asked only once (Priority: P1)

Turning on encrypted storage must not cost the user a single record, even if the change is interrupted halfway. The app carries over what is
already on the phone, keeps the original readable until the change is verified, and then asks once - never again - whether the user wants a PIN.

**Why this priority**: This is the difference between a security upgrade and a data-loss event. The data already on real phones is the most valuable thing the app holds, and the user must not be punished for accepting the change.

**Independent Test**: Take a phone with existing records through the switch-over, kill the app in the middle, reopen it and confirm every original record is still readable; then complete the switch-over and confirm exactly one PIN invitation appears and never returns.

**Acceptance Scenarios**:

1. **Given** a device that already holds records, **When** the switch-over completes, **Then** every existing record is still readable on that device and none has changed.
2. **Given** the switch-over is interrupted (the app is killed mid-change), **When** the app is opened again, **Then** the original data is still readable on that device and no record has been lost.
3. **Given** a completed switch-over, **When** the app is opened for the first time afterwards, **Then** exactly one skippable invitation to set a PIN is shown; declining leaves every record reachable and enables no lock.
4. **Given** the invitation was declined or answered, **When** the app is opened again, **Then** the invitation does not reappear unless the app is reinstalled or all local data is erased.

---

### Edge Cases

- **A device that cannot provide a device-bound, non-exportable key** (an old device, an emulator) - the key must never be written to reachable storage; the weaker situation must be surfaced explicitly, not fallen into by accident.
- **The key material becomes unavailable** (a restore, a wipe, a platform change) - the data on that device must be treated as unreadable, said out loud, and followed by a clean start; never a silent empty app, never a promise of recovery.
- **The migration is interrupted** - the original data must still be readable on that device; a failed switch-over is not a data loss.
- **A backup taken while the app is open** - a backup must never be the reason a record becomes readable elsewhere; the key must not travel in it.
- **Two profiles on one phone after the switch-over** - locking one subject must not make another subject's records unreadable.
- **An install that never enables a lock** - it must keep working normally, with its data still held only in the encrypted form.
- **The app is uninstalled** - there is nothing to recover, and the user must never be led to believe otherwise.

## Requirements *(mandatory)*

### Functional Requirements

**Unreadable at rest**

- **FR-001**: Every user record the app stores locally MUST be unreadable outside the app without the user's unlock - including amounts, budgets, expenses, medical bills, reimbursements, insurance details, currency and conversion settings, profile and shared-space metadata, and attached images.
- **FR-002**: The material that makes those records readable MUST be 256-bit, MUST be held by the device's secure hardware, MUST NOT be exportable or copyable off the device, and MUST NOT appear in any device backup.
- **FR-003**: No readable copy of the data may be kept for convenience: no plaintext cache, no plaintext export, and no weaker alternative (such as a security question) that bypasses the unlock.
- **FR-004**: While the app is locked, the data MUST be unreadable by the app too - the user's unlock is what makes reading possible, and locking removes it.
- **FR-005**: All of the above MUST work entirely offline: no unlock, enrolment, verification, or key handling may depend on the network.
- **FR-006**: An install that has no lock enabled MUST keep working normally and MUST still hold its data only in the encrypted form.
- **FR-007**: The material that makes the data readable MUST NOT be held in memory while the app is locked, and locking MUST remove it from memory.

**When the key is missing or the device cannot hold one**

- **FR-008**: When the material that makes the data readable is unavailable, the app MUST start with an empty state, state plainly that the records on this device cannot be read, and MUST NOT imply they can be recovered.
- **FR-009**: When the device cannot hold a non-exportable key, the app MUST refuse or explicitly warn; it MUST never write the key to reachable storage.

**The switch-over**

- **FR-010**: Existing data MUST be carried over, with the change kept reversible until it is verified: if the change is interrupted, the original data MUST still be readable on that device.
- **FR-011**: On the first launch after the switch-over, the app MUST show one skippable invitation to set a PIN. Declining MUST leave every record reachable and MUST NOT enable a lock, and the invitation MUST NOT reappear unless the app is reinstalled or all local data is erased.

**Evidence**

- **FR-012**: No plaintext record and no key material may appear in logs, crash reports, or any content leaving the device; every outgoing change and backup MUST exclude key material.

### Key Entities

- **Data key** - the 256-bit material that turns the local records into something readable. Held by the device's secure hardware, never exportable, never in a backup, present only while unlocked.
- **Opaque key material** - what the user's PIN unwraps to release the data key. Holds no user-visible content, lives in the device's secure hardware, never in the data store, never in anything sent to another device.
- **Local data** - everything the app already stores per profile and per shared space: amounts, expenses, medical bills, reimbursements, insurance details, currency and rates, and settings. Its shape does not change; its readability does.
- **Boot manifest** (small, non-secret) - which subject the app should ask about, and its name and avatar, so the lock screen can be drawn before any user record is readable.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With the app locked, 100% of a sample read directly from the device's storage contains no amount, name, medical detail, or currency value.
- **SC-002**: 0 of the records restored from a device backup onto a second device can be rendered there.
- **SC-003**: Copying the app's data to another device and attempting to open it yields no readable record in 100% of attempts.
- **SC-004**: An interrupted switch-over leaves the original data readable on the device (0 records lost).
- **SC-005**: A first launch after the switch-over shows exactly one PIN invitation; declining leaves everything reachable and enables no lock, and no further invitation appears in 10 subsequent launches.
- **SC-006**: On a device that cannot hold a non-exportable key, 0 keys are written to reachable storage.
- **SC-007**: Not one plaintext occurrence of a record or of key material appears in the app's logs or diagnostics over a full test run.

## Assumptions

- **This feature depends on `016-app-security`.** The PIN and the lock are what release the key; this feature makes the stored records depend on it.
- **The app's current local storage cannot provide this** - it has no way to make records unreadable at rest. The approach that can is chosen during this feature's planning; the requirement is the standard, not the engine.
- **One data key per install**: a per-profile or per-space lock is an in-app boundary. The guarantee is that the key cannot leave the device, not that every subject has a separate cryptographic key.
- **The encrypted form is the new normal** for every install after the switch-over; the lock itself stays opt-in, so an install with no PIN still holds its records only in the encrypted form.
- **Current data must be carried over**, and the change kept reversible until it is verified, with the two-phone test the project already uses.
- **The feature works entirely offline**; nothing about enrolment, unlocking, or the switch-over depends on the network.
- **Explicitly out of scope**: no change to the identity key, membership, the change exchange, or any existing sync guarantee from 015; no security event history or audit log; no remote wipe or account recovery service; no field-level or per-entity encryption policy beyond making the whole local store unreadable.
