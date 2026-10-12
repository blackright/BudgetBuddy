# Phase 0 Research: Cross-Device Shared Spaces (Peer-to-Peer)

**Feature**: 012-cross-device-shared-spaces | **Date**: 2026-10-10
**Status**: All unknowns resolved. No NEEDS CLARIFICATION remain.

Source-of-truth codebase facts verified on 2026-10-10 against features 011/010/009 (`file:line` cited below).

---

## R1. Identity: local username + device keypair, one profile per identity

**Decision**: A new `Identity` collection holds `username` (label, not unique anywhere), an ed25519 **public key**, a `localProfileId` (exactly one profile, FR-016), and timestamps. The **private key never enters Isar**: it is generated on-device and stored in `flutter_secure_storage` (Android Keystore / iOS Keychain). App access is gated by `local_auth` (`authenticate` with `biometricOnly: false`, so the device passcode/PIN is accepted as fallback); on success a **session unlock** releases the in-memory copy of the key. The username is bound to the key by pairing (R2), not by any registry.

**Rationale**: This is exactly what the spec chose (no email/password, no account, no server). Constitution V already mandates native PIN/biometric auth; `local_auth` provides both from one API. Storing a raw key in Isar would defeat the keystore's hardware protection, so secure storage is mandatory. One-profile-per-identity (Q3=A) keeps pairing targets unambiguous and lets existing multi-profile installs keep extra profiles local-only with no migration pressure on 011's data.

**Alternatives considered**: PIN-derived key (PBKDF2 from a user PIN) — rejected: weak, and the spec explicitly says use the phone's own PIN/biometrics, not a self-managed secret. Storing an encrypted key blob in Isar — rejected: the decrypt secret would itself need keystore storage, adding a layer with no benefit. Multiple profiles per identity — rejected by the user (Q3=A).

---

## R2. Topology: in-person QR pairing + LAN change exchange (no server)

**Decision**: Pairing is **in-person**: the inviting device shows a QR containing `{identityId, username, ed25519 public key, fingerprint, single-use token, offeredRole}`; the joining device scans it, verifies the token, and both sides persist a `PairedPeer` + `PairedContext`. Ongoing exchange happens on the **same local network**: peers advertise via **mDNS** (`multicast_dns`/`nsd`) and open a direct **TCP socket wrapped in TLS**, pinned to the paired peer's public key (self-signed, trust-on-first-use established at QR time). No server, no relay, no internet.

**Rationale**: The spec requires co-located-only, zero-infrastructure operation. QR in-person exchange is the strongest way to bind a username to a key (it defeats name collisions and eavesdroppers; SC-006). LAN + pinned TLS needs no CA and no cloud, and the pinned key is already known from pairing, so no PKI is required.

**Alternatives considered**: `nearby_connections` (Android Nearby Connections / iOS MultipeerConnectivity) — attractive because it handles discovery, transport and encryption across both platforms (BLE + Wi-Fi), but it is a heavy platform dependency with behavioral divergence and is awkward to fake in tests; kept as a **fallback** if raw mDNS+socket proves unreliable in the field. Wi-Fi Direct — rejected: Android-centric, no iOS equivalent. Manual file exchange (sneakernet) — rejected as the primary path: works, but far worse UX than LAN; retained implicitly because a backup file can already move data. A relay server — rejected: violates the no-cloud decision.

---

## R3. Sync engine: signed change-log + HLC + tombstones (not column diffing)

**Decision**: Every local write to a **paired shared context** appends a `ChangeRecord` `{contextKind, contextLocalId, entityType, entityLocalId, op: upsert|delete, payload (canonical string), hlc, deviceId, authorIdentityId, signature}`. Records are exchanged in **HLC order** (a hybrid logical clock: `(wallClockMillis, counter, deviceId)`), applied idempotently, and deletes are **tombstone `ChangeRecord`s** (retained). Each entity type gets a `SyncCodec` (canonical `toPayload`/`fromPayload`); a **`SyncRecorder`** seam wraps the space/finance/medical repository writes so no feature code changes. Applying a change mutates the entity through the same repositories, then records the new version cursor.

