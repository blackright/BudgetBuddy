# Feature Specification: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Feature Branch**: `016-app-security`

**Created**: 2026-10-18

**Status**: Draft

**Input**: User description: "Provide a complete security layer for the application: PIN authentication, biometric authentication, secure storage of sensitive data, protection of personal profiles and shared financial spaces, prevention of unauthorized access, and offline-first security guarantees - so the app stays safe even on a shared device. All sensitive data must be stored using encrypted storage, with secure key management via the OS keystore and zero plaintext storage."

**Scope note (2026-10-18)**: The original description asks for two things that cannot be delivered as one feature: the visible lock, and the guarantee that stored records are unreadable at rest. The second requires changing how the app stores its data and is its own piece of work. Feature `016` therefore delivers the **lock spine** (Stories 1 to 5). The **at-rest guarantee** and the switch-over that carries existing data into it are delivered by feature `017-encrypted-storage`. Nothing is dropped: the requirement and success-criterion numbers left unused below are the ones that moved to `017`.

Strength and behaviour were settled with the project owner before this draft:

- The PIN is required once per cold start. Within a session the PIN has already opened, the device's own biometrics may re-unlock the app; biometrics can never open it from a cold start.
- A forgotten PIN is final for that phone **unless** another subject on the same device can still be unlocked, in which case that subject resets the PIN and every record is kept.
- Away-time is five bounded choices with no option to disable automatic locking.
- No history of security events is kept - only the failure count and the wait-until time needed to enforce a lockout.
- One hardening rule applies to this feature: the verifier that proves the PIN is never stored beside the data it protects.

## Clarifications

### Session 2026-10-18
- Q: If someone forgets their app PIN but their fingerprint or face is still enrolled on the same phone, should the fingerprint still let them in? -> A: **No.** The PIN is required once per cold start; after that, within the open session, the fingerprint can re-unlock (for example after the away-time expires). The fingerprint can never open the app from a cold start, so a forgotten PIN is final for that phone.

### Session 2026-10-20 (lock UX)
- Q: Should "Use my phone's PIN and Biometrics" and "App lock PIN" both be on at the same time? -> A: **No, not as two independent locks.** The app PIN *contains* the phone's factor: `LockController.submitPin` releases the key through `DeviceKeySession.require`, so the device prompt is already paid inside the PIN unlock. The device-auth switch is therefore a *preference* (consent to use the phone's own auth for sync and pairing), not a second lock. It lives in the **Privacy & security** group beside the app lock, is **hidden** whenever the active subject has a PIN (UI only — the consent record is never silently rewritten), is re-worded to "Protect my identity key", and becomes **read-only** with the text "Required for this shared space — the Owner turned this on." when the space Owner requires a PIN. A subject that just had its PIN set does not re-lock on the next frame (the `_justConfiguredKey` mark consumes exactly one `build()`); cold starts, subject switches, the away-time and on-demand locks still lock normally.
- Q: Where do the shared space's "require a PIN for everyone" rows live when US4 lands? -> A: **In the Privacy & security group**, above the member's own app-lock card, so the Owner's requirement reads as the source of the lock rather than a setting of its own.

- Q: If someone forgets their app PIN but their fingerprint or face is still enrolled on the same phone, should the fingerprint still let them in? -> A: **No.** The PIN is required once per cold start; after that, within the open session, the fingerprint can re-unlock (for example after the away-time expires). The fingerprint can never open the app from a cold start, so a forgotten PIN is final for that phone.
- Q: When a user resets after forgetting a PIN, and another profile on the same phone can still be unlocked, should that other profile be able to recover the lock (reset the PIN and keep all data), or must a forgotten PIN always end with data being erased? -> A: **The other unlocked subject can reset the forgotten PIN and keep all data.** Recovery is possible only while something on that phone can still be unlocked.
- Q: Should the app keep a history of security events (unlocks, failed attempts, lockouts, PIN changes)? -> A: **No history is kept.** Only the minimum state needed to enforce the lockout - the failure count and the wait-until time - may be stored, and a correct PIN MUST clear it.
- Q: How long should the app wait before locking itself while away? -> A: **Five bounded choices, no "never"** - immediately, 30 seconds, 1 minute, 2 minutes (the default), or 5 minutes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - My PIN is the way in, and guessing is punished (Priority: P1)

