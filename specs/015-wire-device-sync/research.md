# Phase 0 Research: Live Device Sync (Deliver Cross-Device Changes)

**Feature**: 015-wire-device-sync | **Date**: 2026-10-17
**Status**: All unknowns resolved. No NEEDS CLARIFICATION remain.

Source-of-truth codebase facts verified on 2026-10-17 against `lib/` and `test/` (file:line cited).

---

## Starting facts (verified, these are why the feature exists)

- `syncRecorderProvider` (`lib/features/sync/providers/sync_recorder_provider.dart:14`) builds
  `SyncRecorder(IsarHelper.instance, clock: HlcClock(deviceId: …))` with **no `signer`**, and
  `SyncRecorder._append` returns `null` immediately when `_signer == null`
  (`lib/features/sync/repositories/sync_recorder.dart:430-431`). So in production **no `ChangeRecord`
  is ever written** — the change-log is completely inert, not merely undelivered.
- `SyncEngine` (`lib/features/sync/repositories/sync_engine.dart`), `LanTransport` and
  `LanTransportHost` (`lib/features/sync/transport/lan_transport.dart`) have **zero construction
  sites in `lib/`** (only in tests). Nothing discovers, connects or exchanges.
- `SyncStatusNotifier` methods (`syncing/converged/waitingForPeer`) are **never called** in `lib/`;
  `SyncStatusChip` (`lib/shared/presentation/widgets/sync_status_chip.dart`) reads the single global
  `syncStatusProvider` and is mounted once (`space_settings_section.dart:473`), so it is inert.
- The existing tests (`test/features/sync/convergence_integration_test.dart:37-40`, merge/tombstone/
  sealed/authorization tests) always give **both in-memory peers the same space id `1`** and the same
  entity ids. Nothing ever exercises distinct ids per device — the exact gap the `syncGuid` redesign
  (R5) closes.

---

## R1. Runtime orchestration shape — a `SyncCoordinator` service driven by providers

**Decision**: Add a `SyncCoordinator` (`lib/features/sync/repositories/sync_coordinator.dart`) that
owns the *when/which/how* of running the exchange for real devices, and starts/stops with the app
lifecycle. It:
1. Starts a `LanTransportHost` (advertise + accept) while the app is open.
2. Runs a **bounded discovery loop** via `LanTransport.discover()`.
3. For each discovered `PeerAdvertisement` that matches a known `PairedPeer`, opens a connection and
   runs the exchange for every shared context that peer shares (R4).
4. Handles **inbound** connections from the host symmetrically.
5. Drives the per-context status (R6) around every exchange.

The coordinator is plain Dart over the `Transport`/`SyncEngine` abstractions, so it is unit-testable
with `FakeTransportHub` and no sockets.

**Rationale**: Keeps the "what" (protocol/engine/transport) untouched and localises the missing
"when to run" in one testable class, matching 012's stated design ("the app constructs one while a
pairing or exchange screen is open", `lan_transport.dart:245-247`). Providers supply its
dependencies reactively (unlocked keypair, trusted peers).

**Alternatives considered**: starting transports from widgets (scattered, untestable) — rejected;
a background service/plugin (violates FR-009 and constitution III/V) — rejected.

---

## R2. Signing in production — attach a session key to the recorder

**Decision**: Introduce `syncSessionProvider` (`lib/features/sync/providers/sync_session_provider.dart`)
that yields a `SyncSession` (the unlocked `SimpleKeyPair` + the local `Identity`) **once per app
session**, obtained through the existing `unlockedKeyPairProvider`
(`lib/features/pairing/providers/pairing_providers.dart:127`) so there is at most one keystore
prompt per launch (the same key `AppLockGate`/pairing already use). `syncRecorderProvider` then
**watches the session** and returns a `SyncRecorder` with an `Ed25519ChangeSigner`
(`lib/features/sync/repositories/change_signer.dart:21`) when a session exists, and the current inert
recorder when it does not. `syncEngineProvider` and `syncCoordinatorProvider` depend on the same
session.

`spacesRepositoryProvider` already watches `syncRecorderProvider`
(`lib/features/spaces/repositories/spaces_repository.dart:520`), so it rebuilds with the signing
recorder automatically; no feature repository changes are required.

**Rationale**: The change-log must be signed by the local identity to be verifiable on the peer
(012 R5). Unlock-once-per-session matches the existing security model (private key never stored in
Isar; released only behind device auth). Keeping the inert recorder when locked preserves 011's
behaviour and its tests exactly.