**Rationale**: 011's entities (`Expense`, `MedicalBill`, `Reimbursement`, `MonthlyBudget`, directory rows) have **no uniform `updatedAt`/version columns** today (`expense.dart`, `medical_bill.dart`, `monthly_budget.dart`), so per-column diffing would require touching every model and every query. A change-log keeps 011's models essentially intact, makes "what changed" explicit and auditable, provides natural tombstones, and localizes serialization to one codec per type. HLC gives a deterministic total order without a clock-sync server and tolerates device clock skew (the counter breaks ties when wall clocks collide).

**Alternatives considered**: Add `version`/`updatedAt` to every entity and diff by timestamp — rejected: invasive, and last-write-wins by raw timestamp is fragile across skewed clocks. Whole-context snapshot transfer — rejected: violates FR-006 (no full-DB copy) and wastes bandwidth/history. A CRDT per field — rejected as premature: the spec asks for one deterministic rule and no silently-lost whole records, not field-level merging.

---

## R4. Deterministic merge and conflict surfacing

**Decision**: Per **entity record**, the winner is the `ChangeRecord` with the greatest HLC key; ties (same HLC) break on `deviceId` (lexicographic) so every device picks the same winner. Deletes beat concurrent upserts (tombstone wins once it is the higher HLC; an upsert strictly after a delete is a legitimate recreate). Incoming changes that **lose** to the local head are discarded but **surfaced** in a `sync-conflicts` count/log and a non-blocking notice, never silently merged away (FR-007/013). No human merge UI in v1; re-editing on a converged device supersedes.

**Rationale**: The spec's FR-007 asks for one documented rule identical on every device with no whole record lost. HLC + deviceId tiebreak is total and deterministic by construction. Tombstone-beats-concurrent-upsert prevents resurrection (edge case "delete-then-recreate"). Surfacing losing changes satisfies "conflicts MUST be surfaced rather than silently merged away".

**Alternatives considered**: Last-write-wins by wall clock only — rejected: non-deterministic under skew. First-write-wins — rejected: surprises users who expect the latest edit. Interactive conflict prompts — deferred (out of scope v1 per spec assumption).

---

## R5. Authorization without a server: signed, versioned membership

**Decision**: `SharedMember` becomes an **authorization record**: it gains `version` (HLC), `updatedAt`, `authorIdentityId`, `signature`, and `revokedAt` (revocation tombstone). Every membership change (create, role change, remove, transfer) is signed by the acting Owner's identity and recorded in the change-log like any other change. On each device, **applying** any shared money change re-validates the author's membership **as of that change's HLC** against the local membership head; a change whose author was not a valid member/role at that HLC is dropped. 011's `SpaceAccessGuard` (`space_role_guard.dart:27-104`) is reused verbatim for the local-write path; a new `assertAuthorizedAt(changes)` extends it for the apply path. `revokedAt` + version means a removal wins once it has the higher HLC, and a removed member's later changes never apply anywhere.

**Rationale**: With no central authority, authorization must be derivable from signed, causally-ordered history on each device; this is the only design that satisfies FR-008/009 ("enforced at the point of application, not only the UI") and SC-005 ("removed/demoted member's later changes never applied"). Reusing the existing guard keeps one role matrix (`contracts/space-roles.md`) and its T031 tests valid. Because a removed device's future changes never reach a peer that accepts them (no server to accept them), removal needs no cooperation from the removed device — matching the spec.

**Alternatives considered**: Trust the local guard only — rejected: a tampered peer would bypass it. A trusted-peer whitelist without signing — rejected: no authorship proof. Elections/quorum — rejected: overkill for 2–5 devices and no online authority to run them.

---

## R6. Sealed-month invariance across devices

**Decision**: A sealed month's **content** is exchanged as ordinary `ChangeRecord`s exactly once (at/after the seal), then no further change for that month's records is accepted on any device (the month-seal check — already in `SpaceAccessGuard.assertMonthEditable`, `space_role_guard.dart:78-85` — refuses writes for every role). **Conversion stays local**: each device renders using its own device-global `MonthRateSeal`/`LiveRateSet` (`lib/core/models/month_rate_seal.dart`, `live_rate_set.dart`), which are deliberately **never** exchanged. The seal coordinator's distinct-`yearMonth` rule from 011 research R6 is unchanged.