The user sets a 4-8 digit PIN for a profile or a shared space. Returning to the app asks for the PIN and shows nothing else. Wrong PINs lengthen the wait in a predictable, explainable way, and that wait cannot be escaped by force-quitting the app or by changing the phone's clock.

**Why this priority**: This is the visible security the user operates, and the lockout is the part that has to be right. A counter that resets on restart, or a countdown defeated by moving the clock, is not a lock.

**Independent Test**: Configure a PIN, fail it repeatedly with the app closed in between, and confirm the exact wait, the visible countdown, and that no sequence of reopens or clock changes shortens it.

**Acceptance Scenarios**:

1. **Given** a lock with a PIN, **When** the user returns after the allowed away-time, **Then** only the PIN screen is shown and no figure is visible behind it.
2. **Given** four failed attempts, **When** the fifth fails, **Then** the app waits 30 seconds with a visible countdown and the keypad is disabled.
3. **Given** nine failed attempts, **When** the tenth fails, **Then** the app waits 5 minutes; further failures double the wait up to 60 minutes, until a correct PIN is entered.
4. **Given** an active lockout, **When** the user force-closes and reopens the app, **Then** the remaining wait is unchanged.
5. **Given** a correct PIN, **When** it is entered, **Then** the app unlocks and the failure record is cleared.

---

### User Story 2 - My face or finger is enough (Priority: P2)

When the phone supports it and the user turns it on, the device's own biometric re-unlocks the app within a session the PIN has already opened, instead of typing the PIN again. It is a convenience within that session, not a second key: it can never open the app from a cold start. Cancelling or failing the prompt never costs an attempt and never becomes a dead end: the PIN is always there.

**Why this priority**: It is what makes the lock pleasant rather than punitive, and it is the behaviour most likely to regress into repeated prompts or into a second way in.

**Independent Test**: Turn biometrics on with a working fingerprint or face, cancel the prompt, then fail it, and confirm each time that nothing was counted as a wrong PIN and the PIN path is available; then close and reopen the app and confirm the fingerprint cannot open it.

**Acceptance Scenarios**:

1. **Given** biometrics turned on and the PIN already entered since the app was last started, **When** the app asks to unlock again (for example after the away-time), **Then** the operating system's own prompt appears and a success unlocks the app.
2. **Given** the app is being opened from a cold start, **When** biometrics are enabled, **Then** the PIN is still required and the fingerprint cannot open the app on its own.
3. **Given** the prompt is cancelled, or the biometric does not match, **When** the prompt returns to the app, **Then** no failed attempt was recorded and the PIN is offered.
4. **Given** the device cannot do biometrics, or none is enrolled, **When** the user looks for the setting, **Then** it is not offered as a working option and the reason is stated briefly.

---

### User Story 3 - It locks itself when I put the phone down (Priority: P2)

The app locks whenever it should: after being away longer than the allowed time, after a restart, when the phone is locked or the app is put in the background, when the user switches to another profile or shared space, and on demand.

**Why this priority**: A lock that exists only at first launch is one screenshot away from useless, and "being away" is exactly the shared-device situation this feature is for.

**Independent Test**: Set the away-time, background the app for just under and just over it, lock the phone while the app is open, and switch between two profiles - confirming the state in each case.

**Acceptance Scenarios**:

1. **Given** an unlocked app, **When** it has been in the background longer than the allowed time, **Then** returning to it asks for the unlock and shows no figures.
2. **Given** an unlocked app, **When** the phone is locked while the app is open, **Then** the away-time window starts, and if it has expired by the time the app is returned to, the app asks for the unlock.
3. **Given** two profiles where at least one has a lock, **When** the user switches profile or space, **Then** the subject being left is locked and entering a protected subject asks for its unlock.
4. **Given** any locked state, **When** the user requests it, **Then** locking immediately is available.

---

### User Story 4 - An Owner can require a lock for a shared space (Priority: P2)

The Owner of a shared space can require that everyone entering that space unlocks with their own PIN and, optionally, forbid the biometric shortcut for the space. A member sees the requirement and cannot turn it off. The Owner's own PIN is never involved, asked for, or shared.

**Why this priority**: It is the part of the original request about *other people's* access, and the part where an honest limit must be written down: each member is answered on their own device.

**Independent Test**: As an Owner, set the requirement; as a member, enter the space and confirm it is enforced and cannot be turned off; then confirm that nothing secret crossed between the two devices.

**Acceptance Scenarios**:

