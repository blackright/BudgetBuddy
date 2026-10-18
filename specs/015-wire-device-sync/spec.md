# Feature Specification: Live Device Sync (Deliver Cross-Device Changes)

**Feature Branch**: `[015-wire-device-sync]`

**Created**: 2026-10-17

**Status**: Draft

**Input**: User description: "When I add a paired contact to a shared space (or invite someone), their phone never sees the space — it stays on my phone only. The whole peer-to-peer sync machinery was built and tested in feature 012, but nothing in the running app ever starts it, so two real phones never actually exchange anything. Wire it up so a change made on one paired device actually reaches the other when the two are on the same network, including the very first time a device learns of a space it has never seen."

## Purpose

Feature 012 (`cross-device-shared-spaces`) designed and proved the entire peer-to-peer sync
model: a local identity, in-person pairing, signed-and-versioned changes, a deterministic merge
rule, apply-time role enforcement, sealed-month immutability, a sync cursor per peer and context,
a local-network transport, a sync-status surface, and per-entity codecs/appliers for the shared
month. All of it is covered by tests that drive two in-memory peers through the exact protocol.

Feature 014 (US7) then added "People": a user pairs a contact and can add that contact to a space,
granting a signed membership and recording the pairing.

What was never delivered is the **runtime wiring**. Nothing in the running app ever discovers a
peer, opens a connection, or runs an exchange, and the sync-status surface is inert. The result,
observed on two real phones: the membership an Owner grants after adding a contact stays on the
granting phone, and the other phone never sees the space. The same silence would apply to every
other change (an expense, a medical bill, a reimbursement).

This feature delivers the missing runtime layer so that **a change made on one paired device
actually reaches the other**. It is deliberately a *delivery/wiring* feature: it adds no new sync
protocol, no new merge rule and no server. It starts the existing machinery at
the right moments, drives it from the user's real paired devices, materializes a shared context the
receiving device has never seen, drives the status surface honestly, and keeps every guarantee 011
and 012 already made (offline-first, role safety, sealed-month immutability, privacy: no cloud, no
server, no relay).

To make that work across two real databases it also adds the one thing 012's protocol was missing: a
stable identity code (`syncGuid`) on every shared record, so both phones agree which record a change
is about and each phone writes it under **its own** local row number without overwriting its own
data (an additive migration — no existing amount, seal, total or row number changes). See the
Clarifications above and `research.md` R5.

The model stays **peer-to-peer and co-location-only**: two devices exchange changes only while both
are open and on the same local network (Wi-Fi or a phone hotspot). There is no remote sync, no
background service, and nothing ever leaves the two devices.

## Clarifications

### Session 2026-10-17

