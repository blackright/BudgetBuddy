# Phase 1 Data Model: Cross-Device Shared Spaces (Peer-to-Peer)

**Feature**: 012-cross-device-shared-spaces | **Date**: 2026-10-10
**Persistence**: Isar 3.1 (local-only) · **schemaVersion**: 13 → 15

---

## 1. Value Types

### 1.1 ContextKind

| Value | Meaning |
|---|---|
| `personal` | a personal profile context (sync deferred, US6/P3 — **not** exchanged in this feature) |
| `shared` | a shared space context (the exchange unit for this feature) |

Only `shared` contexts are paired/exchanged in v1 (FR-016 keeps personal profiles local-only).

### 1.2 PairingRole / Direction

| Type | Values |
|---|---|
| `offeredRole` | `SharedMemberRole.owner/editor/viewer` (the role the Owner grants at pairing) |
| `PairingDirection` | `presented` (inviting device shows QR) / `claimed` (joining device scans) |

### 1.3 HLC (Hybrid Logical Clock, non-persisted value)

| Field | Type | Meaning |
|---|---|---|
| `millis` | int | max(local wall clock, last seen millis) |
| `counter` | int | tiebreaker within the same millis |
| `deviceId` | String | stable per-install UUID; final tiebreaker |

Total order: compare `(millis, counter, deviceId)` lexicographically. Injected via the existing `clock_provider.dart` so tests are deterministic.

---

## 2. New Collections

### 2.1 Identity — *the local person, no account*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `username` | String | required, non-empty; **label only, not unique anywhere** (FR-001/004) |
| `publicKey` | String | base64 ed25519 public key (FR-001) |
| `keyAlgorithm` | String | `'ed25519'` |
| `localProfileId` | int | `@Index(unique: true)` — exactly one profile per identity (FR-016) |
| `fingerprint` | String | short human-comparable hash of `publicKey` (pairing confirmation, FR-004) |
| `createdAt`/`updatedAt` | DateTime | |

**Not stored here**: the private key. It lives only in `flutter_secure_storage` (keystore); Isar holds at most a reference/flag.

### 2.2 ConsentRecord — *local, revocable consent trace*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement (single active row) |
| `noticeVersion` | String | version of the consent text shown (FR-002) |
| `deviceAuthGranted` | bool | user enabled PIN/biometrics usage |
| `decidedAt` | DateTime | when decided/updated |
| `updatedAt` | DateTime | revocations just re-write this row |

Local only; never exchanged. Revocable at any time (FR-002).

### 2.3 PairedPeer — *another identity we have paired with*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `peerIdentityId` | String | `@Index(unique: true)` — fingerprint of the peer's public key |
| `peerUsername` | String | display label at pairing time |
| `peerPublicKey` | String | base64 ed25519 public key (used to verify signatures, pin transport) |
| `peerFingerprint` | String | shown next to the username (collision disambiguation, FR-004) |
| `pairedAt` | DateTime | |
| `lastSeenAt` | DateTime? | last successful exchange |

### 2.4 PairedContext — *which space is shared with which peer*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `peerId` | int | links `PairedPeer.id` |
| `contextKind` | `ContextKind` (`@enumerated`) | `shared` in v1 |
| `contextLocalId` | int | the `SharedSpace.id` |
| `peerRole` | `SharedMemberRole` (`@enumerated`) | local cache of the peer's role (authoritative copy is the signed membership) |
| `pairedAt` | DateTime | |
| `active` | bool | false once unpaired/tombstoned (FR-014 unpair) |

`@Index(composite: [peerId, contextKind, contextLocalId], unique: true)` — one pairing per peer per context.

### 2.5 PairingToken — *single-use, expirable, cancellable*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `token` | String | `@Index(unique: true)` random ≥128-bit |
| `spaceId` | int | the space being shared |
| `offeredRole` | `SharedMemberRole` (`@enumerated`) | role to grant (FR-005) |
| `direction` | `PairingDirection` (`@enumerated`) | presented or claimed |
| `peerFingerprint` | String? | bound on successful claim |
| `createdAt`/`expiresAt` | DateTime | expiry enforced (FR-005) |
| `usedAt` | DateTime? | single-use (a set value refuses reuse) |

