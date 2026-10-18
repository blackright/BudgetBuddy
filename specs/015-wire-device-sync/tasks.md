---
description: "Task list for feature 015-wire-device-sync"
---

# Tasks: Live Device Sync (Deliver Cross-Device Changes)

**Input**: Design documents from `/specs/015-wire-device-sync/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included — plan.md enumerates the test files (`sync_guid_test.dart`, `entity_identity_test.dart`, `bootstrap_delivery_test.dart`, `sync_coordinator_test.dart`, `sync_status_test.dart`, plus edits to existing sync tests) and constitution II requires testable seams. Write the test first for each behaviour and watch it fail.

**Organization**: Grouped by user story. This feature has a large **Foundational** phase because the identity
redesign (per-entity `syncGuid`) changes every model, codec, applier, the signing bytes and the engine —
nothing in any story works until that layer is in place (research R5). US1 and US2 are both P1 and both
need the delivery loop; the loop is foundational, the stories are the behaviour + verification on top.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US4 (setup/foundational/polish have no story label)
- Exact file paths in every task

## Path Conventions

Single Flutter project. Feature code under `lib/features/…`, core under `lib/core/…`, tests mirror under `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: The one new primitive and the test scaffolding every later task uses.

- [x] T001 Create `lib/features/sync/domain/sync_guid.dart` exposing `String newSyncGuid()` — a lowercase RFC-4122 v4 UUID built from the **already-present** `uuid: ^4.2.0` package (`const Uuid().v4()`, the same call as `identity_provider.dart:67`; no new package). Document the identity contract (stable, unique, never reused).
- [x] T002 [P] Extend `test/features/sync/support/sync_harness.dart` and `test/features/sync/support/change_factory.dart` so two in-memory peers can run with **deliberately different local row ids** and GUID-bearing fixtures (helpers to seed two Isars with distinct ids for the same logical entity).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Device-independent identity (models + schema + signing + codecs + appliers + engine) and the running loop (session, providers, coordinator, lifecycle). **No user story can be built until this completes.**

**⚠️ CRITICAL**: When a task here changes a model or codec, existing tests that encode the old local-id wire shape will fail until T028/T034/T045 update them — that is expected and is the signal the redesign is in effect.

### 2a. Entity identity on the models

- [x] T003 [P] Add `syncGuid` (`@Index()` **non-unique** hash index + per-instance `= newSyncGuid()` initializer; uniqueness by construction + step 17 — see `data-model.md` §1) to `SharedSpace` in `lib/core/models/shared_space.dart`.
- [x] T004 [P] Add `syncGuid` to `SharedMember` in `lib/core/models/shared_member.dart`.
- [x] T005 [P] Add `syncGuid` to `MonthlyBudget` in `lib/core/models/monthly_budget.dart`.
- [x] T006 [P] Add `syncGuid` to `Expense` in `lib/core/models/expense.dart`.
- [x] T007 [P] Add `syncGuid` to `MedicalBill` in `lib/core/models/medical_bill.dart`.
- [x] T008 [P] Add `syncGuid` to `MedicalServiceType` in `lib/core/models/medical_service_type.dart`.
- [x] T009 [P] Add `syncGuid` to `InsuranceProfile`, `FamilyMember` and `MedicalProvider` in `lib/core/models/insurance_profile.dart` (three classes, one file).
- [x] T010 [P] Add `syncGuid` to `Reimbursement` in `lib/features/expenses/models/reimbursement.dart`.
- [x] T011 Reshape `ChangeRecord` in `lib/core/models/change_record.dart`: add signed `contextSyncGuid` and `entitySyncGuid`; keep `contextLocalId`/`entityLocalId` as local-only bookkeeping; add indexes on the GUIDs.

### 2b. Schema regeneration + migration

- [x] T012 Regenerate Isar schemas: `dart run build_runner build --delete-conflicting-outputs` (updates every `*.g.dart`). No edit to `lib/core/database/isar_helper.dart` is needed (collections are unchanged; only columns were added).
- [x] T013 Add migration step 17 in `lib/core/database/schema_migrations.dart`: bump `schemaVersion` 16 → 17, add `_step17AddSyncGuids` that assigns `newSyncGuid()` to every empty-`syncGuid` row in the ten collections, and clear any dev/test `ChangeRecord` rows (identity reshaped; no production rows exist).
- [x] T014 [P] Add `test/core/database/schema_migrations_test.dart` coverage for step 17: every pre-existing row gets a unique non-empty `syncGuid`; a second run writes nothing (idempotent); no amount/seal/total/id changed.

### 2c. Signing

- [x] T015 Update `lib/features/sync/domain/change_signing.dart`: `changeCanonicalString` signs over `contextSyncGuid`/`entitySyncGuid` in place of the local ids (and no longer over the local ids). Leave `membershipCanonicalString` unchanged. Covered by new `test/features/sync/change_signing_test.dart`.

### 2d. Codecs — GUID payloads

Each codec emits the entity's own `syncGuid` and its references as GUIDs (`sharedSpaceSyncGuid`, `budgetSyncGuid`, `expenseSyncGuid`, `linkedExpenseSyncGuid`, `familyMemberSyncGuid`, `providerSyncGuid`, `serviceTypeSyncGuid`) and drops the numeric `id`/foreign keys, per `contracts/entity-identity.md` §2.3.

