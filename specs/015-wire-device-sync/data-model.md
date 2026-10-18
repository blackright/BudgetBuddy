# Phase 1 Data Model: Live Device Sync (Deliver Cross-Device Changes)

**Feature**: 015-wire-device-sync | **Date**: 2026-10-17
**Base**: 012-cross-device-shared-spaces `data-model.md` (unchanged except as noted here).

This feature adds **no new collection**. It adds one column to each of the ten synced entity
collections and reshapes one existing collection (`ChangeRecord`) so identity is device-independent.
Every change is additive; migration step 17 (`schemaVersion 16 → 17`) backfills the new column.

---

## 1. Entity identity — `syncGuid` (NEW on 10 collections)

Every synced entity gains:

```dart
/// Device-independent identity of this row. Generated on creation, never changed,
/// unique across all devices. Records and payloads refer to the row by this value,
/// never by the local `Id` (research R5).
@Index()
String syncGuid = newSyncGuid();
```

Applied to: `SharedSpace`, `SharedMember`, `MonthlyBudget`, `Expense`, `Reimbursement`,
`MedicalBill`, `FamilyMember`, `MedicalProvider`, `MedicalServiceType`, `InsuranceProfile`.

**Invariants**
- `syncGuid` is a lowercase RFC-4122 v4 UUID (new `newSyncGuid()` in `sync_guid.dart`).
- Unique per collection. Two rows in one collection never share a GUID; a GUID is never reused.
- The **local `Id`** (`isar.autoIncrement`) remains the storage key and stays exactly as it is today;
  it is simply no longer the wire identity.
- On first sight of a foreign GUID, the receiving device inserts a row with a **fresh local `Id`** and
  that GUID. On later records for the same GUID, the same local row is updated.

> **Index is deliberately non-unique.** The index is a plain hash `@Index()` (generating
> `syncGuidEqualTo`), **not** `@Index(unique: true, replace: true)`. A unique index over a column
> whose pre-existing rows all share the default value is a startup/rebuild hazard: Isar would see
> many duplicate `''` entries (and with `replace: true` would silently *replace* rows). Uniqueness is
> instead held **by construction** (every row is born with a fresh `newSyncGuid()`, migration step 17
> stamps every legacy row exactly once) — the same pattern the codebase already uses for
> "must be unique but defaults are shared" columns. This matches the established 012 precedent.

> Why a column, not a separate map table: the `syncGuid` index *is* the GUID→local lookup
> (`isar.expenses.filter().syncGuidEqualTo(g).findFirst()`). A separate translation table would
> duplicate it (research R5 §7). This is a deliberate simplification of the earlier draft.

---

## 2. `ChangeRecord` — GUID identity (RESHAPED)

`lib/core/models/change_record.dart`. Identity fields change; the signing contract changes with them.

| Field | Before | After | Notes |
|---|---|---|---|
| `id` | `Isar.autoIncrement` | unchanged | local storage key |
| `contextKind` | enum | unchanged | `shared` in v1 |
| `contextSyncGuid` | — | `String` (new) | the owning space's `syncGuid`; **signed** |
| `contextLocalId` | signed, wire identity | **local-only** | resolved at apply to the local space id; excluded from the signature |
| `entityType` | `String` | unchanged | e.g. `Expense`; signed |
| `entitySyncGuid` | — | `String` (new) | the entity's `syncGuid`; **signed**; dedupe/merge key |
| `entityLocalId` | signed, wire identity | **local-only** | resolved at apply to the local row id; excluded from the signature |
| `op` | `String` | unchanged | `upsert` / `delete`; signed |
| `payload` | `String` | unchanged in type | canonical GUID-based JSON (see §3); signed |
| `hlcMillis`/`hlcCounter`/`deviceId` | signed | unchanged | ordering + tiebreak; signed |
| `authorIdentityId` | signed | unchanged | signer fingerprint; signed |
| `signature` | — | unchanged in type | ed25519 over the new canonical bytes |
| `createdAt` | — | unchanged | audit |

**Indexes**: keep the `(entityType, entityLocalId)` composite for local queries; add an index on
`entitySyncGuid` (and `contextSyncGuid`) for GUID lookups and per-context grouping.

**Signed canonical bytes** (`change_signing.dart:13-24`) become:

```dart
String changeCanonicalString(ChangeRecord r) => canonicalJsonEncode({
  'contextKind': r.contextKind.name,
  'contextSyncGuid': r.contextSyncGuid,      // was contextLocalId
  'entityType': r.entityType,
  'entitySyncGuid': r.entitySyncGuid,        // was entityLocalId
  'op': r.op,
  'payload': r.payload,
  'hlcMillis': r.hlcMillis,
  'hlcCounter': r.hlcCounter,
  'deviceId': r.deviceId,
  'authorIdentityId': r.authorIdentityId,
});
```

`contextLocalId`/`entityLocalId` are **not** signed, so each device may store its own values without
invalidating the signature. The signature still binds the exact business payload, so a change cannot be
tampered with in transit (SC-008/FR-004).

**Migration note**: no production database has `ChangeRecord` rows (the recorder was inert —
`sync_recorder.dart:430-431` before 015). Step 17 therefore does not need to preserve change-log rows;
any dev/test rows are cleared and the log rebuilds as changes are re-authored. Money rows and seals are
never touched.

---

## 3. Wire payloads — GUID references (RESHAPED, all ten codecs)

Each `SyncCodec.toJson`/`fromJson` stops emitting the local `id` and numeric foreign keys, and emits
GUIDs instead. The applier resolves each GUID to a local row (§4). Reference fields and their new
GUID field names:

| Entity | Local id field | Reference fields (int → GUID on the wire) |
|---|---|---|
| SharedSpace | `id` | `createdByProfileId` stays a local-ish value (see note) |
| SharedMember | `id` | `sharedSpaceId` → `sharedSpaceSyncGuid`; `profileId` unchanged (stable hash) |
| MonthlyBudget | `id` | `sharedSpaceId` → `sharedSpaceSyncGuid` |
| Expense | `id` | `sharedSpaceId` → `sharedSpaceSyncGuid`; `budgetId` → `budgetSyncGuid` |
| Reimbursement | `id` | `sharedSpaceId` → `sharedSpaceSyncGuid`; `expenseId` → `expenseSyncGuid` |
| MedicalBill | `id` | `sharedSpaceId` → `sharedSpaceSyncGuid`; `linkedExpenseId` → `linkedExpenseSyncGuid`; `familyMemberId` → `familyMemberSyncGuid`; `providerId` → `providerSyncGuid`; `serviceTypeId` → `serviceTypeSyncGuid` |
| FamilyMember / MedicalProvider / MedicalServiceType / InsuranceProfile | `id` | `sharedSpaceId` → `sharedSpaceSyncGuid` |

Each entity also emits `'syncGuid'` (its own identity).

**Notes**
- `profileId` on a `SharedMember` is already device-independent (`sharedMemberKey(identityId)`
  = `remoteProfileIdFor`, `shared_member_key.dart`) so it stays a plain value.
- `Expense.profileId` / `Reimbursement.profileId` / `MedicalBill.profileId`: for a shared row this is
  the *local* profile representation of the author. It is **not** used for authorization (that uses
  `SharedMember`), so on apply it is re-pointed to the receiver's local profile for the same identity
  where the identity is known, else to the receiver's own profile (see §4 rule R3). It is therefore
  carried as an author identity reference, not a row id.
- Amounts, currencies, dates, enums, booleans: unchanged and byte-identical (money guarantee holds).

---

## 4. Apply algorithm (engine) — two-pass, dependency-ordered

Per incoming snapshot, inside the existing per-record write transaction model (extended to a per-batch
transaction where safe):

**Pass A — establish identity, write rows**
1. Resolve the local space from `contextSyncGuid`:
   - If a local `SharedSpace` with that GUID exists, use its `Id`.
   - Else create a new `SharedSpace` from the incoming `SharedSpace` row (its own GUID), then use the
     new `Id` (bootstrap, US2).
2. Apply records in dependency order, each resolving/allocating its local row id by `syncGuid`:
   `SharedSpace` → `SharedMember` → `MonthlyBudget` → `Expense` `Reimbursement` `MedicalBill` →
   `FamilyMember` `MedicalProvider` `MedicalServiceType` `InsuranceProfile`.
   - Upsert: look up by `syncGuid`; if found, update that local row; else insert (Isar assigns `Id`).
   - Delete: look up by `syncGuid`; tombstone/delete the local row.