**Alternatives considered**: signing lazily at send time (would let an unlocked session sign old
records, but splits the HLC/author stamps from signing and complicates dedupe) — rejected as more
complex for no gain; storing the key (violates V) — rejected.

**Note**: with device auth *off* (allowed, warning-only, FR-002) the session unlocks with no prompt;
that is the existing, user-chosen behaviour and is unchanged here.

---

## R3. Trust seeding — the engine trusts exactly the paired peers

**Decision**: `syncEngineProvider` builds `SyncEngine(IsarHelper.instance, trustedKeys: {peerIdentityId: SimplePublicKey(peerPublicKey) for each PairedPeer}, clock: HlcClock(deviceId), guard: SpaceAccessGuard())`, watching `pairedPeersProvider`
(`lib/features/pairing/providers/pairing_providers.dart:19`) so a new/removed pairing rebuilds the
engine. The session's own identity is **not** added to the trusted map (a device never accepts its
own records over the wire).

**Rationale**: `SyncEngine._verify` requires an author key in `_trustedKeys`
(`sync_engine.dart:225-240`); `PairedPeer.peerPublicKey` is exactly that key, established at pairing.
This realises FR-004/FR-012/FR-014 ("only a paired, known contact is accepted") without new storage.

**Alternatives considered**: a separate trust store — rejected (duplicates `PairedPeer`).

---

## R4. Exchange over the existing engine — one connection per peer, per-context rounds

**Decision**: Reuse `SyncEngine.exchange` unchanged for the **initiator**, and add one small
**responder** entry point that learns the context from the first envelope:
`Future<int> respond(TransportConnection connection, {required int? peerId})`. A session with peer P is:

```
initiator (the dialing side):           responder (the accepting side):
for each local shared context C          loop:
  with P:                                   await respond(connection, peerId)
    engine.exchange(conn, initiator:true,     // reads first 'snapshot', learns its
                    contextSyncGuid:g,         // contextSyncGuid, resolves the local
                    peerId:peerId)             // context, applies it, replies its own
                                              // snapshot, waits for 'ack', returns
                                          until the connection closes
close connection
```

`respond` is a thin wrapper over the existing responder branch of `exchange`. Under the GUID redesign
(R5) the wire envelope carries `contextSyncGuid` (the space's stable id), which the responder resolves
to **its own** local context before replying — so a peer can answer for a context it identifies by GUID
rather than a device-specific integer.

**Pairwise filter (FR-014)**: the initiator sends only **records it authored itself** for context C
(filter `authorIdentityId == myIdentity`), never a record it received from a third device. This is
what makes "no forwarding through a third phone" true, and it is what lets the receiving side apply
foreign-authored records without ever re-broadcasting them.

**Both sides dial**: because each side only sends its own authored records, both directions must run
(each peer discovers and dials the other). Concurrent duplicate exchanges are harmless: `applyIncoming`
is idempotent (dedupe by `(deviceId, hlc, entityType, entitySyncGuid)`, see R5).

**Rationale**: Reuses the exact tested round protocol (SC-003 exactly-once) with the smallest possible
addition. A connection-per-peer with sequential rounds preserves message ordering on each stream.

**Alternatives considered**: a fresh connection per context — more sockets for no benefit; a
multi-context session loop inside `exchange` — larger engine change; re-broadcasting peers' records —
violates FR-014.

---

## R5. Stable entity identity (`syncGuid`) + GUID-based apply *(the approved layer)*

**Problem**: 012 identifies rows — in the signed record (`contextLocalId`/`entityLocalId`), in the
signed canonical bytes (`change_signing.dart:13-24`), in the envelope, and inside every payload
(`expense_codec.dart:16-34`, `reimbursement_codec.dart:13-24`, `monthly_budget_codec.dart:13-25`, …) —
by **local integer row ids**, and the appliers write them back verbatim
(`entity_applier.dart:76-216`). The engine's dedupe, `headFor`/merge and conflict logic all key on
`(contextLocalId, entityType, entityLocalId)` (`sync_engine.dart:291-301, 86-104`). Real phones have
different ids, so:
1. an incoming context's rows can **collide with and overwrite** the receiver's own rows; and
2. two phones can never agree that a row edited on one is the *same row* on the other — a member's
   edit to an Owner-created expense would be stored as a **second expense**, and apply-time
   authorization (`_authorize` filters members by `record.contextLocalId`, `sync_engine.dart:256-260`)
   would query the wrong local members and **silently skip the role/seal gate**.

**Decision (user-approved: "per-entity syncGuid in payloads")**: make identity **device-independent**.

1. **Every synced entity carries a stable UUID** `syncGuid` (new `String syncGuid` with a unique
   index) on all ten collections: `SharedSpace`, `SharedMember`, `MonthlyBudget`, `Expense`,
   `Reimbursement`, `MedicalBill`, `FamilyMember`, `MedicalProvider`, `MedicalServiceType`,
   `InsuranceProfile`. Generated on creation (`sync_guid.dart`), never changed, backfilled by
   migration step 17 for existing rows.
2. **Records and payloads identify entities by GUID, not by local id.** Each codec serialises the
   entity's `syncGuid` and every cross-reference as a **GUID** (e.g. `Expense.budgetSyncGuid`,
   `Reimbursement.expenseSyncGuid`, `MedicalBill.linkedExpenseSyncGuid/familyMemberSyncGuid/
   providerSyncGuid/serviceTypeSyncGuid`, and the owning `sharedSpaceSyncGuid`); the numeric local
   `id` and numeric foreign keys are **not** put on the wire.