1. **Given** an Owner who requires a PIN for the space, **When** a member enters that space, **Then** the member must unlock before any space figure is shown, and cannot switch the requirement off.
2. **Given** an Owner who forbids the biometric shortcut for the space, **When** a member unlocks, **Then** only that member's PIN is accepted for the space.
3. **Given** a member whose device cannot meet a requirement, **When** it is not met, **Then** the app explains what is missing instead of dead-ending.
4. **Given** two devices in the space, **When** they exchange changes, **Then** no PIN, verifier, or key material is present in what travels.

---

### User Story 5 - I can see and manage it, and I am told what forgetting means (Priority: P3)

The user can turn the lock on and off, change the PIN, turn biometrics on and off, set the away-time, and see the current lockout status. And the consequences of forgetting the PIN are stated in advance: another profile on the same phone can reset the lock and keep every record, and when nothing on the phone can open the app the PIN cannot be recovered.

**Why this priority**: This is the management surface. It is P3 only because the app is still secure without it; the warning itself is a requirement, not a nicety.

**Independent Test**: Walk the security settings, fail the PIN to see the countdown, change the PIN, turn the lock off, and confirm the forgotten-PIN warning appears before a PIN is ever accepted.

**Acceptance Scenarios**:

1. **Given** a configured lock, **When** the user opens Settings then Security, **Then** the lock state, the biometric state, the away-time, and the lockout status are visible and changeable.
2. **Given** a forgotten PIN and another profile on the phone that can still be unlocked, **When** the user resets the forgotten PIN from there, **Then** every existing record is kept and no data is lost.
3. **Given** a forgotten PIN and nothing on the phone able to open the app, **When** the user is offered a way forward, **Then** they are told exactly what will happen before it happens, and nothing is silently destroyed.
4. **Given** a first-time user choosing a PIN, **When** they confirm it, **Then** they have already been shown what forgetting it would mean on their phone.

---

### Edge Cases

- **Force-quit during a lockout** - reopening must show the same remaining wait, never a reset.
- **The clock is moved backwards** while locked out - the wait must not shorten; moved forwards, the app must not be tricked into a different requirement than the schedule.
- **A second person uses the same phone and the same profile** - the only window is the away-time, so it must be short by default and changeable.
- **Biometrics are removed in the phone's settings** while still enabled in the app - the next unlock must not dead-end; the PIN must work and the app should say why.
- **A forgotten PIN with biometrics still enrolled** - the fingerprint must not become a way back in; the app stays closed on a cold start and the forgotten-PIN warning stands as written.
- **A forgotten PIN while another profile still opens the phone** - the lock can be reset and every record kept; the reset must not require the forgotten PIN.
- **The space's requirement and the member's inability to meet it** - explain, offer the PIN path, never a locked-out user with no option.
- **A notification or a link is opened while locked** - nothing behind the lock may be shown first.
- **Two profiles on the same phone** - one subject's PIN must unlock neither the other profile nor a shared space.
- **The app is uninstalled** - there is nothing to recover, and the user must never be led to believe otherwise.

## Requirements *(mandatory)*

### Functional Requirements

**PIN**

- **FR-007**: A PIN MUST be 4-8 digits and is set separately for a profile and for a shared space.
- **FR-008**: The verifier that proves the PIN MUST live in the device's secure storage, never beside the data it protects, never in the app's data store, and never in anything exchanged with another device. What may leave the device at all is FR-042 and FR-043.
- **FR-009**: Enabling a PIN requires entering it twice; changing or disabling it requires the current PIN.
- **FR-010**: Clearly guessable PINs MUST be refused with a plain message - all identical digits, simple runs, and a short known-weak list.
- **FR-011**: A correct PIN MUST unlock the subject and clear its failure record.
- **FR-012**: Changing a PIN MUST be possible without rewriting the records, so that a PIN change carries no risk of data loss.

**Lockout**

- **FR-013**: The wait after a failed PIN MUST follow a fixed, visible schedule: the 5th failure waits 30 seconds; failures 6 to 9 wait 30 seconds each; the 10th waits 5 minutes; each further failure doubles the wait, up to 60 minutes, until a correct PIN is entered.
- **FR-014**: Failure counts and the remaining wait MUST survive app closure, phone restart, and force-quit; none of those may reset or shorten them.
- **FR-015**: Changing the device clock MUST NOT shorten an active wait.
- **FR-016**: The wait belongs to the subject being unlocked: a lockout on one profile or space MUST NOT block another.