- [x] T016 [P] `lib/features/sync/domain/codecs/shared_space_codec.dart`
- [x] T017 [P] `lib/features/sync/domain/codecs/shared_member_codec.dart`
- [x] T018 [P] `lib/features/sync/domain/codecs/monthly_budget_codec.dart`
- [x] T019 [P] `lib/features/sync/domain/codecs/expense_codec.dart`
- [x] T020 [P] `lib/features/sync/domain/codecs/reimbursement_codec.dart`
- [x] T021 [P] `lib/features/sync/domain/codecs/medical_bill_codec.dart`
- [x] T022 [P] `lib/features/sync/domain/codecs/family_member_codec.dart`
- [x] T023 [P] `lib/features/sync/domain/codecs/medical_provider_codec.dart`
- [x] T024 [P] `lib/features/sync/domain/codecs/medical_service_type_codec.dart`
- [x] T025 [P] `lib/features/sync/domain/codecs/insurance_profile_codec.dart`
- [x] T026 [P] Update `test/features/sync/sync_codec_test.dart` to assert GUID round-trips (no local `id` on the wire).

### 2e. Translator + appliers

- [x] T027 Create `lib/features/sync/domain/sync_id_translator.dart`: `resolveLocalContext(contextSyncGuid) -> localSpaceId` (create `SharedSpace` on first sight) and `resolveLocalEntity(entityType, entitySyncGuid) -> localRowId` (find by unique index, else signal allocate-on-insert). Pure over an `Isar`.
- [x] T028 Update `lib/features/sync/domain/entity_applier.dart`: change the base contract so appliers resolve the local row via `SyncIdTranslator` and rewrite GUID references on write (two-pass, dependency-ordered per `data-model.md` §4); update all 10 appliers.
- [x] T029 [P] Add `test/features/sync/entity_identity_test.dart`: the same logical entity arriving on two peers with different local ids lands on the same `syncGuid`-keyed row and merges (does not duplicate); a cross-reference resolves to the local id.

### 2f. Engine + recorder

- [x] T030 Update `lib/features/sync/repositories/sync_engine.dart`: dedupe/`headFor`/merge keyed by `entitySyncGuid`; `_authorize` resolves the local space from `contextSyncGuid`; two-pass dependency-ordered `_applyAll`; add `respond(connection, {peerId})`; advance send-side `lastSent*` when a snapshot is sent; envelope carries `contextSyncGuid`.
- [x] T031 Update `lib/features/sync/repositories/sync_recorder.dart`: change the generic `record()`/`recordDelete()` signatures to take `contextSyncGuid` + `entitySyncGuid` (drop `entityLocalId` as wire identity); have every typed wrapper pass the entity's own `syncGuid`; resolve the context's `syncGuid` by loading its `SharedSpace` row. Keep filtering `PairedContext` by `contextLocalId` (unchanged local bookkeeping).
- [x] T032 [P] Extend `test/features/sync/merge_determinism_test.dart` for GUID identity (winner is stable across distinct local ids).

### 2g. Session, providers, coordinator, lifecycle

- [x] T033 Create `lib/features/sync/providers/sync_session_provider.dart`: derive a `SyncSession` (unlocked keypair → `Ed25519ChangeSigner` + identity) from `unlockedKeyPairProvider`; `null` while locked.
- [x] T034 Update `lib/features/sync/providers/sync_recorder_provider.dart` to attach the session signer and HLC clock when a session exists; stay inert (no-op) when locked.
- [x] T035 Create `lib/features/sync/providers/sync_engine_provider.dart`: build `SyncEngine` with `trustedKeys` from active `PairedPeer` rows (`pairedPeersProvider`), the device clock and `SpaceAccessGuard`.
- [x] T036 Create `lib/features/sync/repositories/sync_coordinator.dart`: own `LanTransportHost` + `LanTransport`; bounded discovery loop; connect to relevant paired peers; run one connection per (peer, context) round (initiator `exchange`, responder `respond`); start/stop API.
- [x] T037 Create `lib/features/sync/providers/sync_coordinator_provider.dart` wiring the coordinator to the session, engine and paired peers.
- [x] T038 Wire lifecycle start/stop in `lib/main.dart`: start after first frame and on `resumed`; stop on `paused`/`detached` (extend the existing `_SealLifecycleObserver` pattern).
- [x] T039 [P] Add `test/features/sync/sync_coordinator_test.dart`: discover → connect → per-context round over `FakeTransportHub`; a non-paired peer's proof is refused.

**Checkpoint**: identity layer + running loop exist; stories can now be implemented and tested.

---

## Phase 3: User Story 1 - Phones stay in step (Priority: P1) 🎯 MVP

**Goal**: a change either phone makes in a shared space reaches the other automatically while co-present, with no duplicate and identical totals.

**Independent Test**: two paired phones (or two `FakeTransportHub` peers with **different** local ids) on the same network, app open; add an expense on A → it appears on B once; repeat B→A.

- [x] T040 [US1] In `lib/features/sync/repositories/sync_coordinator.dart`, enforce **pairwise, own-authored-only** snapshots (send only `authorIdentityId == myIdentity`) and drive both directions per shared context (FR-014, research R4).
- [x] T041 [US1] Verify/ensure `sync_recorder.dart` records to shared contexts on every repository write path (spaces/expenses/medical) via the wired provider; fix any context that still records nothing.
- [x] T042 [P] [US1] Add `test/features/sync/convergence_delivery_test.dart`: two peers with distinct local ids; a create and an edit on each converge; a member's edit to an Owner-created row merges into the **same** row (SC-001/SC-003/SC-007).
- [x] T042a [US1] Add `test/features/sync/sealed_delivery_test.dart`: a sealed month delivered across two peers with **different** local ids is byte-identical on both, re-renders identical totals from each device's own inputs, and a post-seal edit arriving from a peer is refused by `_authorize` (`monthKeyOf` → sealed) and never changes sealed content (FR-005/SC-006).
- [x] T043 [US1] Migrate `test/features/sync/convergence_integration_test.dart` off the same-local-id assumption (use distinct ids; assert GUID-keyed convergence).

---

## Phase 3b: Bug fix — membership key consistency (user-reported)