- Q: Is this a new sync protocol or wiring of the existing one? → A: **Wiring.** The protocol, merge rule, authorization, sealed-month rules, codecs and transport already exist and pass tests (012). This feature adds the runtime orchestration: when to discover, when to connect, which contexts to exchange, how to trust a peer, how a device that has never seen a context receives it, and how the status surface is driven.
- Q: When does exchange happen? → A: **Automatically, while the app is open and a paired peer is reachable on the same local network.** No background service and no always-on process (012's deliberate trade-off). Changes made while the peer is away travel at the next co-presence.
- Q: How does a device that has never seen a space get it? → A: The **granting device drives the first delivery**. Because 012 already exchanges the space and membership directory rows (not only month data), the receiving device materializes the space, the membership and the contents from the granting peer's snapshot. This is the reported gap and is in scope.
- Q: Does this cover personal (non-shared) profiles too? → A: **No.** Shared contexts (shared spaces) only. Personal-profile cross-device sync stays deferred, exactly as 012's US6 left it.
- Q: Are backup/recovery, unpair/leave/wipe and onboarding in scope? → A: **Not re-scoped here.** They belong to 012's US1/US5 and are delivered (or still pending) elsewhere. The one thing this feature must respect is that unpairing or leaving a space stops future delivery for that context (FR-010).
- Q: Manual "Sync now" button, or automatic? → A: **Automatic** while co-present. A manual trigger is not required by any story; the status surface (US3) is how the user sees where they stand.
- Q: If three people share one space but only two pairs of their phones are ever paired, should a phone accept changes written by the third person it has never paired with? → A: **No.** Exchange is strictly **pairwise** — only with your own paired contacts. A device never forwards another member's changes to a third device, and a change travels only directly between the two devices that share the paired context. Sharing a space among several people therefore means every pair pairs directly (People pairing from feature 014 makes that one quick scan, with no space required).
- Q: Should the changes travelling between the two phones be encrypted as they cross the local network, so that someone else on the same Wi-Fi cannot read the amounts? → A: **Yes.** The link must be **confidential as well as authenticated**. Peer identity alone is not enough: the two phones may sit on a shared or guest network, and constitution V protects sensitive data from being visible to anyone who is not meant to see it.
- Q: When your phone has nothing left to send, should it say "up to date" even though the other phone is not around, or should it keep saying "waiting for peer"? → A: **"Up to date" whenever nothing is pending.** "Waiting for peer" means exactly *"you have changes that have not been delivered yet"* and nothing more; with nothing pending the indicator stays quiet even when no peer is nearby. (This resolves the earlier contradiction between SC-005 and the one-phone-open edge case.)
- Q: Where should that sync state appear so you can actually find it when you need it? → A: **On the shared-space money screen, beside the month**, and the existing entry stays in that space's settings. It is deliberately per space (a phone can be up to date in one space and behind in another), not a device-wide sign in global Settings.
- Q: Two real phones store the same row under different internal row numbers. How can a change made on one be recognised as *the same record* on the other, so a member's edit to an Owner-created row merges instead of creating a duplicate — and so an incoming space cannot overwrite the receiving phone's own rows? → A: **Give every shared record a stable identity code (a `syncGuid`) that is the same on every device.** Changes and their references travel by that code, never by a device-specific row number; each phone looks up (or creates) its **own** local row for that code. This was approved by the user (Option "per-entity syncGuid in payloads") because the 012 wire format carried only local row numbers, which is why it could only ever pass in tests where both sides happened to use the same numbers. It adds one small identity field per shared entity (an additive migration) and changes how changes and payloads are identified on the wire; it does **not** add a new sync protocol, merge rule, or a server, and it preserves every 012 guarantee (signatures, dedupe, deterministic merge, apply-time authorization).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - My phone and their phone stay in step when we're together (Priority: P1)

Two paired people open the app while on the same Wi-Fi (or one phone's hotspot). A change either of
them makes in a shared space — a new expense, a corrected medical bill, a reimbursement, a budget
change — shows up on the other phone within moments, with no button to press, and both phones show
the same totals.

**Why this priority**: This is the core promise of cross-device shared spaces and the reason the
feature exists. Without it, everything 012 built is unreachable by real users.

**Independent Test**: Two paired phones on the same network, both with the app open. On phone A add
an expense in the shared space; verify it appears on phone B with no user action and that both show
identical space totals. Repeat in the other direction.

**Acceptance Scenarios**:

1. **Given** two paired phones on the same network with the app open, **When** either party edits a shared month within their role, **Then** the other phone reflects the change automatically and no duplicate copy appears.
2. **Given** both phones making different edits while apart, **When** they are next co-present with the app open, **Then** both converge to the same content, each change present once, under the documented deterministic rule.
3. **Given** an exchange interrupted (app closed mid-transfer), **When** the phones are next co-present, **Then** the exchange resumes and converges with nothing lost and nothing duplicated.
4. **Given** a medical bill entered on one phone while apart, **When** the phones converge, **Then** the bill, its patient share, its insurer lifecycle state and its reimbursement effect all appear unchanged on the other phone.

---

### User Story 2 - The space I add someone to actually arrives on their phone (Priority: P1)

As the Owner of a space, I add a paired contact (or invite someone) to the space. Their phone has
never seen that space. When our phones are next on the same network with the app open, the space —
with their correct role and everything already in it — appears on their phone.

**Why this priority**: This is the exact gap the Owner reported, and it is the one case a
within-a-space edit cannot cover: a device cannot exchange a context it does not yet know exists, so
the granting device must be able to bootstrap it. Without this, a brand-new member can never join.

**Independent Test**: Owner A adds paired contact B to a space that B has never seen; with both
phones on the same network and the app open, verify the space appears on B with the correct role and
identical contents.

**Acceptance Scenarios**:

1. **Given** Owner A and paired contact B, **When** A adds B to a space (by picking the contact or by scanning an identity code) and the two phones are next co-present with the app open, **Then** the space and B's membership appear on B with the role A chose.
2. **Given** the space already contains budget, income, expenses, medical bills and reimbursements, **When** it first arrives on B, **Then** all of that content arrives with it and B's totals match A's.
3. **Given** a space is being bootstrapped onto B, **When** the transfer is interrupted part-way, **Then** B never shows a half-applied space and completes on the next co-presence.
4. **Given** B receives a space it has never seen, **When** B re-opens the app later, **Then** the space is still there and continues to stay in step (transition to US1).

---

### User Story 3 - I can see whether my phone is up to date (Priority: P2)

Where I look to understand my devices — beside the month on the shared-space money screen, and in
that space's settings — I see an honest state: "waiting for peer" **only while I
still have a change the other phone has not received**, "in progress" while exchanging, "up to date"
once there is nothing pending (even if the other phone is away), and a visible count when a
conflicting edit was kept aside. It reflects reality — it never claims "up to date" while a change
is still pending, and it never nags "waiting for peer" when there is nothing to send.

**Why this priority**: Without a server, sync that is silent is indistinguishable from data loss. A
truthful state is what lets a person trust the feature instead of re-entering data.

**Independent Test**: Take the peer offline and make a change; verify "waiting for peer". Bring the
peer online with the app open; verify the state clears to "up to date".

**Acceptance Scenarios**:

1. **Given** a change that has not yet reached a peer, **When** I look at the space, **Then** a "waiting for peer" state is shown.
2. **Given** both phones co-present, **When** the exchange completes, **Then** the state clears to "up to date".
3. **Given** two edits to the same record that could not both win, **When** the phones converge, **Then** the kept-aside count is visible rather than the change being silently discarded.
4. **Given** a peer that cannot be found because the network blocks discovery, **When** I still have a change it has not received and I look at the space, **Then** the state says "waiting for peer" and never a false "up to date".
5. **Given** nothing pending, **When** the other phone is away and I look at the space, **Then** the state says "up to date" and does not claim "waiting for peer".
6. **Given** a shared space with a change still pending, **When** I open that space's money screen, **Then** the "waiting for peer" state is visible beside the month without opening any settings.
7. **Given** two shared spaces, one fully delivered and one still behind, **When** I move between them, **Then** each space shows its own state — "up to date" for the first and "waiting for peer" for the second.

---

### User Story 4 - It still works offline and nothing leaves my phone without a peer (Priority: P2)

With no paired device reachable — no network, or nobody co-present — everything works exactly as it
does today, all edits are saved locally and queued, and nothing is sent anywhere. Data moves only
between two paired phones that are co-present and both open. There is no cloud, no server, no relay
and no telemetry.

**Why this priority**: The offline-first and privacy-first principles (constitution III and V) are
non-negotiable, and delivery must not weaken them. This is also what makes the feature trustworthy.

**Independent Test**: With a paired space and no peer reachable, use the app fully offline (enter,
edit and seal months) and verify complete function and that nothing is sent; then bring the peer
co-present and verify everything converges.

**Acceptance Scenarios**:

1. **Given** a device with no network and no peer reachable, **When** a member enters, edits and seals months offline, **Then** every operation works exactly as it does today.
2. **Given** no paired peer reachable, **When** the app is used, **Then** no data is transmitted and no cloud/server/relay is contacted.
3. **Given** an unpaired device on the same network, **When** it attempts to reach the app, **Then** it cannot supply or receive any financial data.
4. **Given** a member leaves a space or is unpaired, **When** the phones are next co-present, **Then** no further changes for that space are delivered to or from that phone.

---

### Edge Cases

- **Only one phone has the app open**: nothing exchanges until both are open and co-present, then both converge; the side holding undelivered changes shows "waiting for peer", and a side with nothing pending shows "up to date".
- **A change made while the other phone is closed**: queued locally, delivered at the next co-presence with both open; never lost.
- **Network reachable but peers can't find each other** (e.g., a guest Wi-Fi with client isolation, or the network blocks peer discovery): the side holding undelivered changes shows "waiting for peer" and never a false "up to date"; a side with nothing pending shows "up to date". A phone hotspot that both devices join is a valid same-network case.
- **Interrupted transfer** (app closed, connection dropped mid-exchange): resumes at the next co-presence; a context is never left half-applied and no change is duplicated.
- **Duplicate delivery** (the same change arriving twice, or from two paths): idempotent; no duplicate record appears.
- **A device that missed many changes** (closed for a long time, or a brand-new member): catches up fully in one exchange; totals match the other side.
- **Sealed month travelling to a device with no matching live rate data**: the receiving device re-renders the sealed totals from its own sealed inputs; totals are numerically identical and no sealed content can change (011/012 preserved).
- **Two people edit the same record while apart**: one documented deterministic rule picks the winner on both phones; the losing change is kept aside and surfaced, never silently dropped, and no whole record vanishes.
- **A member removed or demoted while their phone is offline**: at the next co-presence the newer signed membership wins and the removed member's later changes are never applied by any peer; removal never requires the removed phone's cooperation.
- **Three members, only two pairs paired**: a change made by a member whose phone you never paired with does not reach you, and no partial space appears — you keep the full space you already have, minus that person's pending edits. Pairing the missing person (Settings → People) is one scan and closes the gap.
- **An unpaired or unknown device on the network**: its changes are refused at apply time; it can neither read nor write financial data.
- **Someone else on the same Wi-Fi listening in**: the link between two paired phones is encrypted, so a listener sees only unreadable traffic and recovers no amount; a device that cannot prove it holds a paired contact's key is turned away before any financial data is sent to it.
- **Same identity restored on a second device**: treated as the same identity, so the two copies are ordinary concurrent editors governed by the deterministic rule.
- **Two people with the same username**: unaffected — the pairing-time key/fingerprint remains the identity, not the label.
- **Both phones on different spaces' networks / different spaces**: exchange is per context; a change in one space never leaks into another.
- **Very large space history** being bootstrapped to a new member: arrives in one catch-up; may take longer than a small change but must complete without a half-applied state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: While two paired devices are open and on the same local network, each device MUST automatically exchange its pending changes for every shared context they have in common, with no user action.
- **FR-002**: Exchange MUST be bidirectional and idempotent: a change delivered twice, or by more than one path, MUST NOT create a duplicate record, and a change present on either side MUST end up on both.
- **FR-003**: A device that has never seen a shared context (for example, a space it was just added to) MUST receive and fully materialize that context — the space, the receiving member's role, and the contents — on the next co-presence, driven by the device that holds it. A context MUST never be left half-materialized.
- **FR-004**: A change MUST NOT be applied unless its author is a known paired contact whose key is trusted and the change is permitted for that author's role at the moment it is applied — enforced at apply time, not only in the user interface (011/012 role matrix preserved).
- **FR-005**: A sealed month's content MUST remain immutable through the delivery path on every device, and a sealed month MUST re-render identical totals on both devices from each device's own sealed inputs (011/012 preserved).
- **FR-006**: Delivery MUST be peer-to-peer and per context. A whole-device or whole-database copy MUST NOT be the unit of exchange, a record from a context the two devices do not share MUST NOT be exchanged, and there MUST be no server, cloud or relay.
- **FR-007**: With no paired device reachable, the entire application MUST keep working exactly as it does today and MUST NOT transmit anything; unsent changes MUST queue locally and converge at the next co-presence.
- **FR-008**: The application MUST show an honest **per-context** sync state for a shared context — at least "waiting for peer", "in progress", and "up to date", plus a visible count of kept-aside conflicts — that reflects reality and clears on convergence. "Waiting for peer" MUST mean exactly *"this device has a change the peer has not received"* and nothing more: it MUST NOT be shown while nothing is pending, and "up to date" MUST NOT be shown while any change is still pending. The state MUST be visible on the shared-space money screen beside the month, and it MUST remain available in that space's settings.
- **FR-009**: Exchange MUST be automatic but MUST NOT require a background service or an always-on process; it occurs while the application is open and a paired peer is reachable.
- **FR-010**: Unpairing a device or leaving a space MUST stop future delivery for that context; a departed or unpaired device MUST NOT continue to send or receive that context's changes.
- **FR-011**: Delivery MUST be resilient: an interrupted or partial exchange MUST never leave a context half-applied, MUST resume or re-run cleanly, and a device that missed changes MUST catch up fully at the next co-presence without loss or duplication.
- **FR-012**: Only changes authored by a paired, known contact whose key is trusted MUST be accepted; any other device, even one able to reach the application on the network, MUST NOT supply or receive financial data.
- **FR-013**: Delivery MUST preserve every existing guarantee of features 011 and 012: personal money never crosses into shared money, the savings vault is never synced, sealed content is immutable, and the last-Owner and role rules hold on every device.
- **FR-014**: Exchange MUST be strictly **pairwise**: a device MUST send and receive only with a device it has paired with, MUST NOT forward another member's changes to a third device, and MUST accept a change only directly from the device that authored it. Sharing a space among several people therefore requires every pair of devices to pair directly; no phone may gain access to a space through a third phone.
- **FR-015**: The link between two paired devices MUST be **confidential as well as authenticated**: changes MUST travel encrypted, a device MUST NOT send financial data over a link whose other end has not been proven to hold the paired contact's key, and it MUST NOT accept a change from an unproven end. A change MUST be readable only by the two paired devices that share it.

### Key Entities *(include if feature involves data)*

- **Paired contact (peer)**: a person's device identity that this device has paired with, holding the peer's public key (the trust anchor) and username label. Only these devices may exchange changes (FR-004/FR-012).
- **Paired context**: an explicit link that says "this peer shares this local context (a shared space), in this role". It is the unit of exchange; only paired contexts are delivered (FR-006).
- **Shared space**: the shared container that must travel to a device that has never seen it, so it can be materialized on first delivery (FR-003).
- **Membership**: a person's role (Owner/Editor/Viewer) and join information within a space; signed and versioned, and part of what travels so the receiving device knows its own role (FR-004).
- **Change (outbox item)**: one versioned, signed change to a single record, with a monotonic time and an author; the thing that is queued, delivered and applied (FR-002/FR-011).
- **Stable identity code (`syncGuid`)**: a device-independent code carried by every shared record (and referenced by changes and cross-references), so both phones agree which record a change is about while each stores it under its own local row number. The mechanism that makes FR-002/FR-003 work across two real databases (research R5).
- **Delivery progress (per peer and context)**: the record of how far each side has exchanged, used to catch up and to count kept-aside conflicts (FR-008/FR-011).
- **Sync state (displayed)**: the derived, user-visible state — waiting / in progress / up to date / conflicts(n) (FR-008).
- **Monthly budget, expense, medical bill, reimbursement, and directory rows**: existing 011 entities, unchanged in meaning; this feature defines only how they travel between paired devices.
- **Savings vault**: remains personal-only and is never delivered (FR-013).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Two paired phones on the same network converge a change with zero user action within 30 seconds of being co-present, in 100% of observed changes.
- **SC-002**: A space an Owner has just added a member to appears on the member's phone — with the correct role and identical contents — within 60 seconds of the two phones being on the same network with the app open, in 100% of attempts.
- **SC-003**: Across repeated and interrupted exchanges, 100% of changes are delivered exactly once: no change is lost and no record is duplicated.
- **SC-004**: With no paired device reachable, 100% of existing application functionality works and zero bytes are transmitted; the full 011/012 offline behaviour passes unchanged.
- **SC-005**: The displayed sync state matches reality in 100% of tested states — it shows "waiting for peer" whenever a change is still pending, clears to "up to date" once nothing is pending (even with no peer reachable), and never reports "up to date" while a change is pending.
- **SC-006**: In 100% of enforcement tests, a change from an unpaired or unauthorized device is refused at apply time, and no sealed month's content changes through the delivery path on either phone.
- **SC-007**: In 100% of concurrent-edit scenarios, both phones converge to the identical final content under the documented rule, and no whole record is silently lost.
- **SC-008**: In 100% of security tests, a third device on the same network recovers no financial amount from the traffic between two paired phones, and a device that cannot prove it holds a paired contact's key is refused before any financial data is sent to it or accepted from it.

## Assumptions

- **Builds on 012's machinery.** The identity, pairing, signed-and-versioned changes, deterministic merge, apply-time authorization, sealed-month immutability, per-peer/context progress, the rules that turn each record into and out of a change, the local-network transport, and the sync-status surface already exist and are proven by tests. This feature adds the runtime orchestration that starts the existing machinery for real devices, plus the stable per-record identity code (`syncGuid`) the protocol needs to work across two real databases; it introduces no new sync protocol, merge rule or server. The `syncGuid` is one additive field per shared entity (and the corresponding change to what identifies a record on the wire); it rewrites no existing amount, seal, total or row number.
- **Co-location is required.** Devices exchange only while both are open and on the same local network (Wi-Fi, or a phone hotspot both devices join). There is no remote join, no relay and no cloud (012's accepted trade-off for zero infrastructure and maximum privacy).
- **No background service.** Exchange runs while the app is open; changes made while the peer is away travel at the next time both are open and co-present.
- **Shared contexts only.** Shared spaces are delivered; personal (non-shared) profiles remain local and their cross-device sync stays deferred (012 US6).
- **Out of scope here.** Backup/recovery, unpair/leave/wipe tooling and onboarding belong to 012's US1/US5 and are not re-scoped by this feature, except that unpair/leave must stop delivery (FR-010).
- **Local-network capability is already available.** The application already includes the network permissions and dependencies the transport needs; no new privilege is introduced.
- **Version tolerance.** Devices ignore change types they do not know, so a newer phone stays compatible with an older one rather than failing.
- **Identity labels are not unique.** The pairing-time key/fingerprint remains the identity; usernames stay labels.
- **"In step" means equal content and equal numeric totals**, not identical on-screen glyph formatting across locale or OS.