**Rationale**: This is how the spec reconciles "totals identical on every device" with 011's device-global market data: content is shared, rates are not, and conversion is a pure deterministic function of the same sealed inputs. FR-011 preserved.

**Alternatives considered**: Exchange seals too — rejected: forks "the past never changes" per-device history and duplicates market data. Recompute totals into the space currency at seal time and share numbers — rejected: loses per-currency re-render and violates the 010/011 conversion contract.

---

## R7. Backup and recovery: user-held encrypted archive, two unlock paths

**Decision**: `BackupService.export()` produces one encrypted archive containing the identity (keypair + username) and the linked contexts' change-log + current rows. Encryption: **AES-256-GCM**; the key is derived from **either** the user's chosen passphrase (**Argon2id**, high cost params) **or** a **generated 128-bit recovery code** (Crockford/base32, shown once) — both wrapped, so **either** unlocks the archive. The user saves the file locally (`file_picker`/`path_provider`) or sends it to their own email; the app never transmits it. `BackupService.import()` on a fresh install restores identity + contexts and re-pairs nothing (keys travel inside the archive); paired peers must still complete the change exchange to catch up.

**Rationale**: The spec requires recovery without any server and explicitly supports **both** unlock methods. Passphrase covers the "I'll remember it" case; the recovery code covers the "I won't" case, and both are portable (device auth cannot cross devices — a documented assumption). Argon2id resists offline guessing of the file.

**Alternatives considered**: Passphrase only — rejected by the user (both required). Recovery code only — risk of loss for the whole identity. Platform cloud backup (Google/Apple) — rejected: reintroduces a cloud and breaks the privacy stance.

---

## R8. Consent and optional device auth (GDPR-by-design)

**Decision**: First run shows a **consent notice** (versioned text) about using the phone's PIN/biometrics; the decision is stored in a `ConsentRecord` (local only) and is **revocable** at any time. Device auth is **optional and recommended**; when off, the app warns that data is less protected and remains fully usable. Enabling/disabling simply changes whether an unlock prompt is required before the identity key is released. No special-category data is sent anywhere (nothing is sent anywhere), so the practical GDPR surface is minimal; the consent record is the auditable trace.

**Rationale**: Matches the user's revised decision (free choice + warning, not compulsory) and keeps consent "freely given and revocable", avoiding the forced-bundling problem flagged during specification. FR-002.

**Alternatives considered**: Compulsory consent — rejected (legally weak for biometrics, and the user retracted it). Evaluating biometrics without any notice — rejected: not compliant/Not transparent.

---

## R9. Migration shape and test strategy

**Decision**: `schemaVersion` 13 → **15**. **Step 14** is additive (house pattern, `schema_migrations.dart:105-106`): registers `Identity`, `ConsentRecord`, `PairedPeer`, `PairedContext`, `PairingToken`, `ChangeRecord`, `SyncCursor`, and adds the `SharedMember` sync columns (`version/updatedAt/authorIdentityId/signature/revokedAt`) — zero data movement, no existing amount touched. **Step 15** is a no-op guard/idempotent backfill (e.g., stamp existing memberships with a genesis version=0 and `authorIdentityId=null`) so the schema is consistent for installs that pre-date pairing. No monetary value, seal or month total is rewritten (011 SC-003 stays true). Tests use a **fake transport** + in-memory peer; HLC is injected via a clock provider so merges are deterministic; `local_auth` and secure storage sit behind interfaces and are faked in unit tests.

**Rationale**: Additive-first matches the repo's immutable-step convention and keeps the 011/010 "amounts are never rewritten" guarantee. Separating additive (14) from backfill (15) mirrors 011 research R9. Faking transport/auth keeps CI hermetic (no sockets, no biometric hardware) — same reason 011's widget tests used `_FakeSpacesRepository`.

**Alternatives considered**: One combined step — rejected (mixes shape and data movement). Regenerating the schema from scratch — rejected (no rollback story; same rejection as 010/011). Exercising real sockets/biometrics in tests — rejected: non-hermetic and flaky.
