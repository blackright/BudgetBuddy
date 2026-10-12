---

description: "Task list for Cross-Device Shared Spaces (Peer-to-Peer) implementation"
---

# Tasks: Cross-Device Shared Spaces (Peer-to-Peer)

**Input**: Design documents from `/specs/012-cross-device-shared-spaces/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md — and **feature 011 complete** (its months, roles and context seams are the exchanged payload).

**Tests**: Included. The spec carries a mandatory "User Scenarios & Testing" section per story, mandates data-layer enforcement "covered by tests" (FR-007/008/009, SC-002/SC-005) and runnable scenarios in quickstart.md; tests are therefore generated per story and MUST fail before implementation.

**Organization**: Tasks are grouped by user story (US1–US6 from spec.md) to enable independent implementation and testing. Git is 🛑 hands-off — the user pushes.

## Format: `[P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US6)
- Include exact file paths in descriptions

## Path Conventions

- Flutter single project: `lib/`, `test/` at repository root.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify the baseline and add the peer-to-peer dependency set (research R1/R2/R7).

- [ ] T001 [P] Verify baseline is green before any change: from repo root run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` and confirm zero failures (011 gate: 393 pass / 1 skip / 0 fail)
- [ ] T002 Add new dependencies to `pubspec.yaml`: `local_auth`, `flutter_secure_storage`, `cryptography`, `mobile_scanner`, `qr_flutter`, `multicast_dns`, `share_plus`; then run `flutter pub get` (research R1/R2/R7; no server SDK)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story — models, migration, HLC/codecs, transport abstraction, identity/consent services, the sync-recorder seam and harnesses.

**CRITICAL**: No user story work can begin until this phase is complete.

### Models (Isar collections, data-model §2)

- [ ] T003 [P] Create `Identity` model in `lib/core/models/identity.dart` — username, publicKey, keyAlgorithm, localProfileId (`@Index(unique: true)`), fingerprint, createdAt/updatedAt; private key NOT stored here (data-model §2.1, FR-001/016)
- [ ] T004 [P] Create `ConsentRecord` model in `lib/core/models/consent_record.dart` — noticeVersion, deviceAuthGranted, decidedAt, updatedAt (data-model §2.2, FR-002)
- [ ] T005 [P] Create `PairedPeer` model in `lib/core/models/paired_peer.dart` — peerIdentityId (`@Index(unique: true)`), peerUsername, peerPublicKey, peerFingerprint, pairedAt, lastSeenAt (data-model §2.3)
- [ ] T006 [P] Create `PairedContext` model in `lib/core/models/paired_context.dart` — peerId, contextKind `@enumerated`, contextLocalId, peerRole `@enumerated`, pairedAt, active; composite unique `[peerId, contextKind, contextLocalId]` (data-model §2.4)
- [ ] T007 [P] Create `PairingToken` model in `lib/core/models/pairing_token.dart` — token (`@Index(unique: true)`), spaceId, offeredRole `@enumerated`, direction `@enumerated`, peerFingerprint?, createdAt/expiresAt, usedAt? (data-model §2.5, FR-005)
- [ ] T008 [P] Create `ChangeRecord` model in `lib/core/models/change_record.dart` — contextKind, contextLocalId `@Index`, entityType, entityLocalId, op, payload, hlcMillis/hlcCounter, deviceId, authorIdentityId `@Index`, signature, createdAt (data-model §2.6, FR-006)
- [ ] T009 [P] Create `SyncCursor` model in `lib/core/models/sync_cursor.dart` — peerId, contextLocalId, lastSent*/lastReceived* HLC watermarks, conflictCount, updatedAt (data-model §2.7, FR-013)
- [ ] T010 [P] Create `ContextKind` and `PairingDirection` enums in `lib/core/models/context_kind.dart` (data-model §1.1/1.2)
- [ ] T011 [P] Add sync columns to `SharedMember` in `lib/core/models/shared_member.dart`: `version int`, `updatedAt DateTime`, `authorIdentityId String?`, `signature String?`, `revokedAt DateTime?` (data-model §3.1, R5)

### Schema registration + codegen + migration

- [ ] T012 Register the seven new `*Schema`s alongside the existing collections in the `Isar.open(...)` list in `lib/core/database/isar_helper.dart` (data-model §2)
- [ ] T013 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate all `*.g.dart` for the new/modified models (required after T003–T012)
- [ ] T014 Add migration step 14 (additive: create the seven collections + add `SharedMember` sync columns) and step 15 (idempotent backfill: stamp pre-existing memberships `version = 0`, `authorIdentityId = null`, `revokedAt = null`), then bump `schemaVersion` 13 → 15 in `lib/core/database/schema_migrations.dart` (data-model §7, R9)

### Sync core abstractions (research R3/R4/R6)

- [ ] T015 [P] Create the `Hlc` value type (millis/counter/deviceId, total-order compare, `tick(now)` via injected clock) in `lib/features/sync/domain/hlc.dart` (data-model §1.3, sync-protocol §2)
- [ ] T016 [P] Create the `SyncCodec` interface + per-entity codecs (canonical `toPayload`/`fromPayload`) for the covered entity types in `lib/features/sync/domain/sync_codec.dart` and `lib/features/sync/domain/codecs/` (data-model §2.6, sync-protocol §5)
- [ ] T017 [P] Create the `Transport` abstraction (discover/connect/send/receive) with an in-memory `FakeTransport` for tests in `lib/features/sync/transport/transport.dart` and `test/features/sync/support/fake_transport.dart` (research R2; keeps CI hermetic)
- [ ] T018 [P] Create `IdentityService` (generate ed25519 keypair, persist public key in Isar, store private key via `flutter_secure_storage`, expose a session unlock) in `lib/features/identity/repositories/identity_service.dart` (research R1, FR-001)
- [ ] T019 [P] Create `ConsentService` (record/show/revoke device-auth consent against a notice version) in `lib/features/identity/repositories/consent_service.dart` (research R8, FR-002)

### Providers + sync-recorder seam

- [ ] T020 [P] Create identity/consent providers (`identityProvider`, `consentProvider`, `deviceAuthEnabledProvider`) in `lib/core/providers/identity_provider.dart` (data-model §2.1/2.2)
- [ ] T021 Create the `SyncRecorder` seam in `lib/features/sync/repositories/sync_recorder.dart` and wire it into `lib/features/spaces/repositories/spaces_repository.dart` writes so every paired-shared-context write appends a `ChangeRecord` (research R3, FR-006)

### Harnesses + migration tests

- [ ] T022 Add the seven new schemas to `test/features/medical/repositories/medical_test_harness.dart` and add an in-memory-peer harness with the `FakeTransport` in `test/features/sync/support/sync_harness.dart` (extends the 011 harness pattern)
- [ ] T023 [P] Write migration test: fresh install at v15 and upgrade from v13 both succeed; existing amounts/seals/totals are byte-identical; step 14 is additive and step 15 is idempotent (SC-003) in `test/core/database/migration_cross_device_test.dart`

**Checkpoint**: Foundation ready — user stories can now begin.

---

## Phase 3: User Story 1 - I set up my identity, my way (Priority: P1) — MVP

**Goal**: Create a local username identity with no account/email/server, optionally gated by the phone's own PIN/biometrics, with a voluntary, revocable consent record and a clear warning when off (spec US1).

**Independent Test**: On a fresh install create a username with device auth off then on; verify the app works both ways, the warning appears when off, the choice is recorded/revocable, and no network is contacted (US1 Independent Test).

### Tests for User Story 1 (MUST fail before implementation)

- [ ] T024 [P] [US1] Write identity creation test: username + device-generated keypair, public key persisted, private key only via secure storage (fake), exactly one profile linked, no server contact (FR-001/016, SC-008) in `test/features/identity/identity_creation_test.dart`
- [ ] T025 [P] [US1] Write consent/device-auth test: notice shown, grant/decline recorded locally, warning present when off, revocation updates the record, app usable without it (FR-002) in `test/features/identity/consent_test.dart`

### Implementation for User Story 1

- [ ] T026 [P] [US1] Build identity onboarding UI (username entry + optional device-auth toggle + warning text + consent notice) in `lib/features/identity/presentation/identity_onboarding_screen.dart`
- [ ] T027 [US1] Wire the `local_auth` app lock (session unlock of the identity key) and persist the consent decision via `ConsentService`, including revocation from settings, in `lib/features/identity/repositories/identity_service.dart` + `consent_service.dart` (FR-002)
- [ ] T028 [US1] Link the identity to exactly one profile (`localProfileId`); keep additional local profiles local-only and never paired in `lib/features/identity/repositories/identity_service.dart` (FR-016)

**Checkpoint**: User Story 1 fully functional and testable independently. **STOP and VALIDATE (MVP).**

---

## Phase 4: User Story 2 - The same space, on both our devices (Priority: P1)

**Goal**: A paired shared space shows the same single month (budget, income, expenses, medical bills, reimbursements) on both devices; offline edits queue and converge at the next co-presence with one deterministic rule and no silently-lost record (spec US2).

**Independent Test**: Two fake-peer devices; each edits offline; on co-presence both expenses exist once with identical totals (US2 Independent Test).

### Tests for User Story 2 (MUST fail before implementation)

- [ ] T029 [P] [US2] Write codec round-trip test: every covered entity `toPayload`→`fromPayload` is lossless, money fields byte-identical (FR-010) in `test/features/sync/sync_codec_test.dart`
- [ ] T030 [P] [US2] Write HLC determinism + merge test: identical winning outcome regardless of arrival order; losing change counted and surfaced (FR-007, SC-002) in `test/features/sync/merge_determinism_test.dart`
- [ ] T031 [P] [US2] Write tombstone test: delete beats a concurrent upsert; a strictly later upsert recreates; no resurrection (FR-006/007) in `test/features/sync/tombstone_test.dart`
- [ ] T032 [P] [US2] Write offline + convergence integration test with `FakeTransport`: edits queue offline, converge on co-presence, no duplicate copy, no half-apply (FR-003/010/013, SC-001/003) in `test/features/sync/convergence_integration_test.dart`

### Implementation for User Story 2

- [ ] T033 [US2] Implement `SyncEngine` (exchange loop, verify→merge by HLC→apply through the same repositories, advance `SyncCursor`) in `lib/features/sync/repositories/sync_engine.dart` (sync-protocol §3/§4, FR-006/007)
- [ ] T034 [US2] Extend `SyncRecorder` coverage to every covered entity type (month budget/income, expense, reimbursement, medical bill + lifecycle, directory rows) via their `SyncCodec`s in `lib/features/sync/repositories/sync_recorder.dart` (FR-010)
- [ ] T035 [US2] Create the sync status model/provider (`waitingForPeer`/`syncing`/`converged`/`conflicts(n)`) in `lib/features/sync/providers/sync_status_provider.dart` and a status chip widget in `lib/shared/presentation/widgets/sync_status_chip.dart`, surfaced on the shared space view (FR-013)

**Checkpoint**: User Stories 1 AND 2 both work independently.

---

## Phase 5: User Story 3 - I pair with someone on their own device (Priority: P1)

**Goal**: Owner pairs a peer device in person (QR) / on the LAN with a chosen role; username binds to key with a fingerprint; pairing is single-use, expirable, cancellable, and duplicates are refused (spec US3).

**Independent Test**: Owner pairs device A with device B by QR; the invitee becomes a member with the chosen role; both list the same member and role at the next co-presence (US3 Independent Test).

### Tests for User Story 3 (MUST fail before implementation)

- [ ] T036 [P] [US3] Write pairing-token test: single-use (`usedAt`), expiry enforced, cancellation invalidates, duplicate/reuse refused (FR-005, SC-006) in `test/features/pairing/pairing_token_test.dart`
- [ ] T037 [P] [US3] Write pairing handshake test: fingerprint shown/confirmed, claim creates `PairedPeer`+`PairedContext` and a signed membership with the offered role, mismatched fingerprint rejected (FR-004/005) in `test/features/pairing/pairing_handshake_test.dart`

### Implementation for User Story 3

- [ ] T038 [US3] Implement `PairingService` (create token; claim validation single-use/expiry/cancel/duplicate; create signed `SharedMember`; persist `PairedPeer`/`PairedContext`; open `SyncCursor`) in `lib/features/pairing/repositories/pairing_service.dart` (pairing §2–§4, FR-004/005)
- [ ] T039 [US3] Build QR presentation + scan UI (`qr_flutter` display, `mobile_scanner` scan, fingerprint confirmation) in `lib/features/pairing/presentation/pair_device_screen.dart` (pairing §2, FR-004)
- [ ] T040 [US3] Implement the LAN `Transport` (mDNS discovery via `multicast_dns`/`nsd` + pinned-TLS socket verified against the paired public key) behind the `Transport` interface in `lib/features/sync/transport/lan_transport.dart` (research R2, pairing §3)
- [ ] T041 [US3] Create the "Paired devices" section in space settings (list peers, pair, unpair, role) and register it in `lib/features/spaces/presentation/space_settings_section.dart` + `lib/features/settings/presentation/settings_screen.dart` (pairing §4, FR-014)

**Checkpoint**: User Stories 1–3 independently functional (real pairing over LAN).

---

## Phase 6: User Story 4 - Roles and the frozen past hold on every paired device (Priority: P1)

**Goal**: 011's role matrix holds across devices, enforced when changes are applied (not just in UI); a sealed month is content-immutable on every device and re-renders identical totals from each device's own seals (spec US4).

**Independent Test**: A Viewer attempts every write path directly; the Owner seals a month on A; verify the Viewer's writes are never applied and B re-renders identical sealed totals (US4 Independent Test).

### Tests for User Story 4 (MUST fail before implementation)

- [ ] T042 [P] [US4] Write apply-time authorization test: removed/demoted author's later changes dropped by every peer; Viewer money/directory change dropped; last-Owner/transfer rules hold off-device (FR-008/009, SC-005) in `test/features/spaces/apply_time_authorization_test.dart`
- [ ] T043 [P] [US4] Write sealed-month invariance test across devices: content exchanged once then refused on both paths; totals identical in every currency from each device's own seals (FR-011, SC-004) in `test/features/spaces/sealed_month_invariance_test.dart`

### Implementation for User Story 4

- [ ] T044 [US4] Extend `SpaceAccessGuard` with `assertAuthorizedAt(change, membershipHead)` (author valid member/role as of the change HLC; sealed-month refusal) in `lib/features/spaces/repositories/space_role_guard.dart` (role-authorization §3, FR-008/009)
- [ ] T045 [US4] Make membership writes signed + versioned (create/role/remove/transfer authored by the acting Owner with a fresh HLC `version` + signature; revocations via `revokedAt`) in `lib/features/spaces/repositories/spaces_repository.dart` (role-authorization §2/§4, FR-008)
- [ ] T046 [US4] Wire apply-time enforcement (signature → `assertAuthorizedAt` → month-seal) into the `SyncEngine` apply path in `lib/features/sync/repositories/sync_engine.dart` (FR-008/009/011, SC-005)
- [ ] T047 [US4] Enforce sealed-month content immutability on the apply path (no role) so a sealed month's records are exchanged once then refused everywhere in `lib/features/sync/repositories/sync_engine.dart` (FR-011, R6)

**Checkpoint**: User Stories 1–4 independently functional (full cross-device role safety).

---

## Phase 7: User Story 5 - I can back up, recover, unpair, and see my sync state (Priority: P2)

**Goal**: Export an encrypted backup the user keeps (passphrase OR recovery code), restore on a new device, see sync state, and leave/unpair/wipe (spec US5).

**Independent Test**: Export a backup, restore on a fresh install by passphrase then by recovery code; verify identity + data return; go offline and observe "waiting for peer" clearing at co-presence (US5 Independent Test).

### Tests for User Story 5 (MUST fail before implementation)

- [ ] T048 [P] [US5] Write backup/recovery round-trip test: export→import via passphrase AND via recovery code both restore identity + contexts; wrong secret fails with no partial restore; vault excluded (FR-012/015, SC-007) in `test/features/backup/backup_round_trip_test.dart`
- [ ] T049 [P] [US5] Write leave/unpair/wipe lifecycle test: last-Owner leave blocked; unpair keep-vs-delete local copy; wipe deletes identity/key/data and confirms (FR-014) in `test/features/backup/unpair_wipe_test.dart`

### Implementation for User Story 5

- [ ] T050 [US5] Implement `BackupService` (canonical payload of identity keypair + contexts; Argon2id passphrase key + generated 128-bit recovery code; AES-256-GCM archive; import) in `lib/features/backup/repositories/backup_service.dart` (backup-recovery §1–§4, FR-012)
- [ ] T051 [US5] Build backup/restore UI (export with passphrase + one-time recovery code display; import via `file_picker`; export via `share_plus` to the user's own email/storage) in `lib/features/backup/presentation/backup_screen.dart` (FR-012/017)
- [ ] T052 [US5] Implement leave space / unpair (keep-or-delete local copy) / wipe identity (delete identity, key, local data + confirm) in `lib/features/settings/repositories/identity_lifecycle.dart` + settings UI (FR-014)
- [ ] T053 [US5] Finalize per-space sync status + conflict count display ("waiting for peer" clears at co-presence) in `lib/features/sync/providers/sync_status_provider.dart` (FR-013, US5 AC3)

**Checkpoint**: User Stories 1–5 functional.

---

## Phase 8: User Story 6 - My personal profiles follow me (deferred, optional) (Priority: P3)

**Goal**: Optionally pair a user's *own* second device to sync a *personal* (non-shared) profile, offline-first (spec US6). **Deferred — do not start until US1–US5 are complete and the product opts in.**

**Independent Test**: (Deferred) Pair two own devices and confirm a personal profile's expenses converge offline-first (US6 Independent Test).

### Tests for User Story 6 (DEFERRED)

- [ ] T054 [P] [US6] Write personal-context convergence test (`contextKind = personal`, same determinism guarantees) in `test/features/sync/personal_sync_test.dart` — **DEFERRED**

### Implementation for User Story 6 (DEFERRED)

- [ ] T055 [US6] Extend `SyncRecorder`/`SyncEngine`/pairing to accept `ContextKind.personal` contexts and pair a profile (FR-016 boundary preserved for other profiles) — **DEFERRED**

**Checkpoint**: Deferred; not required by SC-001…SC-008.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and privacy guarantees across all stories.

- [ ] T056 [P] Privacy verification: no cloud/server/relay/telemetry endpoint is contacted at any point; the only outbound artifact is the user-initiated backup; discovery exposes nothing financial before mutual pairing (SC-008, FR-017) in `test/features/sync/privacy_no_network_test.dart`
- [ ] T057 [P] Cross-check docs: reconcile `plan.md`/`data-model.md` with shipped collection names, migration steps and contracts (no doc drift)
- [ ] T058 Run the final validation gate per `quickstart.md`: `dart run build_runner build --delete-conflicting-outputs`, `dart format`, `flutter analyze`, `flutter test` all green; walk quickstart §1 (CI scenarios) and §2 (two-device manual); fix regressions

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — baseline verification + dependencies
- **Foundational (Phase 2)**: Depends on Setup; **BLOCKS all user stories** (models, migration, HLC/codecs, transport, identity/consent services, recorder seam, harnesses)
- **US1 (Phase 3)**: Depends on Foundational only (identity/consent) — MVP
- **US2 (Phase 4)**: Depends on Foundational (US2 is independently testable with `FakeTransport` + an in-memory peer; no US3 needed)
- **US3 (Phase 5)**: Depends on Foundational (real QR/LAN path); provides real pairing used by the manual walkthrough
- **US4 (Phase 6)**: Depends on Foundational + US2 (apply path exists) and uses US3's signed membership; sequence after US2 (US3 recommended before end-to-end)
- **US5 (Phase 7)**: Depends on Foundational + US1 (identity) and benefits from US2 status surface
- **US6 (Phase 8)**: Deferred; depends on US2 + US3 if ever started
- **Polish (Phase 9)**: Depends on all desired stories complete

### User Story Dependencies

- **US1**: standalone (MVP)
- **US2**: standalone after Foundational via fake transport; real-device validation needs US3
- **US3**: after Foundational; its handshake test uses the fake transport
- **US4**: after US2 (apply path) — membership signing overlaps US3's `PairingService` (single-owner invariant)
- **US5**: after US1; independent of US2/US3 for backup, sync-state depends on US2's provider
- **US6**: deferred

### Within Each User Story

- Tests (included) MUST be written and FAIL before implementation
- Models before services; services before UI/integration
- Story complete before moving to next priority

### Parallel Opportunities

- Phase-2 `[P]` model tasks (T003–T011, T015–T020) run in parallel (different files)
- After Foundational, **US1** and **US2** can start in parallel; **US3**'s handshake tests can start once the transport abstraction (T017) exists
- Each story's `[P]` tests run in parallel, then `[P]` implementation tasks in parallel within the story
- T013 (codegen) and T014 (migration) are serialization points (must follow T003–T012)

---

## Parallel Example: Foundational models + US2 sync core

```bash
# Foundational models in parallel (all different files):
Task: "Create Identity model in lib/core/models/identity.dart"
Task: "Create ChangeRecord model in lib/core/models/change_record.dart"
Task: "Create PairingToken model in lib/core/models/pairing_token.dart"
Task: "Add sync columns to SharedMember in lib/core/models/shared_member.dart"

