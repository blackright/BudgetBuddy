# Contract: Sync Runtime Orchestration

**Feature**: 015-wire-device-sync | **Scope**: when and how the (pre-existing) engine/transport run for
real devices. Complements 012 `contracts/sync-protocol.md` (the exchange protocol), which is unchanged.

Actors: **App** (owns the coordinator), **Coordinator** (`SyncCoordinator`), **Host**
(`LanTransportHost`), **Transport** (`LanTransport`), **Engine** (`SyncEngine`).

---

## 1. Lifecycle (FR-009, R7)

| App event | Coordinator action |
|---|---|
| App becomes foreground **and** a `SyncSession` exists (identity unlocked) | `start()` |
| App goes to background / detached | `stop()` |
| Session appears (unlock) while foregrounded | `start()` |
| Session disappears / identity locked | `stop()` |
| Unpair last context with a peer | host keeps running; that peer is simply no longer dialed/accepted |

`start()`: open the host (advertise) and begin the discovery loop.
`stop()`: cancel the discovery loop, close the host, drop all live connections. **No background
service exists**; while `stop()` has run, the app sends and receives nothing.

`start()` is idempotent; a second call while running is a no-op. `stop()` is idempotent.

---

## 2. Advertising & discovery (FR-001/003, R7)

- The host advertises a single service while running; the advertised payload is the local
  `Identity.fingerprint` (device identity), **not** any space id.
- Discovery runs in bounded passes (default timeout 5 s, 012's `Transport.discover`), repeated at a
  modest interval (default 10 s) while the app is foregrounded.
- A discovered `PeerAdvertisement` is **relevant** iff its `fingerprint` matches a `PairedPeer.peerIdentityId`
  whose pairing is active. Non-paired advertisements are ignored.
- `lastSeenAt` on the `PairedPeer` is refreshed on a successful exchange (FR-013).

---

## 3. Connection & handshake (FR-015, R8)

Every connection performs the existing TLS + signed-nonce handshake (`lan_transport.dart`):
1. TLS `SecureSocket` (self-signed, no certificate verification).
2. `hello`/`proof`: the connecting side signs a nonce; each side verifies the other's proof against the
   pinned `PairedPeer.peerPublicKey`.
3. Only after both proofs verify does the connection yield to the engine.

A connection whose peer is not a trusted `PairedPeer`, or whose proof fails, is **refused and closed**
before any financial data is read or written (SC-008). No data is sent in the clear.

---

## 4. Exchange sessions (FR-001/004/014, R4/R5)

For a live connection with peer P:

**Dialing side (initiator)** — for each local context C that P shares (from active `PairedContext`
rows):
```
await engine.exchange(connection,
    initiator: true, contextSyncGuid: spaceGuid(C), peerId: P.id)
```
`engine.exchange` sends a `snapshot` of **C's locally-authored records only**
(`authorIdentityId == myIdentityId`), applies P's reply, sends `ack`.

**Accepting side (responder)**:
```
loop until connection closes:
    await engine.respond(connection, peerId: P.id)
```
`respond` reads the first `snapshot`, resolves its `contextSyncGuid` to a local context, applies the
records, replies with its own C-local authored snapshot, and ends on `ack`. It then loops to serve the
next context C' the initiator dials on the same connection. A context whose local `PairedContext` is
**inactive** — unpaired, or a space this device has left — is **refused**: nothing is applied and
nothing is replied, so the round ends (FR-010, stop-delivery).

**Guarantees**
- **Pairwise-only (FR-014)**: a snapshot contains only the sender's own authored records; a record
  received from a third device is never re-sent. This is enforced at snapshot assembly, not by policy.
- **Terminating**: each context round completes on `ack` (012 protocol). A connection carries contexts
  sequentially; ordering per stream is preserved.
- **Idempotent**: a repeated or concurrent exchange applies nothing new (dedupe by
  `(deviceId, hlcMillis, hlcCounter, entityType, entitySyncGuid)`).
- **Both directions run**: since each side only sends its own records, both sides dial; the union of the
  two rounds converges the context (SC-001).

**Error handling**
- Connection drops mid-round → that context round aborts; the next discovery pass retries. No partial
  apply is visible (per-batch transaction, 012 §7).
- Unknown/incompatible record type → dropped (`droppedUnknownType`), connection continues.
- Bad signature → record dropped, connection continues, conflict bumped.

---

## 5. Status transitions (FR-008, R6)

Around each context round the coordinator drives the per-context notifier:
- On round start: `syncing`.
- Records applied from P: cursor `lastReceived*` advances (engine).
- Snapshot sent to P: cursor `lastSent*` advances (engine — new).
- On round end: recompute `pending`; emit `converged` (pending == 0) or `waitingForPeer` (pending > 0),
  carrying `conflictCount`.

The chip is **per space** (its local id), so one space can read "up to date" while another reads
"waiting for peer" (US3 AC7).

---

## 6. Non-goals / invariants

- No server, relay, cloud, or telemetry is contacted (Constitution III/V).
- No synchronization while the app is backgrounded or the identity is locked.
- No change to 011 money math; sync only moves existing rows.
- The transport never carries a local integer row id (see `entity-identity.md`).