3. **`ChangeRecord` identity becomes GUID-based.** The record carries `contextSyncGuid` (the space)
   and `entitySyncGuid`; `entityType` and `op` are unchanged. The signed canonical bytes
   (`change_signing.dart`) cover `contextSyncGuid`/`entitySyncGuid` **instead of** the local
   `contextLocalId`/`entityLocalId`, so a signature computed on one device verifies on another even
   though the two digitise the row with different local ids. `contextLocalId`/`entityLocalId` are
   kept on the stored row as **local-only** bookkeeping (set at apply), not part of the signature.
4. **The engine resolves and groups by GUID.** `SyncIdTranslator`
   (`lib/features/sync/domain/sync_id_translator.dart`) turns a GUID into the local row id — returning
   the existing row's id when present, else allocating a fresh local id on insert. Dedupe, `headFor`,
   the merge head and cursor keys switch from the local id to `entitySyncGuid`; `_authorize` resolves
   the local context from `contextSyncGuid` before loading members, so the role/seal gate fires.
5. **Two-pass apply, in dependency order.** Within one incoming snapshot: (pass A) resolve the local
   space for `contextSyncGuid` (create it from the incoming `SharedSpace` row when absent, matched by
   its own `syncGuid`), then apply `SharedSpace` → `SharedMember` → `MonthlyBudget` →
   `Expense`/`Reimbursement`/`MedicalBill` → directory rows, resolving each entity's local id via its
   GUID; (pass B) rewrite every cross-reference by resolving its GUID to the local id (NULL/0 when the
   target is genuinely absent). Because each round re-sends the full log
   (`recordsForContext` returns all records, `sync_engine.dart:79-83`) and apply is idempotent, a
   forward reference that is missing in one batch is resolved by the next exchange — the design is
   self-healing.
6. **Deletes** resolve the GUID to the local id and tombstone that row; the GUID→entity binding
   survives (a later re-create upserts the same local row / a fresh one).
7. **`syncGuid` index is the map.** No separate translation table is needed: the unique `syncGuid`
   index on each collection *is* the GUID→local lookup; the `SyncIdMap` idea from the earlier draft is
   dropped.

**Why not keep the origin's integer id as the identity**: collisions with the receiver's own rows and
no cross-device sameness (problem 2 above). **Why not a separate id-map table keyed by origin ints**:
it still cannot tell that device B's integer id 12 is the same row the Owner created, because the
wire row's integer id is arbitrary per device; a GUID carried in the payload is the only thing both
devices agree on, and it matches 012's own precedent (`SharedSpace.syncGuid` in the original draft).

**Rationale**: Correct on real devices, additive/immutable migration, and it keeps every 012 property
that matters — signatures still verify across devices (now over GUIDs), dedupe/cursors are stable,
merge stays deterministic, and apply-time authorization still runs. It is a real change to all ten
codecs, the signing canonical bytes, the `ChangeRecord` shape and the engine's identity keys, plus
test fixtures — the honest footprint of making the tested-in-memory protocol work on two real
databases.

**Alternatives considered**: canonical-origin-id + reverse map (smaller wire change but requires every
write path to stamp a canonical id and maintain a reverse map — more bookkeeping, rejected by the
user); scope-to-bootstrap-only (narrows US1, rejected).

### R5a. Bootstrap of a never-seen context (US2)