**Biometrics**

- **FR-017**: A biometric unlock MUST be offered only when the device supports it and an enrolment exists.
- **FR-018**: A successful biometric MUST unlock the app only within a session that the PIN has already opened since the last cold start; a biometric MUST NOT be able to open the app from a cold start on its own.
- **FR-019**: A cancelled, failed, or errored biometric prompt MUST NOT be counted as a wrong PIN, and MUST never leave the user without the PIN path.
- **FR-020**: Biometrics are enabled per subject; an Owner may forbid them for a space.
- **FR-021**: At most one **system** authentication prompt is shown per unlock event. A PIN entry is not a system prompt: a cold start costs one PIN entry plus at most one system prompt (the device's biometric, or the device credential), and the app never asks for the same factor twice in a row.

**Lock behaviour**

- **FR-022**: The app MUST lock at cold start, when the allowed away-time expires (default: 2 minutes), when the user switches to another profile or shared space, and on request. Leaving the foreground - the phone's screen locking, or the app being backgrounded - MUST start the away-time window rather than locking at once; `inactive` (the app switcher, an incoming call) MUST NOT start the window.
- **FR-023**: No figure, name, or record may be displayed while locked. The lock screen shows only the subject's own name and avatar and the single Unlock action (FR-037) - no list row, no notification body, and no deep-linked content.
- **FR-024**: The material released to the session by an unlock MUST NOT be retained while the app is locked, and locking MUST remove it from memory.
- **FR-025**: Unlock MUST feel immediate: under 300 ms from the user completing the prompt to the app being usable again.
- **FR-026**: A failed or cancelled unlock MUST leave the app locked, with the data still unavailable.

**Shared spaces**

- **FR-027**: An Owner MUST be able to require a PIN for everyone entering a space, and separately to forbid the biometric shortcut for that space.
- **FR-028**: A member MUST see the requirement and MUST NOT be able to switch it off.
- **FR-029**: The requirement MUST be satisfied with the member's own PIN or biometrics; the Owner's secret MUST NOT be needed, asked for, or shared.
- **FR-030**: Only the non-secret requirement may travel between devices; no PIN, verifier, or key material may ever be included in what is exchanged.
- **FR-031**: When a member's device cannot satisfy a requirement, the app MUST explain it and MUST offer the PIN path rather than a dead end.

**Profiles and spaces**

- **FR-032**: Security settings belong to a subject (one profile, or one shared space); a PIN or biometric setting for one subject MUST NOT unlock any other.
- **FR-033**: The away-time MUST be one of a short bounded list per subject - immediately, 30 seconds, 1 minute, 2 minutes (the default), or 5 minutes - and the app MUST NOT offer a choice to disable automatic locking.
- **FR-034**: Removing a profile or space MUST remove its security setting with it.

**Managing it**

- **FR-035**: Settings MUST offer: turn the lock on or off, change the PIN, turn biometrics on or off, the away-time, and the current lockout status.
- **FR-036**: The PIN screen MUST provide a numeric keypad, a clear error message, the lockout countdown, and the biometric option when enabled.
- **FR-037**: The lock screen MUST show the subject's avatar and name and a single Unlock action.
- **FR-038**: No factory, default, or service PIN may exist, and no hidden route may bypass the lock.

**Honesty, loss, and evidence**

- **FR-039**: Before a PIN is accepted for the first time, the user MUST be told what forgetting it means on their phone: another subject on the same device can reset the PIN and keep every record; when nothing on the phone can open the app, the PIN cannot be recovered and the only way forward through the app is to erase the local data and start clean, and the user MUST be told that before it happens.
- **FR-042**: Neither the PIN nor its verifier may appear in logs, crash reports, or any content leaving the device.
- **FR-043**: Every outgoing change, backup, and diagnostic MUST exclude PINs and verifiers.
- **FR-045**: Resetting a forgotten PIN MUST require another subject on the same phone to be unlocked first, and MUST keep every record. When nothing on the phone can open the app, the only way forward through the app is to erase the local data and start clean; the disclosure FR-039 fixes MUST have been shown before that happens.
- **FR-046**: The app MUST NOT keep a history of security events (unlocks, failed attempts, lockouts, PIN changes). Only the minimum state needed to enforce the lockout - the failure count and the wait-until time - may be stored, and a correct PIN MUST clear it.

**Unlocking**

- **FR-048**: The app PIN is an additional lock, never a replacement for the device's own authentication. Releasing the key material a subject needs MUST still require the device's own authentication (a biometric, or the device credential) at every cold start, so the app is gated by both the PIN and the device.

**Delivered by feature 017-encrypted-storage**

The original draft also required that the records themselves be unreadable at rest, that the material making them readable be 256-bit, hardware-held, non-exportable and absent from backups, that locking remove that material from memory, that the switch-over of existing data be reversible, and that the first launch after the switch-over show one skippable PIN invitation. Those requirements (the original FR-001 to FR-006, FR-024's data-key clause, FR-040, FR-041, FR-044, and FR-047) are carried by `017-encrypted-storage`, which depends on this feature. They are not dropped. FR-042 and FR-043 stay here: the PIN and its verifier are excluded from logs, backups, diagnostics and everything that travels, and 017 adds that same duty for its own key.

### Key Entities

- **Local security setting** - one per subject (profile or shared space): lock on or off, whether a PIN is set, the biometric setting, the away-time, and the version of the parameters. Non-secret, personal, never exchanged. The PIN's verifier, the failure count and the wait-until live in the device's secure hardware, never beside the data and never in anything sent to another device.
- **Space access requirement** - the Owner's setting for a shared space: PIN required, whether the biometric shortcut is forbidden, and the away-time for that space when the Owner sets one (unset means no such requirement, not a hidden default). Non-secret, and part of the space the way its name and currency are.
- **Local data** - everything the app already stores per profile and per shared space: amounts, expenses, medical bills, reimbursements, insurance details, currency and rates, and settings. This feature controls who may see it; changing how it is stored at rest is feature 017's job.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-004**: Unlock completes in under 300 ms after the user completes the last prompt of the unlock (the PIN entry, and the system prompt when FR-048 requires one), 95th percentile over at least 20 unlocks on the **reference device** (the oldest supported Android phone on hand; the exact model is recorded with the measurement).
- **SC-005**: Force-quitting the app during a lockout never shortens the remaining wait (10 out of 10 attempts).
- **SC-006**: The 5th and the 10th failure produce exactly 30 seconds and 5 minutes (plus or minus 1 second), and the countdown is visible.
- **SC-007**: Zero network traffic is needed for enrolment, verification, or unlocking; the feature behaves identically in airplane mode.
- **SC-008**: A first-time user enables a PIN in under 1 minute, without guidance, and without losing any record.
- **SC-010**: Not one plaintext occurrence of a PIN or verifier appears in the app's logs or diagnostics over a full test run.
- **SC-011**: With biometrics enabled, 0 out of 10 cold starts can be opened by biometric alone; every cold start requires the PIN.
- **SC-012**: With two profiles on one phone, resetting a forgotten PIN from the other profile keeps 100% of the records (0 lost).
- **SC-013**: The away-time setting offers exactly the five bounded choices and no option to disable automatic locking (0 such options present in the built app).

## Assumptions

- **The lock is opt-in per subject.** An install that never enables a lock keeps working normally; this feature never forces a PIN on anyone.
- **A lockout is a wait, not a trap** - the user may leave the app; they simply may not enter without waiting.
- **The default away-time is 2 minutes**, offered to the user rather than left for them to research.
- **Profiles and spaces are already subjects** - the app already separates a personal profile from a shared space, and this feature attaches a security setting to each; it does not invent a new concept of account.
- **The identity key, membership, and the change exchange are reused with one deliberate change.** The key is released only after both the app PIN and the device's own authentication (FR-048), and it is dropped whenever the app locks (FR-024). This feature adds nothing else to what travels between phones except the non-secret space requirement.
- **At-rest protection is a separate, dependent feature.** The guarantee that a copy of the stored data is useless (feature 017) builds on this lock; this feature alone makes the app ask for a PIN, it does not make the stored bytes unreadable.
- **One honest limit is written down:** an Owner's requirement is enforced on each member's own device and cannot constrain a modified device or a determined owner of the hardware.
- **Explicitly out of scope**: no security event history or audit log; no server-side security policy, remote wipe, or account recovery service; no change to the identity key, membership, the change exchange, or any existing sync guarantee from 015; no biometric enrolment of its own - the app uses what the phone already provides; and no change to how records are stored at rest (feature 017).