# US2 sync logic in parallel after T015/T016/T017 (different files):
Task: "Implement SyncEngine in lib/features/sync/repositories/sync_engine.dart"
Task: "Extend SyncRecorder in lib/features/sync/repositories/sync_recorder.dart"
Task: "Create sync status provider + chip in lib/features/sync/providers/ and lib/shared/presentation/widgets/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T023) — CRITICAL
3. Run US1 tests (T024–T025) — confirm they FAIL
4. Complete Phase 3: US1 (T026–T028)
5. **STOP and VALIDATE**: tests green; device-auth on/off both work; no network (US1 Independent Test, quickstart §1.1–1.2)

### Incremental Delivery

1. Foundational → US1 (**MVP**: identity done, all 011 behaviour unchanged)
2. + US2 → validate sync convergence with fake then real transport
3. + US3 → validate real QR/LAN pairing
4. + US4 → validate offline role enforcement + sealed-month invariance
5. + US5 → validate backup/recovery (both paths), unpair/wipe, sync state
6. + US6 (deferred) → optional personal-profile sync
7. Polish + final gate + quickstart §1–§2

### Parallel Team Strategy

1. Team completes Setup + Foundational together (T003–T023, parallel where `[P]`)
2. Then: Developer A → US1 (identity/consent); Developer B → US2 (sync engine, fake transport); Developer C → US5 backup (needs only US1)
3. Then: US3 (pairing/LAN) → US4 (authorization) → US6 (deferred)
4. Stories integrate only through `Transport`, `SyncEngine`, `SyncRecorder` and `SpaceAccessGuard` — single seams, no file conflicts

---

## Notes

- **Git hands-off**: no commits/pushes by the agent — the user pushes (Phase-Builder rule).
- **[P] tasks** = different files, no dependencies; keep them truly parallel.
- **[Story] labels** map to spec.md user stories for traceability.
- Each story independently completable and testable; verify tests fail before implementing.
- `build_runner` must run after any model edit (T013 and after each story that touches `lib/core/models/`).
- Tests never open real sockets or biometric hardware: `local_auth`, secure storage and networking sit behind interfaces with fakes (same reason 011 widget tests used `_FakeSpacesRepository`).
- The savings vault (FR-015) and device-global `MonthRateSeal`/`LiveRateSet` (FR-011) are never synced by any task.