### 2.6 ChangeRecord — *the signed, versioned unit of exchange*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `contextKind` | `ContextKind` (`@enumerated`) | `shared` in v1 (FR-006) |
| `contextLocalId` | int | `@Index(composite: [contextKind, contextLocalId])` — the space id |
| `entityType` | String (`@enumerated`-like) | `SharedSpace`, `SharedMember`, `MonthlyBudget`, `Expense`, `Reimbursement`, `MedicalBill`, `FamilyMember`, `MedicalProvider`, `MedicalServiceType`, `InsuranceProfile` (FR-010) |
| `entityLocalId` | int | the row's Isar id within the context |
| `op` | String | `upsert` or `delete` (delete ⇒ tombstone, retained) |
| `payload` | String | canonical serialized row (empty on delete) — produced by the entity's `SyncCodec` |
| `hlcMillis`/`hlcCounter` | int | HLC ordering (FR-007) |
| `deviceId` | String | stable per-install |
| `authorIdentityId` | String | `@Index` — the signer's fingerprint |
| `signature` | String | base64 ed25519 over canonical `{contextKind,contextLocalId,entityType,entityLocalId,op,payload,hlc*,deviceId,authorIdentityId}` |
| `createdAt` | DateTime | |

**Rules** (contracts/sync-protocol.md): appended by the `SyncRecorder` on every paired-context write; exchanged in HLC order; applied idempotently; delete tombstones retained so records are never resurrected (FR-006/007).

### 2.7 SyncCursor — *per-peer exchange watermark*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `peerId` | int | links `PairedPeer.id` |
| `contextLocalId` | int | the space id |
| `lastSentHlcMillis`/`lastSentCounter`/`lastSentDeviceId` | int/int/String | high-water mark sent |
| `lastReceivedHlcMillis`/`lastReceivedCounter`/`lastReceivedDeviceId` | int/int/String | high-water mark received |
| `conflictCount` | int | surfaced lost-change count (FR-013) |
| `updatedAt` | DateTime | |

---

## 3. Modified Entities

### 3.1 SharedMember — *becomes a signed, versioned authorization record* (R5)

| Field | Type | Change |
|---|---|---|
| `version` | int | **added** — HLC millis of the last change to this membership |
| `updatedAt` | DateTime | **added** |
| `authorIdentityId` | String? | **added** — signer (nullable on legacy/backfilled rows) |
| `signature` | String? | **added** — ed25519 over the membership fields + version |
| `revokedAt` | DateTime? | **added** — removal tombstone; prevents resurrection and blocks all later writes by the member |
| `sharedSpaceId` / `profileId` / `role` / `joinedAt` | — | unchanged; unique composite `[sharedSpaceId, profileId]` unchanged |

**Invariant**: a space still always has ≥ 1 non-revoked Owner (011 FR-006 maintained at apply-time; R5).

### 3.2 MonthlyBudget, Expense, Reimbursement, MedicalBill, directory rows

**Unchanged in shape** — no sync columns are added. Their changes travel as `ChangeRecord` payloads via per-entity `SyncCodec`s (R3). The exactly-one-context invariant (011 FR-003) is preserved: shared rows keep `sharedSpaceId != null`, `profileId == null`.

### 3.3 UserProfile — *unchanged*

No new columns. Personal profiles are **not** paired/exchanged in v1 (FR-016).

### 3.4 SavingsVault — *unchanged, personal-only*

Never paired or exchanged (FR-015).

### 3.5 MonthRateSeal / LiveRateSet — *unchanged, device-global*

Never exchanged; conversion stays local (FR-011, R6).

---

## 4. Exchange Model (peer-to-peer)

```
ChangeRecord (space S, authored by identity I, signed)
   │  verify signature with PairedPeer(I).publicKey
   │  verify author's membership @ HLC (signed SharedMember head)  → R5
   │  if author not a valid member/role at HLC  → drop
   ▼
merge by (hlcMillis, hlcCounter, deviceId); delete tombstone wins a concurrent upsert (R4)
   ▼
apply through the SAME repositories that local edits use (single write path)
   ▼
advance SyncCursor; increment conflictCount if a losing change was discarded
```