**Pass B — resolve cross-references**
3. For each written row, resolve every GUID reference to a local id:
   - R1: target GUID found locally → the local `Id`.
   - R2: target GUID not found → leave the field `null`/`0`; the target's own record arrives in a
     later round (every round re-sends the full log), and the next exchange re-applies and fixes it
     (self-healing, research R5 §5).
   - R3: author-scoped `profileId` fields → the receiver's local profile for the same identity when
     known, else the receiver's own profile.
4. Authorization (`_authorize`, `sync_engine.dart:253-289`) runs **after** step 1 so it loads members
   for the **local** space id; the role/seal gate therefore fires for remapped contexts
   (closes the security hole noted in R5).

**Idempotency & dedupe**: unchanged in spirit — dedupe by
`(deviceId, hlcMillis, hlcCounter, entityType, entitySyncGuid)`; merge head by
`(contextLocalId(local), entityType, entitySyncGuid)` with the existing deterministic rule
(higher `(hlcMillis, hlcCounter)` wins; at equal time `delete` beats `upsert`; else higher `deviceId`).

---

## 5. Sync status (in-memory, derived) — UNCHANGED SHAPE, per-context

No new collection. `SyncStatusState` (already in-memory) gains `pending` and is served per context:

```dart
class SyncStatusState {
  final SyncPhase phase;      // syncing | converged | waitingForPeer
  final int conflictCount;
  final int pending;          // # locally authored records above the lowest lastSent watermark
}
```

`syncStatusProvider` becomes `StateNotifierProvider.family<SyncStatusNotifier, SyncStatusState, int>`
keyed by the **local** space id. Semantics (FR-008/SC-005): `pending > 0` ⇒ `waitingForPeer`;
exchange in flight ⇒ `syncing`; else `converged`. Derived from the persisted `SyncCursor`
(`lastSent*`, `lastReceived*`, `conflictCount`) + the local change-log; survives restart.

---

## 6. Migration — step 17 (`schemaVersion 16 → 17`)

Additive and idempotent, in the existing `_applySteps` sequence:

```dart
await _step17AddSyncGuids(isar);
```

- Isar reconciles the schema on open, materialising the new `syncGuid` columns (empty for a row that
  predates the column — an initializer cannot run for a row that never had the field) and the new
  `ChangeRecord` columns before the step runs.
- `_step17AddSyncGuids` iterates each of the ten collections; for every row with an empty `syncGuid`,
  assigns `newSyncGuid()` and writes it back (batched `putAll`). Full backfill.
- `ChangeRecord`: any existing rows (dev/test only) are cleared, since identity changed and there is
  no meaningful way to derive the old rows' GUIDs; nothing monetary is stored there.
- Idempotent: a second run finds every `syncGuid` non-empty and writes nothing.
- **Preserved**: no monetary amount, seal, month total or existing `Id` is rewritten (011 SC-003).

---

## 7. Validation rules (from FRs)

- `syncGuid` must be non-empty and unique per collection (held by construction — every row is born
  with a fresh value and step 17 stamps every legacy row; the index itself is non-unique, see §1).
- A shared row's cross-reference GUIDs must either resolve locally or be left null/zero (never a
  foreign device's integer id — those never cross the wire).
- A record whose `entitySyncGuid` is empty is rejected as malformed (defensive).
- A record whose author is not in the engine's trusted set is dropped (`droppedBadSignature`); a record
  failing the role/seal guard is dropped as `droppedUnauthorized`.
- Exactly-one-context invariant on money rows (`profileId` xor `sharedSpaceId`) is preserved on apply.

---

## 8. Backward compatibility / states

- **Pre-015 rows on a phone**: get a fresh `syncGuid` at step 17; nothing else changes.
- **Two phones, one already paired (012) but never synced**: the first 015 exchange bootstraps the
  member's local `SharedSpace` from the Owner, then flows normally.
- **Three peers, one space**: the space is recognised as one because its `syncGuid` matches; pairwise
  exchanges never forward a peer's records (FR-014), so a member's change reaches another member only
  through a shared author's own authored records — by design.
- **Locked phone**: recorder is inert and the coordinator is stopped, so nothing is written or sent
  (011/FR-002 preserved).