When the member's phone receives a context GUID it has never seen, the incoming `SharedSpace` record is
applied first (pass A), creating a **new local `SharedSpace`** with the same `syncGuid`, followed by
`SharedMember` rows (so the member's own membership — and, where the Owner granted it, others — exist
locally) and then the money/directory rows. This closes the 014 gap where pairing adopted the
presenter's `spaceId` without creating a local `SharedSpace`
(`pairing_service.dart` `acceptResult`): the space now materializes locally on first exchange. The
member's `PairedContext`/`SyncCursor` are (re)bound to the new **local** space id.

---

## R6. Honest per-context sync status

**Decision**:
- Replace the global `syncStatusProvider` with a **family keyed by local space id**
  (`StateNotifierProvider.family<SyncStatusNotifier, SyncStatusState, int>`); `SyncStatusChip` takes a
  `spaceId`. Migrate the one existing mount (`space_settings_section.dart:473`) and add the chip
  **beside the month** on the shared-space money screen (`dashboard_screen.dart` AppBar / beside
  `MonthNavigator`).
- `SyncStatusState` gains a `pending` count. Semantics (FR-008, SC-005):
  `syncing` while an exchange for the context is in flight; `waitingForPeer` **iff** `pending > 0`;
  otherwise `converged` ("up to date"), plus `conflictCount`. `pending` = the number of locally
  authored records for the context whose HLC is above the **lowest** `lastSent` watermark across the
  context's active peers (with no peers, any locally authored record counts as pending). The context
  is identified by its **local** space id (post-translation), so the family key is stable regardless
  of which peer's GUID arrived first.
- The engine writes the **send-side** watermark (`lastSent*`) when it sends a snapshot
  (today only `lastReceived*` and `conflictCount` are written, `sync_engine.dart:322-346`); the status
  is derived from the persisted `SyncCursor` + the local change log, so it survives restarts and
  requires no new collection.
- `SyncCursor` is keyed by `(peerId, contextLocalId)` today (`sync_cursor.dart:15-22`); with
  translation the stored `contextLocalId` is always the **local** space id, so the cursor stays valid
  and no schema change is needed there.

**Rationale**: "Waiting for peer" must mean exactly "I still have something undelivered" and
"up to date" must not appear while anything is pending; deriving from cursors is the only
server-free source of truth. Per-space family satisfies US3 AC7 (up to date in one space, behind in
another).

**Alternatives considered**: an in-memory-only status (lost on restart; can't distinguish pending
offline) — rejected; a device-wide status (contradicts FR-008) — rejected.

---

## R7. Lifecycle & battery — no background service

**Decision**: `main.dart` starts the coordinator after the first frame and on `AppLifecycleState.
resumed`, and stops it (closes host, cancels discovery, drops connections) on `paused`/`detached`,
using the existing `_SealLifecycleObserver` pattern (`main.dart:40-47, 51-79`). Discovery runs in
bounded passes (default 5 s, 012's `Transport.discover` timeout) repeated at a modest interval while
the app is foregrounded and a session exists; no polling while backgrounded.

**Rationale**: FR-009 (automatic, but no always-on process) and battery hygiene. Co-location-only is
an accepted 012 trade-off.

**Alternatives considered**: an Android foreground service (violates FR-009/III) — rejected.

---

## R8. Confidentiality & authentication of the link

**Decision**: Reuse `LanTransport`/`LanTransportHost` as-is. `connect` opens a `SecureSocket` (TLS)
with `onBadCertificate: (_) => true` and then authenticates via a signed-nonce `hello`/`proof`
handshake verified against the **pinned** paired public key (`lan_transport.dart:122-212`); the host
signs the nonce with the session key and refuses unproven peers (`lan_transport.dart:310-362`). The
host runs only while the app is open (R7).

**Rationale**: This already satisfies FR-015/SC-008 — the channel is encrypted (a Wi-Fi listener
recovers nothing) and the peer is authenticated by the paired key before any financial data is sent
or accepted. Confirm with a test that a non-paired key's proof is refused and that the socket is TLS.

**Alternatives considered**: re-implementing transport encryption — rejected (already present and
correct).

---

## Outstanding deferrals (documented, not blockers)

- **Discovery cadence / battery tuning** — an operational param; default a few seconds per pass,
  refined during implementation.
- **Observability** — beyond the status chip, no logging/metrics are added (no telemetry per V).
- **Very large bootstrap size** — streamed per-record apply already bounds memory; no explicit cap is
  defined (tracked as an edge case in the spec).