**Goal**: a profile that owns an `Identity` (i.e. any paired/syncing phone) resolves its own memberships and role, so a shared space is visible to the person it was granted to and the Owner's own role gate reads correctly.

**Root cause**: membership rows are **stored** under the synthetic `sharedMemberKey`/`remoteProfileIdFor(fingerprint)` (`spaces_repository.dart:104/309`, `pairing_service.dart:537`), but every **read** path looks them up by the raw local `UserProfile.id` (`spaces_providers.dart:24/40/84`). The two only agree for a 011-local profile with no `Identity`.

**Independent Test**: pair a second phone, add it to a space from the Owner's phone → the space appears in the member's switcher and the member sees their own role; the Owner still sees their own Owner role and the member list.

- [x] T060 [Bug] Resolve membership reads by `sharedMemberKeyForLocalProfile(isar, profileId)` instead of the raw id in `lib/features/spaces/providers/spaces_providers.dart`: `myMembershipsProvider` (L24), `mySpacesProvider` (L40) and `activeSpaceMyRoleProvider` (L84), so an identity-bearing profile matches its own rows.
- [x] T061 [P] [Bug] Add a regression test (new `test/features/spaces/membership_key_test.dart` or extend `spaces_repository_test.dart`): a profile with an `Identity` is granted a membership keyed by its fingerprint and still resolves its spaces (`mySpacesProvider`) and its role (`activeSpaceMyRoleProvider`); a 011-local profile with no `Identity` is unchanged.

---

## Phase 3c: Bug fix — honest member removal (user-reported)

**Goal**: removing a member either works, or tells you the **real** reason it was refused; and the "Remove" affordance is not offered when it cannot work.

**Root cause**: `lib/features/spaces/presentation/space_settings_section.dart:353-361` catches **any** `UnauthorizedSpaceAction` and hard-codes the text "Cannot remove the only Owner.", so an unrelated failure (e.g. `assertManage` failing, "Not a member", a sealed-month rule) is misreported as the owner rule.

**Independent Test**: as Owner, remove an Editor → it succeeds and the row disappears; try to remove the last Owner → no Remove affordance (or a message naming the real rule); the SnackBar text always matches the rule that fired.

- [x] T062 [Bug] In `lib/features/spaces/presentation/space_settings_section.dart`: surface the real `UnauthorizedSpaceAction.message` in the SnackBar instead of the hard-coded text; proactively hide/disable "Remove" for the space's last Owner and for the acting profile itself (I1/I2). *Landed 2026-10-18: `_removeMember` now catches `on UnauthorizedSpaceAction catch (error)` and shows `SnackBar(content: Text(error.message))`, so the refusal text is the rule that actually fired; the old guessed text is gone from the whole app (`grep` finds no "Cannot remove the only Owner" in `lib/`). The manage `PopupMenuButton` is already gated by `isOwner && member.profileId != myRole?.profileId`, so the acting profile — which is the space's last Owner whenever it is an Owner — carries no Remove affordance, and a non-Owner sees no manage menus at all.*
- [x] T063 [P] [Bug] Add a widget test asserting (a) the SnackBar shows the **actual** refusal message and (b) the Remove affordance is absent for the last Owner and for the acting profile (I2). *Landed 2026-10-18: new `test/features/spaces/member_removal_guard_test.dart` (2 widget tests) drives the real settings section against an identity-keyed Owner + a paired Editor: (a) a stubbed repository that throws the real last-Owner message reaches the SnackBar verbatim while the old guessed text never appears; (b) the acting profile's own tile holds no "Manage member" menu while the other member's does (and its menu really carries Remove), so the absence is not vacuous.*
- [x] T064 [Bug] Render each member's **name, role, and which device/contact they are** (join `PairedPeer` by `remoteProfileIdFor(peerIdentityId)` for remote members) in the members list, so a paired contact is no longer an anonymous "Profile" row (I3). *Landed 2026-10-18: `memberDisplayNamesProvider` (`lib/features/spaces/providers/spaces_providers.dart`) maps all three membership-key forms — the raw `UserProfile.id` (pre-012), the identity-keyed local profile via `sharedMemberKey(fingerprint)`, and a paired contact via `remoteProfileIdFor(peerIdentityId) → peerUsername`; the three lookups in `lib/features/spaces/presentation/space_settings_section.dart` (member list, remove confirmation, transfer dialog) now read it instead of a raw-id-only map that resolved nobody on a synced phone. Covered by `test/features/spaces/member_display_name_test.dart` (3 widget tests: list names, remove confirmation, transfer dialog).*

> Note: the automated two-phone bootstrap test for I4 is already covered by **T046** in Phase 4.

---

## Phase 3b.1: Bug fix — an added person actually receives the space, both ways

**Goal**: when the Owner adds a person, that person's phone ends up with the space's **real** name/currency/income, the Owner's membership, and every month/expense already in it — and the added phone can send its own edits back. No blank "Shared space" placeholder, no one-way-only sharing.

**Root cause**: `SyncRecorder._append` (`sync_recorder.dart:535-541`) drops any record whose context has no active `PairedContext` yet. But the space, the Owner membership and any early money are created **before** anyone is added — so they are never journaled, and a newly-added phone only ever receives the one "joined" record plus a bare `resolveLocalContext` placeholder (`sync_id_translator.dart:113`). Separately, the joining phone never creates a `PairedContext`/`SyncCursor` of its own, so its edits are dropped by the same check and never flow back.

**Independent Test**: Owner A creates a space, puts a month + expense in it, then adds paired contact B → co-present + open → B's phone shows the space with the **real** name/currency/income, A as Owner, and the month + expense; B edits an expense → it reaches A. A paired peer sending a GUID B was never added to creates nothing on B.

