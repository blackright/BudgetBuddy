# Contract: Sync Protocol (signed change-log)

**Feature**: 012-cross-device-shared-spaces
**Covers**: FR-006, FR-007, FR-010, FR-013 · **Design**: research R3, R4, R6

Peer-to-peer, per shared context, per record. No server, no whole-DB copy.

---

## 1. Unit of Exchange — `ChangeRecord`

```
{ contextKind, contextLocalId, entityType, entityLocalId,
  op: upsert|delete, payload, hlcMillis, hlcCounter, deviceId,
  authorIdentityId, signature }
```

- Appended by the **`SyncRecorder`** seam on every write to a **paired shared context** (no feature code changes; writes still go through 011 repositories).
- `signature` = ed25519 over the canonical serialization of all fields above except `signature` itself.
- `delete` is a **tombstone** `ChangeRecord` (payload empty); retained, never purged, so records never resurrect.
- `personal` contexts are **not** recorded/exchanged in v1 (FR-016).

## 2. Ordering — Hybrid Logical Clock

- Each local change takes `HLC = (max(wallClock, lastSeenMillis), counter, deviceId)`.
- Total order = lexicographic `(hlcMillis, hlcCounter, deviceId)`.
- Deterministic and skew-tolerant; injected clock makes tests reproducible.

## 3. Exchange Loop (only while co-present on LAN)

1. On peer contact, compare `SyncCursor` high-water marks and request the range `(lastReceived, peerHead]`.
2. **Verify** each incoming record: signature (against `PairedPeer.publicKey`) → authorization (R5) → month seal (R6). Failing checks ⇒ dropped (never applied).
3. **Merge** by HLC order (§4); apply through the **same repositories** as local edits (single write path).
4. Advance `SyncCursor`; if a change lost to the local head, increment `conflictCount` and surface it (FR-013).
5. Repeat until both cursors are equal ⇒ **converged**.

**Idempotency**: applying the same `ChangeRecord` twice is a no-op (dedupe by `(deviceId, hlc, entityType, entityLocalId, op)`).

## 4. Merge Rule (deterministic)

- Winner per entity record = greatest HLC key; tie broken by `deviceId` (lexicographic). Every device computes the same winner (FR-007).
- **Delete beats a concurrent upsert** (tombstone wins) to prevent resurrection.
- An upsert strictly after a delete is a legitimate recreate.
- **No whole record is silently lost**: a losing change is discarded but counted and surfaced (FR-007, FR-013).

## 5. Coverage

Whole-month atomicity: a month's `MonthlyBudget` (budget/income) + `Expense` + `Reimbursement` + `MedicalBill` + directory rows exchange as the space's single month (FR-010). Each is its own `ChangeRecord`; the month is consistent once all its records are applied.

## 6. Sealed Months

- A sealed month's content is exchanged once (at/after seal); afterwards **no further change is accepted** on any device (`assertMonthEditable`, R6/FR-011).
- **Conversion stays local**: `MonthRateSeal`/`LiveRateSet` are device-global and **never** exchanged; identical sealed inputs + local conversion ⇒ identical totals (FR-011, SC-004).

## 7. Failure & Edge Cases

| Case | Behavior |
|---|---|
| Peer unreachable | No error; edit stays local; UI shows "waiting for peer"; converges on next co-presence (FR-013) |
| Interrupted transfer | Resumes from `SyncCursor`; no half-apply (records apply atomically per record; a partial range simply re-requests) |
| Bad signature | Record dropped; logged; never applied |
| Unauthorized author at HLC | Record dropped (see `role-authorization.md`) |
| Duplicate/replayed record | Deduped (idempotent) |
| Clock skew | HLC counter + deviceId tiebreak keep order deterministic |
| Concurrent conflicting edits | HLC winner applied; loser surfaced; no crash (no prompt in v1) |

## 8. Non-Goals

No server/relay/cloud · no background upload while peers are apart · no field-level/CRDT merge (record-level LWW, R4) · no sync of market data or vault.
