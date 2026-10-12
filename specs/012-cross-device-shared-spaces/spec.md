# Feature Specification: Cross-Device Shared Spaces (Peer-to-Peer)

**Feature Branch**: `[012-cross-device-shared-spaces]`

**Created**: 2026-10-10

**Status**: Draft

**Input**: User description: "Until now BudgetBuddy shares spaces between local profiles on one device only — invites are 'add another profile on this phone'. We want the real goal: a user on *another device* joins our shared space. Keep the app offline-first and privacy-first (constitution III and V)."

## Purpose

Feature 011 (`shared-financial-spaces`) established whole-month sharing and role-based membership **locally on one device**: the invite flow adds another *profile on the same device*, and 011 scoped invites as *"local-only in this iteration."* This feature extends the boundary from *one device* to **co-located peer devices**: the Owner of a shared space pairs with a person on their own device (on the same network, or in person), and the same single, non-duplicated financial month then lives on both devices and stays coherent.

The model is deliberately **peer-to-peer with no server, no cloud and no accounts**: identity is a local username secured by the phone's own authentication; devices find each other on the local network or by pairing in person; sync happens directly between devices when they are co-present; recovery is a user-held encrypted backup. Nothing — no amount, no month, no secret — ever leaves the two devices except a backup the user creates and stores themselves.