- [x] T066 [Bug] Journal every shared-space write: remove the "no paired context → drop" early-out in `SyncRecorder._append` (`lib/features/sync/repositories/sync_recorder.dart:535-541`) so the space, the Owner membership and all money written before a person was added are recorded and signed. Sending stays gated per-peer by the coordinator's active `PairedContexts` (`sync_coordinator.dart:214`), so nothing new leaks.
- [x] T067 [Bug] Mirror the context on the joining phone: when a device applies a `SharedMember` row that makes **itself** a member of a space, create the matching `PairedContext` for the authoring peer (same rows `pairing_service.dart:_persistContext` writes), so the joining phone records and sends its own edits (two-way). (`_advanceReceived` already creates the `SyncCursor`.)
- [x] T068 [P] [Bug] Add `test/features/sync/join_history_test.dart`: two Isar devices; A creates a space, puts a month + expense, then adds B; after one `exchange`, B has the space with the **real** name/currency/income, A's Owner membership and the money rows — and B's own edit flows back to A on the next round.
- [x] T069 [Bug] Discard junk spaces: after applying an inbound snapshot, if this device has **no** membership row in the resolved space, delete the bootstrapped space row (a paired peer cannot litter the switcher with fake spaces). Keys off the applied records' contexts (not the envelope GUID) and keeps the space when an active shared `PairedContext` exists.
- [x] T070 [P] [Bug] Add a security test: a paired peer sends a snapshot naming a `contextSyncGuid` this device was never added to → the space is discarded and no membership/money row survives.
- [x] T071 [Bug] Show a **"Waiting for first sync…"** state instead of the bootstrap placeholder name: when a membership exists for a space whose row is still the bare `resolveLocalContext` placeholder (name "Shared space"), render the waiting label rather than the wrong name/currency. (`SharedSpace.isPendingSync` + `displayName`.)
- [x] T072 [P] Add a widget test asserting the waiting label shows for a bootstrap-placeholder space and disappears once the real `SharedSpace` row arrives.

> Scope note: no server, no background service, no new wire messages, no pairing-handshake change. Journal growth (records for never-shared spaces accumulate) is a known future prune, deliberately not built here.

---

## Phase 3b.2: Bug fix — one identity unlock per launch, retryable, and a way to remove a person

**Goal**: unlocking the identity key prompts **once** per launch, is retried on demand instead of sticking on "no", and adding/removing a person is possible and safe. Reported on hardware as: *"Your identity stayed locked, so nothing was shared."* and *"I have to scan my fingerprint ~3 times before entering the app"*, plus *"there is no way to remove/unpair someone I added"*.

**Root cause**: three independent faults.

1. *Locked forever.* `unlockedKeyPairProvider` (`lib/features/pairing/providers/pairing_providers.dart:127`) is a `FutureProvider`: it evaluates **once** and memoises the answer. A cancelled or dropped prompt returns `null`, which is then served to every later `signingPairingServiceProvider` read — so `invite_sheet.dart:92`, `pair_device_screen.dart:59` and `scan_contact_into_space_screen.dart:77` all report the identity stayed locked with no way to retry.
2. *N prompts at cold start.* `_SyncLifecycleObserver`'s constructor (`lib/main.dart:95-102`) eagerly evaluates `syncCoordinatorProvider` → `syncSessionProvider` → `unlockedKeyPairProvider`, firing a `local_auth` prompt (reason "Pair with a device") at the same moment `AppLockGate._unlock` (`app_lock_gate.dart:30-32`) fires its own ("Unlock BudgetBuddy"); `deviceAuthEnabledProvider` flipping `false → true` when the consent row settles invalidates it a third time. Concurrent `authenticate()` calls are exactly what produces `W/BiometricFragment: Success/Error not sent to client. Client is not awaiting a result.` — the losing result is discarded, hence the repeated scans and the cached `null`.
3. *No remove-person.* `lib/features/pairing/presentation/people_screen.dart` has no action on a contact, and `PairingService.unpair` (`pairing_service.dart:140-159`) only deactivates the `PairedContext`s — it never deletes the `PairedPeer` row, so a person can never leave the People list. The member "Remove" popup in `space_settings_section.dart:339-372` also has an empty `onSelected` and no confirmation, so a single mis-tap removes a member irreversibly.