- **Unit**: per shared context, per entity record (FR-006). No whole-DB copy.
- **Order**: HLC total order; idempotent apply.
- **Determinism**: every device computes the same winner (FR-007).
- **No server**: exchange occurs only when peers are co-present on the LAN (R2).

---

## 5. Authorization Model (no server)

| Gate | Roles | Applies to |
|---|---|---|
| `SpaceAccessGuard.canView/canEdit/canManage` (`space_role_guard.dart:27-104`) | unchanged from 011 | local writes (reused verbatim) |
| `assertAuthorizedAt(change, membershipHead)` (new) | author must have held the required role **as of the change's HLC** | **apply-time** enforcement of every incoming change; a revoked/demoted member's later changes are refused (FR-008/009, SC-005) |
| `assertMonthEditable(member, sealed:)` (existing) | no role, if sealed | sealed-month content immutability on local + apply paths (FR-011, R6) |

Transfer semantics: a signed membership change promotes the new Owner and demotes the former to Editor (011 FR-014), ordered by HLC so both devices converge.

---

## 6. Backup / Recovery Model (R7)

```
BackupService.export():
  payload = { identity(keypair,username), contexts[changeLog + current rows] }   (canonical)
  key     = Argon2id(passphrase)            → wrapped
          ⊕ generated 128-bit recovery code → wrapped
  archive = version header + salt + nonce + AES-256-GCM(payload)
  → user saves the file locally or emails it to themselves (app never transmits)

BackupService.import(file, secret):   # secret = passphrase OR recovery code
  unwrap key → decrypt → restore Identity + contexts → require re-pairing for live exchange
```

---

## 7. Data Migration Plan (steps are immutable once shipped)

| Step | Type | Contents | Phasing |
|---|---|---|---|
| **14** | additive | create `Identity`, `ConsentRecord`, `PairedPeer`, `PairedContext`, `PairingToken`, `ChangeRecord`, `SyncCursor`; add `SharedMember.version/updatedAt/authorIdentityId/signature/revokedAt` | ships first; zero data movement; no existing amount touched |
| **15** | idempotent backfill/guard | stamp pre-existing `SharedMember` rows with `version = 0`, `authorIdentityId = null`, `revokedAt = null` so apply-time checks are consistent | data-shape only |

`schemaVersion` 13 → 15. **No monetary amount, seal or month total is rewritten** (011 SC-003 preserved).

---

## 8. Validation Rules Summary (traceable to spec)

| Rule | FR/SC |
|---|---|
| Identity = username + device keypair; no email/password/account/server; one profile per identity | FR-001/016 |
| Device-native auth optional + warned; consent recorded locally, voluntary + revocable | FR-002 |
| All 011 operations work offline with no peer; co-presence only converges | FR-003 |
| Pairing co-located only (QR + LAN); binds username↔key; fingerprint shown; no directory/search/uniqueness | FR-004 |
| Pairings single-use, expirable, cancellable; no remote entry; duplicates refused | FR-005 |
| Peer-to-peer, per-context/record, versions + tombstones; never a whole-DB copy | FR-006 |
| Deterministic merge, identical on both devices; no whole record silently lost; conflicts surfaced | FR-007, SC-002 |
| Signed/versioned membership; removal wins; removed member's later changes never applied; no cooperation needed | FR-008, SC-005 |
| 011 role matrix holds at apply-time, not just UI | FR-009 |
| Whole month exchanges as the space's single month (budget/income/expenses/medical/reimbursements) | FR-010 |
| Sealed month content-immutable everywhere; local conversion; identical totals | FR-011, SC-004 |
| User-held encrypted backup; restore via passphrase OR recovery code; app never transmits it | FR-012, SC-007 |
| Sync state visible ("waiting for peer"/converged); retry on co-presence; conflicts surfaced; no half-apply | FR-013, SC-001 |
| Leave / unpair / wipe defined; last-Owner rule preserved | FR-014 |
| Vault stays personal-only | FR-015 |
| No data leaves a device except a user-initiated backup; no cloud/telemetry | FR-017, SC-008 |