Everything feature 011 guaranteed must keep holding **on each paired device**: full offline function (constitution III), role-based enforcement that cannot be bypassed by tampering, the "past never changes" multi-currency promise (sealed months are content-immutable and re-render from each device's own sealed rate set with identical totals), personal money never crossing into shared money, and privacy-first, user-controlled behaviour (constitution III and V).

## Clarifications

### Session 2026-10-10

- Q: Continuation inside 011, or a separate feature? → A: A separate feature (this spec, 012) that *depends on* 011's data model, `SpaceAccessGuard` and `budgetContextProvider`, and extends 011's "one device" scope to **co-located peer devices**. Local-only spaces keep working exactly as 011 ships them.
- Q: Cloud or peer-to-peer? → A: **Path A — peer-to-peer**. No server, no cloud, no relay. Devices pair and sync only when co-located: same local network (LAN discovery) and/or in-person (QR pairing). There is no remote join and no always-on background sync.
- Q: What is an "account"? → A: There is no account and no email/password. Onboarding is a **username** plus a device-generated keypair. The username is a **label**; the real identity is the key. Access is gated by the **phone's own authentication** (device PIN/passcode and biometrics) through the OS — the app never creates or stores a PIN.
- Q: Is using the phone PIN/biometrics required? → A: **Optional and recommended.** The user may keep it off and still use the app; the app shows a clear warning that data is less protected. Consent is **voluntary and revocable**, recorded locally (GDPR-friendly; no forced bundling, no special-category consent trap).
- Q: How are people found without a server? → A: They are not searched. There is **no directory, no global uniqueness and no search**. People are bound to their key by **in-person QR pairing**; usernames are labels and may collide, disambiguated by the key/fingerprint shown during pairing.
- Q: Recovery without a server? → A: A **user-held encrypted backup**. The user exports an encrypted file (identity key + linked data), may keep it locally or send it to their own email, and restores on a new phone. The backup is unlocked by the user's **chosen passphrase OR a generated one-time recovery code** (both supported). The system never sees, stores or transmits the backup.
- Q: Account-to-profile mapping? → A: **One identity ↔ one profile (Q3=A).** Additional local profiles remain local-only and are never paired.
- Q: If two people edit the same record while apart, what wins? → A: One documented, deterministic rule applied identically on every device; no whole record is ever silently lost (see FR-007).
- Q: Should personal (non-shared) profiles also sync between a person's own devices? → A: Deferred/optional (P3, US6); not required by any earlier story.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - I set up my identity, my way (Priority: P1)

As a user, I start the app, pick a username, and (optionally) turn on a toggle that lets the app use my phone's own PIN and biometrics. Nothing else is required — no email, no account, no sign-up to a service.

**Why this priority**: There is no cross-device anything without an identity both devices can agree on, and the privacy-first constitution (III, V) makes the local, no-account identity the first-class choice.

**Independent Test**: On a fresh install, create a username with the device-auth toggle off, then again with it on; verify the app works in both cases, that the warning appears when it is off, and that no network/server is contacted.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** I choose a username, **Then** an identity is created locally with no email, no password and no server contact.
2. **Given** the onboarding consent notice about using the phone's PIN/biometrics, **When** I accept and enable the toggle, **Then** the app requires the phone's own authentication to open and to authorize sensitive actions (key access).
3. **Given** the same consent notice, **When** I decline or keep the toggle off, **Then** the app still works and clearly warns that my data is less protected; my choice is recorded locally and I can change it later.

---

### User Story 2 - The same space, on both our devices (Priority: P1)

As a member of a paired shared space, when the other device is on the same network I open that space and see the same single month — budget, income, every expense, every medical bill, every reimbursement — as the other member sees, fully offline-capable, and our changes converge whenever we are co-present.

**Why this priority**: This is the core value — coherent, non-duplicated shared money across two devices — and it must not regress any line of 011's offline promise.

**Independent Test**: Two paired devices on the same network; device B is offline while device A adds an expense; device B, still offline, adds a different expense. When both are back on the same network, verify both expenses exist once, on both devices, with identical space totals.

**Acceptance Scenarios**:

1. **Given** two paired devices reachable on the same network, **When** either member edits the month within their role, **Then** the other device reflects the change without any user action, and no duplicate copy ever appears.
2. **Given** a paired space on a device with no network and no peer reachable, **When** a member enters, edits and seals months offline, **Then** every operation works exactly as it does today on a single device, and the changes converge at the next co-presence.
3. **Given** two members who edited the same record while apart, **When** both are reachable again, **Then** both devices converge to the exact same final value, chosen by the documented rule, with neither member's whole record vanishing silently.
4. **Given** a medical bill entered on device A while apart, **When** the devices converge, **Then** the bill, its patient share, its insurer lifecycle state and its reimbursement effect all appear on device B unchanged.

---

### User Story 3 - I pair with someone on their own device (Priority: P1)

As the Owner of a shared space, I pair with a person on their own device — in person (QR) or on the same network — the pairing binds their username to their key, and they become a member with the role I chose.

**Why this priority**: Pairing is the mechanism that makes "another user, another device" real without any server, and it must behave under the same offline-first, tamper-resistant rules as everything else.

**Independent Test**: Owner pairs device A with device B in person by QR; the invited person becomes a member with the chosen role; when A and B next share a network, both list the member and the same role.

**Acceptance Scenarios**:

1. **Given** an Owner and a paired-capable space, **When** the Owner pairs a peer device (QR or LAN) and assigns a role, **Then** a single-use, expirable pairing is created and, once confirmed on both devices, the membership exists with that role and join date.
2. **Given** a completed pairing, **When** the devices are next co-present, **Then** the membership appears on both with the same role and join date.
3. **Given** a pairing that expired, was cancelled, or was already used, **When** it is presented, **Then** it is refused with a clear message.
4. **Given** a peer that is already a member or already has a pending pairing for the space, **When** the Owner tries to pair it again, **Then** the duplicate is refused.
5. **Given** two people whose chosen usernames are identical, **When** they pair, **Then** the pairing screen shows each key's fingerprint so the Owner confirms the right person before adding them.

---

### User Story 4 - Roles and the frozen past hold on every paired device (Priority: P1)

The role rules of 011 hold on both devices — enforced when changes are applied, not just hidden in the UI — and a sealed (closed) month is content-immutable on every device, converting with each device's own sealed rates to show identical totals.

**Why this priority**: Trust is the product. A role or a sealed month you can't trust on the other device is worthless, and 011's role/sealed promises must extend unchanged off-device.

**Independent Test**: On device B, a Viewer of a space attempts every write path directly (not via the UI); and the Owner seals a month on A; verify the Viewer's writes are never applied, and device B re-renders the sealed month with totals identical to A.

**Acceptance Scenarios**:

1. **Given** a Viewer of a space, **When** they attempt any write to the space from their device, **Then** the write is refused when changes are applied, even if they bypass the UI.
2. **Given** a one-Owner space, **When** the last Owner tries to leave or delete-while-money-exists from either device, **Then** the same protections as 011 block it.
3. **Given** a member demoted or removed by the Owner on device A, **When** the devices next converge, **Then** any later writes from the removed/demoted member are not applied by any peer, and the last-Owner/role rules of 011 hold unchanged.
4. **Given** a sealed shared month, **When** both devices re-render it in any currency, **Then** the amounts are identical on both, re-computed from each device's own sealed rate set, and no path can change any content of the sealed month.

---

### User Story 5 - I can back up, recover, unpair, and see my sync state (Priority: P2)

I can export an encrypted backup I keep myself (locally or in my own email) and restore my identity and data on a new phone; I can see whether my paired devices are up to date, and I can leave a space or wipe my identity.

**Why this priority**: Without a server, the user's own backup *is* recovery, and sync without transparency is indistinguishable from data loss.

**Independent Test**: Export a backup, restore it on a fresh install using the passphrase, then again using the recovery code; verify identity and data return. Then take a device offline, make a change, and observe a clear "waiting for peer" state that clears at the next co-presence.

**Acceptance Scenarios**:

1. **Given** a set-up identity, **When** I export a backup, **Then** I get an encrypted file I can store locally or send to my own email, and the system neither sees nor keeps it.
2. **Given** a backup file on a fresh device, **When** I restore it with my chosen passphrase OR the generated recovery code, **Then** my identity and linked data are restored and usable offline.
3. **Given** changes that have not yet reached a peer, **When** I view the space, **Then** a visible "waiting for peer" indicator is present and clears once the devices are co-present and converge.
4. **Given** a member who wants out, **When** they leave the space (observing 011's last-Owner rule), **Then** their local copy of the space's data is removed and no further changes for that space are exchanged with their device.
5. **Given** any user, **When** they wipe their identity, **Then** identity, key and local data are deleted and confirmed.

---

### User Story 6 - My personal profiles follow me (deferred, optional) (Priority: P3)

As a user with an identity, I can also pair my *own* second device to keep my *personal* (non-shared) profiles in sync.

**Why this priority**: Nice-to-have coherence, not the ask. The cross-device story is about reaching *other* users; personal sync is a stretch goal that must not delay or complicate the shared-space work.

**Independent Test**: (Deferred — track separately.) Pair my own two devices and confirm a personal profile's expenses converge between them offline-first.

**Acceptance Scenarios**:

1. **Given** a paired personal profile, **When** I add expenses on device A, **Then** they converge to my device B under the same profile, offline-first, with the same determinism guarantees as shared spaces.
2. **Given** a deleted or renamed personal profile, **When** my devices converge, **Then** the change propagates deterministically.

---

### Edge Cases

- **Two devices, no common network for a while**: each works fully offline (011 behaviour); changes queue locally and converge only when the devices are co-present. There is no remote sync and no push.
- **User removed while their device is offline**: at the next convergence the newer (signed) membership wins, and the removed member's later changes are never applied by any peer; the removed device drops the space's local copy when it learns of the removal — removal never requires the removed device's cooperation.
- **Two people pick the same username**: allowed (no directory guarantees uniqueness); pairing shows each key's fingerprint so the correct person is confirmed; the name is only a label.
- **Same identity restored on a second device via backup**: the restored device is the *same* identity; changes between the two are ordinary concurrent edits governed by the deterministic rule.
- **The pairing device is lost/broken**: recovery is the user's encrypted backup, not a server; without a backup the identity is unrecoverable by design (no server holds it).
- **Device-auth toggled off later**: the app remains usable with a clear warning; consent state is updated locally and is revocable at any time.
- **QR pairing in a public place**: pairing confirms fingerprints; a pairing is single-use and expirable, so an observed/old code cannot be reused.
- **LAN with no peer present**: no sync happens and nothing is exposed; discovery only exposes what is needed to pair, never financial data before pairing and mutual consent.
- **Sealed months and seal sets**: sealed content is exchanged once, then immutable everywhere; *conversion* always uses each device's own device-global seals — identical totals, no new conversion behaviour, in every currency (011 FR-012).
- **Home currency of the two devices differs from the space's currency**: rendering stays a pure derivation; nothing stored changes, and totals match because conversion is deterministic from the same sealed inputs.
- **Delete-then-recreate of the same name**: deletes are tombstones, so a recreate is a new record, never a resurrection of the deleted one.
- **A change keyed to a version that never landed** (stale device): handled by the deterministic rule; the devices converge — no partial record ever appears.
- **Two identities on one physical phone** (e.g., a shared household phone): each is its own local identity; a space always has exactly one Owner identity; the phone's own authentication still gates the app.
- **Unpairing**: unpairing stops future exchange; the user is asked whether to keep or delete the local copy of that space's data (detach vs delete).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Onboarding MUST create a local identity from a **user-chosen username** and a **device-generated keypair**; there MUST be no email, password, account registration or server contact.
- **FR-002**: App access and the identity key MUST be gated by the **device's native authentication** (phone PIN/passcode and biometrics) via OS facilities; the app MUST NOT create or store its own PIN. Using device auth MUST be **optional and recommended**, with a clear warning when off, and the app MUST remain usable without it. A **consent notice** MUST be shown and the user's accept/decline recorded **locally**; consent MUST be **voluntary and revocable** at any time. (GDPR by design.)
- **FR-003**: Every function of feature 011 MUST keep working fully offline with no network and no peer reachable — including entering, editing and sealing shared months, inviting a local profile, and switching contexts. Co-presence only adds convergence.
- **FR-004**: Two devices MUST join contexts by **co-located pairing**: in-person QR exchange and/or discovery on the same local network. Pairing MUST bind a peer's username to their **public key** and show a **fingerprint** for confirmation. There MUST be no directory, no global uniqueness and no search.
- **FR-005**: A space member MUST be added only by an Owner, by pairing, carrying a role. Pairings MUST be **single-use, expirable and cancellable**, refused when expired, cancelled, reused or duplicated; there MUST be no remote entry.
- **FR-006**: Sync MUST be **peer-to-peer**, per context (one profile or one shared space) and per record, with monotonic versions and **tombstones**. A whole-device or whole-database copy MUST NOT be the sync unit, and no record from another context MAY ever be exchanged. There MUST be no server or relay.
- **FR-007**: Concurrent edits to the same record from two devices MUST resolve by one documented, **deterministic** rule applied identically on both devices; deletes MUST be tombstones so records are never resurrected; a whole record MUST NEVER be silently lost; conflicts MUST be surfaced rather than silently merged away (FR-013).
- **FR-008**: Membership and role changes MUST be **signed and versioned**; when devices converge the **newest signed membership wins**. A removed or demoted member's later changes MUST NOT be applied by any peer. Removing or demoting a member MUST NOT require that member's device to cooperate. (No central authority: enforcement happens when each device applies changes.)
- **FR-009**: The 011 role matrix (Owner / Editor / Viewer; Owner-only actions; last-Owner guard; no non-member writes) MUST hold identically across paired devices, enforced when changes are applied and not only in the UI.
- **FR-010**: A shared space's whole month — budget, income and its override, expenses, medical bills (with the full insurance lifecycle) and reimbursements — MUST move/exchange as the space's single month, with no second copy anywhere (011 FR-007/008/013 preserved).
- **FR-011**: A sealed shared month MUST be **content-immutable** on every device and from every path; conversion MUST use each device's own device-global sealed rate set, producing totals identical on both devices with zero new conversion behaviour (011 FR-012 preserved).
- **FR-012**: The user MUST be able to **export an encrypted backup** of their identity key and linked contexts, and **restore it on a new device**, unlocked by the user's **chosen passphrase OR a generated one-time recovery code** (both supported). The backup MAY be stored locally or sent by the user to their own email; the system MUST NOT see, store or transmit it.
- **FR-013**: Sync state MUST be visible ("waiting for peer" / converged); pending changes MUST converge automatically at the next co-presence; the system MUST surface conflicts instead of silently dropping or merging them, and MUST never leave a record half-applied.
- **FR-014**: A member MUST be able to **leave** a space (last-Owner rule of 011 preserved); a user MUST be able to **unpair** (choosing to keep or delete the local copy of that space's data) and to **wipe** their identity and local data.
- **FR-015**: The savings vault MUST remain **personal-only** and MUST NOT be paired, synced or accepted by any shared space (011 FR-017 unchanged).
- **FR-016**: There MUST be **exactly one profile per identity** (Q3=A). Additional local profiles MUST remain **local-only** and MUST NOT be paired or exchanged.
- **FR-017**: No data MAY leave a device except a **user-initiated backup** the user controls. There MUST be no cloud, no server, no telemetry containing financial data, and no exchange of unlinked/unpaired contexts.

### Key Entities *(include if feature involves data)*

- **Identity**: a local username **label** + a device-generated keypair; gated by device-native auth; owns exactly one profile (FR-016). The private key lives in the platform keystore.
- **ConsentRecord**: a local record of whether device-auth use was accepted or declined, when, and under which notice version (FR-002).
- **PairedContext**: an explicit, per-item link between a local context (profile or shared space) and a **peer identity's public key**, established by co-located pairing. Only paired contexts exchange changes.
- **PairingToken**: a co-located, single-use, expirable, cancellable token carrying the offered role; exchanged by QR/LAN; never remote (FR-005).
- **SignedChange / Tombstone**: a versioned, signature-backed change record enabling deterministic merge and enforcement without a server (FR-006/007/008).
- **BackupArtifact**: an encrypted archive of the identity key and linked data, unlockable by a user passphrase or a generated recovery code; held only by the user (FR-012).
- **Membership** (space + profile + role + join date): the 011 entity, now signed/versioned and converging on both devices (FR-008).
- **MonthlyBudget, Expense, MedicalBill, Reimbursement, UserProfile, SharedSpace, SharedMember**: the 011 entities, unchanged in meaning; this feature defines how they travel between paired devices.
- **SavingsVault**: remains personal-only; never paired or exchanged (FR-015).
- **MonthRateSeal / LiveRateSet**: each device's existing global rate sets stay the conversion source of truth; never exchanged as part of a context (FR-011).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Two paired devices on the same network converge a change with zero user action within 30 seconds of being co-present, in 100% of observed changes.
- **SC-002**: In 100% of concurrent-edit scenarios, both devices converge to the identical final state under the documented rule, and no whole record is silently lost.
- **SC-003**: Every operation of feature 011 works on a device with no network and no peer (the 011 offline matrix passes unchanged on a paired space's device).
- **SC-004**: Both devices render the same sealed month's totals numerically identical in any currency, and no sealed amount changes from any path, on either device.
- **SC-005**: In 100% of enforcement tests, a removed or demoted member's later changes are never applied by any peer, while the last-Owner and role rules of 011 hold unchanged from either device.
- **SC-006**: A paired device's member appears on both devices within the next co-presence in 100% of valid pairings; expired, cancelled, reused and duplicate pairings are refused in 100% of attempts; pairing and first convergence complete in under 2 minutes in person.
- **SC-007**: A backup restores identity and data on a fresh device using the passphrase in 100% of attempts, and using the recovery code in 100% of attempts.
- **SC-008**: No financial data leaves the two paired devices in 100% of privacy tests, and no cloud/server is contacted at any point; the only outbound artifact is a user-initiated backup the user controls.

## Assumptions

- **Peer-to-peer only in this feature.** No server, cloud, relay or background service. A future feature MAY add a relay for remote devices, but it MUST NOT require changing this spec's story or data model — the design leaves that room.
- **Co-location is required to pair and to converge.** Discovery uses the local network; identity is confirmed by in-person QR with key fingerprints. There is no remote join and no always-on sync (this is the accepted trade-off for zero-infrastructure, maximum privacy).
- Merge rule: per-record deterministic last-write-wins over monotonic versions, with tombstones for delete (FR-007). Fine-grained per-field merging and a human conflict-resolution UI are out of scope for v1; a conflict is surfaced clearly and a re-edit on the converged devices supersedes.
- Device-native authentication is **optional**; when off, the app warns and remains usable. The identity key is still stored in the platform keystore.
- Backup requires a **portable secret** (passphrase and/or generated recovery code), because device auth cannot cross devices; both are supported (FR-012).
- Sealed months: content is exchanged once and immutable everywhere; conversion remains a pure, local derivation from each device's own global seal sets (FR-011) — this is how "totals are identical" stays compatible with 011's device-global market data.
- Local-only spaces keep working exactly as 011 ships them; the 011 invite flow (invite a local profile, offline) is unchanged for spaces that are not paired.
- Usernames are labels with no guaranteed uniqueness; the key/fingerprint is the identity, confirmed during pairing (FR-004).
- "Past never changes" across devices means *content* immutability of sealed months plus device-local deterministic conversion; it does not promise identical on-screen glyph formatting across locale/OS — only identical numeric totals.
- Building on 011's shipped `SpaceAccessGuard`, `budgetContextProvider` and role matrix; requires 011 to be complete (its months, roles and context seams are the exchanged payload).
- This spec extends 011's *single-device* scope to *co-located peer devices*; it does not add a cloud identity or account. Only `SavingsVault` scoping is explicitly untouched (FR-015).