Related log noise fixed in the same pass: `UnauthorizedSpaceAction … (needs Owner/Editor)` on `createSpace` (HEAD's `MonthMoveOperations._member` resolves by raw profile id while `createSpace` writes the row under `sharedMemberKeyForLocalProfile`; the working tree already fixes `month_move_operations.dart:524-536` + `create_space_with_identity_test.dart`, but `SpacesRepository._member` at `spaces_repository.dart:463-470` still has the old single-key lookup, so `updateSpace`/`invite`/`removeMember`/`transferOwnership` share the landmine), the unhandled `NsdError ("Maximum outstanding requests reached")` from the bare `nsd.register` call (`lan_transport.dart:315`), and the duplicate `<default FloatingActionButton tag>` Hero assertion.

**Independent Test**: cold start with device auth granted → **exactly one** fingerprint scan to reach the app; cancel it → the lock screen offers Unlock again and the next tap re-prompts (retry works); *Add a person* → at most one further scan and no "identity stayed locked" banner; People → Remove → a confirmation appears first, and only after confirming does the person vanish from People and stop syncing.

- [x] T073 [Bug] Replace `unlockedKeyPairProvider` in `lib/features/pairing/providers/pairing_providers.dart` with a single-flight unlock session (`NotifierProvider<DeviceKeySession, SimpleKeyPair?>` exposing `Future<SimpleKeyPair?> require({required String reason})` + `void lock()`): concurrent callers await the **same** in-flight prompt, an unlocked key is returned without re-prompting, and a cancelled/failed prompt stores nothing and clears the in-flight flag so the next `require()` genuinely re-prompts.
- [x] T074 [Bug] Make the app-lock gate the only prompt source at cold start: `lib/features/identity/presentation/app_lock_gate.dart` routes `_unlock()` through `require(reason: 'Unlock BudgetBuddy')` and only clears the lock once the key is out; `lib/features/sync/providers/sync_session_provider.dart` watches the session's **value** (never `.future`) so sync can never originate a prompt and simply stays quiet while locked; `lib/main.dart` keeps its lifecycle observer but reads only prompt-free state. **Follow-up 2026-10-18 (found on hardware, `Troubleshoot.md`):** the "key is not out while the gate is shut" guard called `DeviceKeySession.lock()` *inside* `build`, which Riverpod rejects with *"Tried to modify a provider while the widget tree was building"* — the write now runs from `_lockWhenShut()` via `addPostFrameCallback` (the decision stays synchronous, so the lock screen still paints on the decision frame), `lock()` early-returns when nothing is held, and `test/features/identity/app_lock_gate_test.dart` fails on any such framework exception.
- [x] T075 [Bug] Route the three signing flows through `require(...)` from the button handler — `lib/features/pairing/presentation/pair_device_screen.dart:57`, `lib/features/spaces/presentation/invite_sheet.dart:90`, `lib/features/spaces/presentation/scan_contact_into_space_screen.dart` — so a cancel leaves the session retryable instead of sticky-null.
- [x] T076 [P] [Bug] Add `test/features/pairing/device_key_session_test.dart` with a fake `DeviceAuthenticator`: (a) two concurrent `require()` calls trigger **one** prompt and both resolve to the same key; (b) a cancelled prompt leaves the session retryable — the next `require()` prompts again; (c) `syncSessionProvider` stays `null` (and prompts zero times) while locked.
- [x] T077 [Bug] Add person removal: `PairingService.forgetPeer({required String peerIdentityId})` in `lib/features/pairing/repositories/pairing_service.dart` (deactivate **every** `PairedContext`, then delete the `PairedPeer` row); give each contact in `lib/features/pairing/presentation/people_screen.dart` a trailing menu behind an `AlertDialog` confirmation (copy style of `paired_devices_section.dart:34-55`) that also calls `SpacesRepository.removeMember` for the shared spaces where the acting profile is Owner, and tells the user plainly when it is not. Keys: `removePerson_<peerIdentityId>`, `confirmRemovePersonButton`.
- [x] T078 [P] [Bug] Add a test for removal: nothing is written unless the dialog is confirmed; after confirming, the `PairedPeer` row is gone and its `PairedContext`s are inactive.
- [x] T079 [Bug] Membership lookup + guarded member removal: give `SpacesRepository._member` (`lib/features/spaces/repositories/spaces_repository.dart:463-470`) the same uniform-key-plus-raw-id resolution `MonthMoveOperations._member` already has; in `lib/features/spaces/presentation/space_settings_section.dart` move the remove/transfer work out of `PopupMenuItem.onTap` into the currently-empty `onSelected` and put a confirmation dialog in front of it.
- [x] T080 [Bug] Wrap `nsd.register` in `lib/features/sync/transport/lan_transport.dart:315` in try/catch (best-effort registration, matching the existing `startDiscovery` handling) so a maxed-out NSD table can no longer surface as an unhandled `NsdError`.
- [x] T081 [Bug] Give the two `FloatingActionButton`s distinct explicit `heroTag`s (`lib/features/expenses/presentation/expenses_screen.dart:194`, `lib/features/expenses/presentation/category_list_screen.dart:62`) to clear the duplicate-Hero assertion.
- [x] T082 [P] Run the gate: `dart format lib test` → `flutter analyze --no-pub` → `flutter test`, all green with the pre-existing suite intact, plus the manual checklist (one scan to enter; cancel-then-retry works; one scan per *Add a person*; Remove person confirms before deleting). *Automated gate green 2026-10-18: `dart format lib test` clean, `flutter analyze --no-pub` no issues, `flutter test` 697 passed + 1 pre-existing skip. The on-device checks (one scan to enter; cancel-then-retry; one scan per Add-a-person; Remove confirms first) are to be confirmed on hardware.*

> Scope note: no change to the pairing handshake, the wire protocol or the keystore storage. The unlock session lives in memory only — `lock()` on app-lock keeps FR-002's "key is out only while unlocked" behaviour exactly as it is today.

---

## Phase 4: User Story 2 - A space arrives on the member's phone (Priority: P1)

**Goal**: a space an Owner adds a contact to materializes whole on the member's phone on next co-presence, usable offline, never half-applied.

**Independent Test**: Owner A adds paired contact B to a space B has never seen; co-present + open → the space appears on B with correct role and identical contents and survives a restart.

- [x] T044 [US2] Implement first-sight materialization in the apply path (`lib/features/sync/domain/sync_id_translator.dart` + `lib/features/sync/repositories/sync_engine.dart`): create the local `SharedSpace` from the incoming row by GUID, then its `SharedMember` rows, then contents (FR-003, research R5a). *Landed: `sync_engine.dart:213` resolves the local space from the signed context GUID and bootstraps it on first sight; the sender fills the history via `SyncRecorder.backfillContext` (`sync_recorder.dart:509`, called from `sync_engine.dart:157`). **Two-phone retest confirmed 2026-10-18** — the second phone shows the shared space after one co-present round.*
- [x] T045 [US2] Rebind the receiver's `PairedContext` and `SyncCursor` to the newly created local space id on first sight (`lib/features/sync/repositories/sync_engine.dart`, and `lib/features/pairing/repositories/pairing_service.dart` for the pairing-adopted id path). *Landed: the joining phone mirrors the `PairedContext` it was granted (`sync_engine.dart:577-610`, T067) and `_cursor` (`sync_engine.dart:526`) keys the `SyncCursor` to the materialized local id, so its own edits flow back.*
- [x] T046 [P] [US2] Add `test/features/sync/bootstrap_delivery_test.dart`: a context the receiver has never seen materializes whole (space + members + months + expenses + directory); totals match; an interrupted transfer is never half-applied (SC-002/SC-003). *Landed and green in the full suite (2026-10-18: `dart format lib test` clean, `flutter analyze --no-pub` no issues, `flutter test` **716 passed + 1 pre-existing skip**).*

---

## Phase 5: User Story 3 - I can see whether my phone is up to date (Priority: P2)

**Goal**: an honest **per-space** state — "waiting for peer" only while a change is still pending, "in progress" while exchanging, "up to date" once nothing is pending, plus a visible conflict count — shown beside the month and in space settings.

**Independent Test**: take the peer offline and make a change → "waiting for peer"; bring the peer back → clears to "up to date"; two spaces show independent states.

- [x] T047 [US3] Rework `lib/features/sync/providers/sync_status_provider.dart` into `StateNotifierProvider.family<SyncStatusNotifier, SyncStatusState, int>` keyed by the **local** space id; add `pending` to `SyncStatusState`; derive status from `SyncCursor` + the local change-log. Internal enum keeps `syncing`; the user-facing label is "in progress" (FR-008, research R6). *Landed 2026-10-18: `syncStatusProvider` is now a `.family<…, int>`; `SyncStatusState.pending` is persisted-derived and `status` is a **derived getter** (`exchanging → syncing`; `pending > 0 → waitingForPeer`; else `converged`), so "up to date" while something is queued is structurally impossible (SC-005). New `SyncStatusFactsReader` (plain class over `Isar`, so it is testable without a running app) derives `pending` from the change-log rows whose `authorIdentityId == Identity.fingerprint` and whose HLC is above the **lowest** `lastSent` watermark across the space's **active** `PairedContext` peers (no active peer ⇒ everything still owed), plus summed `SyncCursor.conflictCount` and the newest cursor `updatedAt` as `lastSyncedAt` (survives a restart); `syncStatusFactsProvider` (`FutureProvider.family<SyncStatusFacts, int>`) is the Riverpod wrapper and is an `AsyncError` whenever Isar is closed, which is what keeps the existing widget tests safe. **Prerequisite fixed along the way:** T030 claims the engine advances the send-side `lastSent*`, but no code wrote it, so `pending` could never clear; `SyncEngine._advanceSent` now moves the watermark to the sent snapshot's head **only after the peer's ack** (a dropped round leaves it, so the badge keeps saying "waiting for peer" rather than lying). Pinned by the new `test/features/sync/sync_sent_watermark_test.dart`, verified non-vacuous (commenting out the call fails the test) and by the reader tests in `test/features/sync/sync_status_test.dart` — 18 tests, green in the 2026-10-18 full gate (`dart format lib test` clean, `flutter analyze --no-pub` no issues, `flutter test` **733 passed + 1 pre-existing skip**).*
- [x] T048 [US3] Update `lib/shared/presentation/widgets/sync_status_chip.dart` to take a `spaceId` and read the family provider (keep the `syncStatusChip` key; keep conflict display). *Landed 2026-10-18: `SyncStatusChip({required int spaceId})` watches `syncStatusProvider(spaceId)` and keeps `Key('syncStatusChip')`. Labels are the user's words: **'Waiting for peer'** / **'In progress'** / **'Up to date'**, and with conflicts **'Up to date · 2 conflicts'** (singular handled) — conflicts are still shown, never hidden (FR-007). The label sits in a `Flexible` with ellipsis so the badge can shrink beside the month instead of overflowing a phone app bar. Widget tests in `sync_status_test.dart` (`SyncStatusChip (T048)`, 4 tests) cover every label and prove two `spaceId`s render two independent badges.*
- [x] T049 [US3] Mount the chip **beside the month** on the shared-space money screen in `lib/features/dashboard/presentation/dashboard_screen.dart` (and/or `month_navigator.dart`). *Landed 2026-10-18: the badge is mounted as the dashboard app bar's `bottom` strip — a 30 px `PreferredSize` holding `SyncStatusChip(spaceId: …)`, left-aligned, shown only when `activeSpaceIdProvider` is non-null (a personal month keeps the shorter app bar). It is inside the `AppBar`, so it is visible without opening settings and never scrolls away. **Deliberate deviation:** the badge sits directly *under* the month rather than on the title line, because that line is already full — measured on a 360 px-wide phone the month navigator wants 288 px while the title is handed only 232 px. That 56 px overflow is **pre-existing, not introduced here**: probed with no badge anywhere in the tree, the personal dashboard still overflows by 56 px at 360 px. Left for a future UI pass (out of scope for US3) and flagged in the phase report. Widget tests `the space status on the money screen (T049, US3 AC6)` mount the real `DashboardScreen` and assert the chip is inside the `AppBar` directly below `MonthNavigator`, carries the active space's id, reports that space's state ("Waiting for peer" with a queued change), shows nothing on a personal month, and adds no overflow of its own at 360 px (US3 AC6).*
- [x] T050 [US3] Update `lib/features/spaces/presentation/space_settings_section.dart` to pass the active space id to the chip (replace the current no-arg mount). *Landed 2026-10-18: the settings row now reads `SyncStatusChip(spaceId: space.id)`. The four existing widget tests that mount `SpaceSettingsSection` without Isar still pass, which is the check that the new facts provider fails into `AsyncError` instead of throwing from a provider body.*
- [x] T051 [US3] Drive the per-space status from the coordinator around each round in `lib/features/sync/repositories/sync_coordinator.dart` (`syncing` → recompute `pending` → `converged`/`waitingForPeer`, carry `conflictCount`). *Landed 2026-10-18: `SyncCoordinator` takes `onRoundStart`/`onRoundEnd` and hands them to `engine.exchange`/`engine.respond`; the engine reports the **resolved local** space id (`exchange`/`respond` gained the same optional callbacks). The coordinator alone could not do this: only the engine learns the responder's local id, after it maps the incoming envelope GUID. `syncCoordinatorProvider` wires the callbacks to `roundStarted()` / `roundFinished()` and then `ref.invalidate(syncStatusFactsProvider(spaceId))`, so `pending` catches up with what the round actually delivered; the callbacks swallow their own failures so a cosmetic badge error can never be mistaken for a dropped exchange. Evidence: `test/features/sync/sync_coordinator_test.dart` now records the boundaries and asserts A reports local id **1** while B reports local id **2** (its own, not the GUID A knows it by); the engine-level reporting is covered by `sync_sent_watermark_test.dart`.*
- [x] T052 [P] [US3] Update `test/features/sync/sync_status_test.dart` for per-space pending semantics; add widget tests asserting the chip is beside the month and reads per-space state (US3 AC6/AC7). *Landed 2026-10-18: the file was rewritten around four groups (18 tests, all green) — (1) per-space phase: nothing pending reads "up to date", a queued change reads "waiting for peer", an in-flight exchange reads "in progress" and then settles honestly, two spaces hold independent states, a kept-aside conflict is surfaced without faking a phase; (2) `SyncStatusFactsReader` against a real Isar: an undelivered change is pending, a delivered one is not, the **lagging** peer decides, an unpaired peer cannot pin the space forever, the peer's own history is never counted, conflicts are summed; (3) chip labels and two independent badges; (4) the mount in the app bar directly under the month (and no badge on a personal month, plus a 360 px-wide phone check). Two real bugs were caught by these tests during implementation: the watermark was seeded with `Hlc.genesis` so it could never be lowered (a delivered change stayed "pending"), and the chip's `spaceId` could not be read off the keyed widget.*

---

## Phase 6: User Story 4 - Offline & private (Priority: P2)

**Goal**: with no peer reachable everything works and nothing is transmitted; only two paired, proven, co-present phones exchange; unpair/leave stops delivery.

**Independent Test**: with a paired space and no peer reachable, use the app fully offline and confirm zero transmission; a non-paired device is refused before any data; unpairing stops that context's delivery.

- [x] T053 [US4] Ensure the coordinator no-ops when the app is backgrounded or the identity is locked, and transmits nothing when no paired peer is reachable (`lib/features/sync/repositories/sync_coordinator.dart`; confirms FR-007/FR-009). *Verified 2026-10-18: the lifecycle observer (`main.dart:94`) stops the coordinator on background/pause/detach and on session loss (the locked identity makes `syncCoordinatorProvider` return `null`, so the previous coordinator is stopped); the coordinator itself is inert while stopped and skips discovery entirely when no `PairedPeer` exists. Locked in by the new `sync_privacy_test.dart` test "offline: a paired peer that is unreachable causes no transmission" — with a real paired peer and a pending change but nothing discovered, zero connections are dialed and zero payloads are sent (`offline.connects == 0`, `offline.payloads` empty).*
- [x] T054 [US4] Implement FR-010 stop-delivery: on unpair/leave, deactivate the context so the coordinator neither dials nor accepts it (`lib/features/sync/repositories/sync_coordinator.dart`, using `PairedContext.active`). *Two gaps closed 2026-10-18. **Dial** was already gated (`_activeSharedContexts` filters `active == true`; `unpair`/`forgetPeer` set `active = false`). **Accept** was not: the responder (`sync_engine.dart` `respond`) applied an incoming snapshot and replied with its own records even for a context the device had left. Added `_contextAccepted(peerId, localContextId)` — an existing **inactive** `PairedContext` refuses the snapshot (nothing applied, nothing replied; the round ends), while a context with no local row is still allowed for first-sight bootstrap. Also `spaces_repository.leaveSpace` now deactivates every `PairedContext` for the space (leaving previously left them active). Evidence: `sync_privacy_test.dart` "a deactivated context is neither dialed nor accepted" and the extended `spaces_repository_test.dart` `leaveSpace` test (`context.active == false`).*
- [x] T055 [P] [US4] Add `test/features/sync/sync_privacy_test.dart`: offline run performs no send; a non-paired proof is refused (`droppedBadSignature` path) before any apply; a deactivated context is not exchanged (SC-004/SC-006/SC-008). *Landed 2026-10-18: 3 tests — (1) offline with an unreachable paired peer dials nothing and sends zero bytes (SC-004); (2) a record signed by a device we never paired returns `ApplyOutcome.droppedBadSignature` and leaves no row (SC-008, refused before any apply); (3) a deactivated context is neither dialed nor accepted (FR-010). Tests 1 and 2 passed on the pre-fix code; test 3 was watched failing (`Expected: null / Actual: <Instance of 'Expense'>`) before the `respond` guard was added.*
- [x] T055a [US4] Add `test/features/sync/sync_confidentiality_test.dart`: assert the coordinator's session is only established after the paired contact's key proves possession (handshake binds the trusted key), that a device failing the proof receives/emits zero payload bytes, and record the passive-listener check in quickstart Scenario E (FR-015/SC-008). *Landed 2026-10-18: 3 tests over real loopback sockets (the code `FakeTransport` cannot cover) — (1) a responder proving a **different** key is refused with `TransportHandshakeException` and the dialer emits only the handshake `hello` (no snapshot: zero payload bytes); (2) a responder proving the **pinned** key opens the session; (3) a plain non-TLS client never yields a session, so the channel is genuinely TLS. The passive-listener check is already recorded in `quickstart.md` Scenario E step 2 (laptop capture sees only TLS). Note (verified, not changed per research R8 "reuse as-is"): the signed-nonce proof is verified by the **dialer**; the responder yields only for a *paired* peer identity and the engine still drops any record whose signature is not trusted (`droppedBadSignature`, T055).*

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T056 [P] Sweep for dead local-id wire paths left behind (local `id`/foreign int keys in codecs/appliers) and remove them; keep comments referencing `contracts/entity-identity.md`.
- [ ] T057 Run the full gate: `dart format lib test` then `flutter analyze --no-pub` then `flutter test` — all green with the pre-existing suite intact, **and confirm FR-013 regressions still hold**: no vault entity has a codec, no `sharedSpaceId == null` (personal) row is ever recorded, and the last-Owner rule holds (add these assertions to `sync_privacy_test.dart`).
- [ ] T058 Update the 014 KNOWN GAP pointer in `specs/014-charts-and-analytics/tasks.md` to note the gap is closed by 015 (reference the delivered tasks).
- [ ] T059 Validate the `specs/015-wire-device-sync/quickstart.md` scenarios (automated suites + the two-phone manual checklist).
- [ ] T065 [P] Update `README.md` to reflect the current app (I5): correct the **Shared spaces & cross-device sync** line to be honest about what works vs. in progress; add the shipped features missing from the file (sealed/frozen months, currency-conversion footnote & degraded amounts, money field, QR contact pairing & People list, space roles Owner/Editor/Viewer, profile switcher/deletion, app theme, bring-in-past-months, time-picker safety); add a **Status** section listing specs `011`–`015` and their state.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: depends on Setup; **blocks all user stories**. Within it: models (2a) → codegen/migration (2b) → signing (2c) → codecs (2d) → translator/appliers (2e) → engine/recorder (2f) → session/providers/coordinator/lifecycle (2g).
- **US1 (Phase 3)** and **US2 (Phase 4)**: depend on Foundational. US2's bootstrap builds on the same apply path as US1; US2 can start once 2e/2f are done.
- **Bug fixes (Phase 3b / 3c / 3b.1 / 3b.2)**: discovered on real hardware after US1; independent of US2 but must land **before** US2. The member-key fix (3b) is what makes an arriving space visible, and 3b.1 is what makes the space arrive *whole* and flow both ways — US2's acceptance test depends on both. 3b.2 is what lets anyone actually *reach* those flows on a real phone (one retryable unlock) and undo them (remove a person), so it gates the manual two-phone checklist.
- **US3 (Phase 5)**: depends on Foundational (2f cursors). Independent of US1/US2 behaviour.
- **US4 (Phase 6)**: depends on Foundational (2g coordinator).
- **Polish (Phase 7)**: after the desired stories are complete.

### User Story Dependencies

- **US1 (P1)**: independent after Foundational — the core delivery behaviour.
- **US2 (P1)**: independent after Foundational — first-sight bootstrap; shares the apply path but is separately testable.
- **US3 (P2)**: independent after Foundational — pure status surfacing.
- **US4 (P2)**: independent after Foundational — safety/privacy verification and stop-delivery.

### Within Each Story

- Test task before its implementation task where both exist is preferred (TDD); the plan's tests must fail first.
- Models → codecs → appliers → engine → orchestration is the order inside Foundational; do not reorder.

### Parallel Opportunities

- All of **2a** (`T003`–`T010`) run in parallel (different files).
- All of **2d** (`T016`–`T025`) run in parallel (different codec files).
- `T014`, `T026`, `T029`, `T032`, `T039` (tests) run in parallel with adjacent implementation once their targets exist.
- After Foundational, US1–US4 test tasks can run in parallel across developers.

---

## Parallel Example: Foundational models

```text
T003 Add syncGuid to SharedSpace        (lib/core/models/shared_space.dart)
T004 Add syncGuid to SharedMember       (lib/core/models/shared_member.dart)
T005 Add syncGuid to MonthlyBudget      (lib/core/models/monthly_budget.dart)
T006 Add syncGuid to Expense            (lib/core/models/expense.dart)
T007 Add syncGuid to MedicalBill        (lib/core/models/medical_bill.dart)
T008 Add syncGuid to MedicalServiceType (lib/core/models/medical_service_type.dart)
T009 Add syncGuid to InsuranceProfile/FamilyMember/MedicalProvider (lib/core/models/insurance_profile.dart)
T010 Add syncGuid to Reimbursement      (lib/features/expenses/models/reimbursement.dart)
```

## Parallel Example: Foundational codecs

```text
T016 shared_space_codec.dart      T021 medical_bill_codec.dart
T017 shared_member_codec.dart     T022 family_member_codec.dart
T018 monthly_budget_codec.dart    T023 medical_provider_codec.dart
T019 expense_codec.dart           T024 medical_service_type_codec.dart
T020 reimbursement_codec.dart     T025 insurance_profile_codec.dart
```

---

## Implementation Strategy

### MVP First (US1 + US2, both P1)

1. Phase 1 Setup → Phase 2 Foundational (the identity layer + running loop).
2. Phase 3 US1 → validate a change reaches the other phone (STOP for a two-peer playground test).
3. Phase 4 US2 → validate a never-seen space materializes (STOP for the two-phone test).
4. This pair is the reported bug fixed; it is the smallest shippable increment.

### Incremental Delivery

1. Foundational → identity + loop in place.
2. US1 → delivery works (MVP core).
3. US2 → joining a space works.
4. US3 → honest status surface.
5. US4 → privacy/stop-delivery hardened.
6. Polish → gate green, docs updated.

### Notes

- The Phase-Builder-Agent flow applies: verify real code, build one phase, **STOP for the user's playground test**, then proceed. Do not batch phases.
- `[P]` tasks touch different files and have no incomplete dependency.
- After any model/codec change, run `dart run build_runner build --delete-conflicting-outputs` before `flutter analyze`.
- No git operations without an explicit request.
