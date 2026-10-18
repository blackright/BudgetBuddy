# Contract: Entity Identity (`syncGuid`) & Cross-Device Apply

**Feature**: 015-wire-device-sync | **Status**: the approved design (research R5).
**Supersedes**: the earlier draft "id-translation table"; there is **no** separate map collection.

Goal: two real phones must agree on *which row* a change is about, and each phone must store that row
under **its own** local integer `Id`, without ever overwriting its own data.

---

## 1. Identity rules

1. Every synced row has a stable `syncGuid` (UUID v4), unique per collection, generated at creation,
   never changed, identical on every device.
2. The **local `Id`** is private to a device. It is never transmitted and never appears in a payload.
3. A change is *about* an entity identified by `(contextSyncGuid, entityType, entitySyncGuid)`.
4. A cross-reference is a GUID, resolved to a local `Id` only at apply time.

---

## 2. Wire format changes

### 2.1 `ChangeRecord` (signed)
Fields on the wire and in the signature: `contextKind`, **`contextSyncGuid`**, `entityType`,
**`entitySyncGuid`**, `op`, `payload`, `hlcMillis`, `hlcCounter`, `deviceId`, `authorIdentityId`,
`signature`.
Fields **not** on the wire and **not** signed: `contextLocalId`, `entityLocalId` (local-only, set at
apply).

### 2.2 Envelope
```json
{ "type": "snapshot" | "ack", "contextSyncGuid": "<uuid>", "records": [ … ] }
```
(the old `contextLocalId` field is replaced by `contextSyncGuid`).

### 2.3 Payloads (all ten codecs)
- Emit `"syncGuid"` for the entity itself.
- Emit owning/foreign references as GUIDs:
  `sharedSpaceSyncGuid`, `budgetSyncGuid`, `expenseSyncGuid`, `linkedExpenseSyncGuid`,
  `familyMemberSyncGuid`, `providerSyncGuid`, `serviceTypeSyncGuid`.
- Do **not** emit the numeric `id` or numeric foreign keys.
- `profileId` (membership key / author profile) is carried per §4 R3.

---

## 3. Apply contract (`EntityApplier` + `SyncIdTranslator`)

Input: one decoded record with `contextSyncGuid`, `entityType`, `entitySyncGuid`, `op`, payload.

```
resolveLocalContext(contextSyncGuid) -> localSpaceId        # create SharedSpace if absent (bootstrap)
resolveLocalEntity(entityType, entitySyncGuid) -> localRowId # find by GUID, else allocate on insert
```

- **Upsert**: `localRowId = find(entityType, syncGuid)`; if found update, else insert (Isar assigns
  `Id`); then write GUID-refs via §4.
- **Delete**: `localRowId = find(entityType, syncGuid)`; tombstone/delete that row. A delete for an
  unknown GUID is a no-op (the row never existed locally).
- The stored `ChangeRecord.contextLocalId` = `localSpaceId`; `entityLocalId` = `localRowId`.
- Appliers must never write a foreign integer id into any local field.

Ordering (see `data-model.md` §4): Pass A resolves the space and writes rows in dependency order
(`SharedSpace` → `SharedMember` → `MonthlyBudget` → money rows → directory); Pass B resolves
cross-references.

---

## 4. Cross-reference resolution

| Case | Rule |
|---|---|
| R1 target GUID resolves locally | use its local `Id` |
| R2 target GUID absent in this batch | set field `null`/`0`; resolved on a later exchange (full log re-sent each round → self-healing) |
| R3 author-scoped `profileId` | re-point to the receiver's local profile for the same identity when known; else the receiver's own profile |
| R4 delete of a referenced target | dependent rows keep their local id until their own record updates the reference (or they are tombstoned) |

`profileId` on a `SharedMember` is the stable membership key (`sharedMemberKey(identityId)`) and is
**not** remapped; it is the join key that makes authorization work across devices (012
role-authorization §2).

---

## 5. Authorization is GUID-resolved

`_authorize` must load members for the **local** space id resolved from `contextSyncGuid` — never the
author's integer space id. This ensures the role/seal gate (`SpaceAccessGuard`,
`contracts/role-authorization.md`) fires for remapped contexts. A refusal is `droppedUnauthorized` and
nothing is applied or projected. A refusal is **not** counted as a kept-aside conflict — only a losing
merge is (FR-007/FR-008): the coordinator re-offers the same refused change on every discovery round, so
a per-attempt count would snowball into a nonsense tally while the data stays correct.

---

## 6. Determinism & idempotency

- Dedupe key: `(deviceId, hlcMillis, hlcCounter, entityType, entitySyncGuid)`.
- Merge head key: `(contextLocalId, entityType, entitySyncGuid)`.
- Merge winner: higher `(hlcMillis, hlcCounter)`; tie → `delete` beats `upsert`; tie → higher `deviceId`.
- Applying the same record twice changes nothing.

---

## 7. Bootstrap (US2)

A context GUID the receiver has never seen:
1. Pass A creates a local `SharedSpace` carrying that GUID, then its `SharedMember` rows (the member's
   own membership, and any others the Owner shared), then the rest.
2. The receiver's `PairedContext`/`SyncCursor` for the peer bind to the **new local** space id.
3. The space is fully usable offline immediately after (FR-007/SC-002).

---

## 8. Failure / edge rules

- Missing `entitySyncGuid` on a record → malformed → dropped, connection continues.
- Two different GUIDs accidentally both reference the same local row after user merge → last writer
  wins by HLC; the loser is a conflict (surfaced), never silently lost (FR-007).
- A record authored by an untrusted identity → `droppedBadSignature`.
- No local integer id ever crosses the transport (verifiable in tests by using deliberately different
  local ids on the two peers).
