---

description: "Task list for Multi-User Profiles & Shared Financial Spaces implementation"
---

# Tasks: Multi-User Profiles & Shared Financial Spaces (Unified)

**Input**: Design documents from `/specs/011-shared-financial-spaces/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Included. The spec explicitly mandates data-layer enforcement "covered by tests" (FR-003, FR-005, SC-001/SC-005), carries a mandatory "User Scenarios & Testing" section per story, and quickstart V1–V10 define runnable automated scenarios; tests are therefore generated per story and MUST fail before implementation.

**Organization**: Tasks are grouped by user story (US1–US6 from spec.md) to enable independent implementation and testing. Git is 🛑 hands-off — the user pushes.

## Format: `[P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US6)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify the baseline the feature builds on.

- [x] T001 [P] Verify baseline is green before any change: run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` from repo root and confirm zero failures (357 test cases, features 009/010 present)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story (schema, migration, context router, read-scoping, role guard, harnesses).

**CRITICAL**: No user story work can begin until this phase is complete.

### Models (Isar entities, data-model §2–3, research R1/R3)

- [x] T002 [P] Add `avatar String = ''` and `lastActiveAt DateTime?` to `UserProfile` in `lib/core/models/user_profile.dart` (FR-001, data-model §3.1)
- [x] T003 [P] Create `SharedSpace` model in `lib/core/models/shared_space.dart` — fields per data-model §2.1 (name, avatar, currency `@enumerated`, defaultIncome int minor units, createdByProfileId, createdAt)
- [x] T004 [P] Create `SharedMember` model + `SharedMemberRole` enum (owner/editor/viewer) in `lib/core/models/shared_member.dart` — `sharedSpaceId/profileId` unique composite index, role `@enumerated`, joinedAt (data-model §2.2)
- [x] T005 [P] Add `profileId int?`, `sharedSpaceId int?`, `sharedIncomeOverride int?` to `MonthlyBudget` in `lib/core/models/monthly_budget.dart` (data-model §3.2; composite `@Index` on `[profileId, yearMonth]` and `[sharedSpaceId, yearMonth]`)
- [x] T006 [P] Add `sharedSpaceId int?` with `@Index` to `Expense` in `lib/core/models/expense.dart` (data-model §3.3)
- [x] T007 [P] Add `sharedSpaceId int?` with `@Index` to `Reimbursement` in `lib/features/expenses/models/reimbursement.dart` (data-model §3.4)
- [x] T008 [P] Add `sharedSpaceId int?` with `@Index` to `MedicalBill` in `lib/core/models/medical_bill.dart` (data-model §3.5)
- [x] T009 [P] Add `sharedSpaceId int?` with `@Index` to `InsuranceProfile`, `FamilyMember`, `MedicalProvider` in `lib/core/models/insurance_profile.dart` and to `MedicalServiceType` in `lib/core/models/medical_service_type.dart` (data-model §3.6, R3)

### Schema registration + codegen + migration

- [x] T010 Register `SharedSpaceSchema` and `SharedMemberSchema` alongside the existing 15 collections in the `Isar.open(...)` list in `lib/core/database/isar_helper.dart:25-44`
- [x] T011 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate all `*.g.dart` for the new/modified models (required after T002–T010)
- [x] T012 Add migration step 12 (additive, empty body per house pattern `schema_migrations.dart:148-159`) and step 13 (ownership backfill: assign `profileId` to every existing `MonthlyBudget`; assign `profileId` to null-context `MedicalBill` via linked expense / `_pickProfile`; guarantee no money row is all-null-context) and bump `schemaVersion` 11 → 13 in `lib/core/database/schema_migrations.dart` (data-model §7, R9)

### Context Router (FR-004) + read-path scoping (research R8)

- [x] T013 [P] Create `ContextRef` value class + `budgetContextProvider` (derived from `activeSpaceIdProvider` + `activeProfileIdProvider` + `selectedYearMonthProvider`, invariant: exactly one of profileId/spaceId) in `lib/core/providers/budget_context_provider.dart`
- [x] T014 [P] Create `activeProfileIdProvider` (`StateProvider<int?>`, persisted marker) and rework `activeProfileProvider` in `lib/core/providers/active_profile_provider.dart` to return the selected row instead of `profiles.first` (R2)
- [x] T015 [P] Create `activeSpaceIdProvider` + derived `activeSpaceProvider` (watches `SharedSpace` row) in `lib/core/providers/active_space_provider.dart` (null = personal context)
- [x] T016 [P] Make `activeBudgetProvider` context-aware — filter by `(profileId, yearMonth)` or `(sharedSpaceId, yearMonth)` composite in `lib/core/providers/active_budget_provider.dart:13-21`
- [x] T017 [P] Re-point engine reads through `budgetContextProvider`: `monthlyExpensesProvider` and `monthlyReimbursementsProvider` in `lib/features/engine/providers/true_available_provider.dart`, plus `monthlyOriginReimbursementsProvider` in `lib/features/engine/providers/month_summary_provider.dart` (context filter + yearMonth; reimbursement via `originYearMonth`)
- [x] T018 [P] Re-point expense reads: `ExpensesNotifier._loadExpenses` in `lib/features/expenses/providers/expenses_provider.dart:65-69` and repository filters (`watchExpenses/getExpenses/watchReimbursementsForMonth/watchOrphanedReimbursements`) in `lib/features/expenses/repositories/expense_repository.dart` and `lib/features/expenses/repositories/reimbursement_repository.dart` to context scoping
- [x] T019 [P] Re-point medical reads through context: `medicalBillsProvider`, `medicalDisplayCurrencyProvider`, `medicalBudgetImpactProvider`, `patientShareTotalsProvider`, `medicalBillContextProvider` and directory providers in `lib/features/medical/providers/medical_providers.dart`, plus repository queries and `_syncLinkedExpense` in `lib/features/medical/repositories/medical_repository.dart` (R3 — bills + directory space-owned)
- [x] T020 [P] Make `MonthFinanceRepository` context-aware: `ensureMonth(contextRef, ym)`, `getMonth`, `watchMonth`, `saveOpeningBalance`, `saveConvertTo`, `saveNetSalaryOverride` (and new shared override save) in `lib/features/finance/repositories/month_finance_repository.dart`
- [x] T021 [P] Make `mainCurrencyProvider` resolve the space currency when a space is active (fallback to profile main currency) in `lib/features/settings/providers/settings_provider.dart:15-18`

### Role guard + invariant (contracts/space-roles, FR-003/005)

- [x] T022 Create `SpaceAccessGuard` (pure Dart: `canView`/`canEdit`/`canManage`, sealed-month no-role refusal, exactly-one-context invariant, `UnauthorizedSpaceAction`) + `spaceRoleGuardProvider` in `lib/features/spaces/repositories/space_role_guard.dart` (contracts/space-roles §3–4)

### Harnesses + migration tests

- [x] T023 Add `SharedSpaceSchema`/`SharedMemberSchema` to the schema list and make `seedBudget` context-aware in `test/features/medical/repositories/medical_test_harness.dart:62-96` (verify `rate_test_support.dart` needs no change — it opens rate-only schemas)
- [x] T024 [P] Write migration test: upgrading an existing DB assigns every existing month to the single personal profile, is byte-identical on amounts/seals/totals, and step 13 is idempotent on re-run (SC-003) in `test/core/database/migration_context_backfill_test.dart`

**Checkpoint**: Foundation ready — user stories can now begin in parallel.

---

## Phase 3: User Story 1 - I am my own profile (Priority: P1) — MVP

**Goal**: Create, name and switch between several personal profiles, each with isolated money data and its own avatar, main currency, income, font and theme; the dashboard shows only the active profile's data (spec US1).

**Independent Test**: Create a second profile, enter different expenses + currency in each, switch profiles, verify every screen shows only the active profile's data within one frame (US1 Independent Test).

### Tests for User Story 1 (MUST fail before implementation)

- [x] T025 [P] [US1] Write multi-profile context isolation test: profile A rows unreadable from profile B in 100% of cross-context cases; both-context/null-context writes refused (SC-001/SC-005) in `test/features/engine/context_isolation_test.dart`
- [x] T026 [P] [US1] Write profile switcher widget test: switch A→B updates dashboard/expenses/medical/currency; per-profile settings (avatar, main currency, font, theme, income) persist and render per profile (US1 AC2) in `test/features/settings/profile_switcher_test.dart`

### Implementation for User Story 1

- [x] T027 [P] [US1] Rework `saveBudget`/new-profile creation in `lib/features/budget_setup/providers/budget_setup_provider.dart` to support multiple profiles — first profile keeps `id = 1`, later profiles auto-increment; onboarding no longer assumes one profile (drop `profiles.first` at :90-104)
- [x] T028 [P] [US1] Create `ProfileSwitcherSection` (list profiles, show active, switch, create-new-profile flow) in `lib/features/settings/presentation/profile_switcher_section.dart`
- [x] T029 [P] [US1] Register `ProfileSwitcherSection` in `lib/features/settings/presentation/settings_screen.dart` and wire profile selection to `activeProfileIdProvider` + update `lastActiveAt` on switch
- [x] T030 [US1] Re-point single-profile writers to the *active* profile id instead of `.findFirst()`: `getDefaultNetSalary`/`saveDefaultNetSalary` in `lib/features/finance/repositories/month_finance_repository.dart:151-171`, `setMainCurrency`/`setThemeMode` in `lib/features/settings/providers/settings_provider.dart:36-79`, font write in `lib/features/settings/presentation/font_setting_section.dart:47-55`

**Checkpoint**: User Story 1 fully functional and testable independently — two profiles, isolated data, instant switch. **STOP and VALIDATE (MVP).**

---

## Phase 4: User Story 2 - I create a shared space and invite people (Priority: P1)

**Goal**: Create a space (name + emoji avatar + shared currency + "Our income"), invite local profiles with a role, creator becomes Owner, last-Owner invariant, Owner-only management enforced (spec US2).

**Independent Test**: Create a space, invite a second profile as Viewer, verify the Owner can edit space settings while the Viewer cannot (US2 Independent Test).

### Tests for User Story 2 (MUST fail before implementation)

- [x] T031 [P] [US2] Write `SpacesRepository` test matrix: creator→Owner, invite-only membership, role transitions, transfer, last-Owner leave blocked, remove member (FR-002/006/014; US2 AC2-4) in `test/features/spaces/spaces_repository_test.dart`
- [x] T032 [P] [US2] Write space creation widget test: create space (name/avatar/currency/income), Owner can edit settings, invited viewer cannot (US2 AC1 + US2 Independent Test) in `test/features/spaces/space_creation_test.dart`

### Implementation for User Story 2

- [x] T033 [P] [US2] Implement `SpacesRepository` (create/update space, membership CRUD, invite, setRole, removeMember, transferOwnership, leaveSpace — all guarded; last-Owner refused; transfer demotes former Owner to Editor) in `lib/features/spaces/repositories/spaces_repository.dart`
- [x] T034 [P] [US2] Create `SpaceSwitcher` (dropdown of memberships + "New space") and mount it in the app shell `lib/features/spaces/presentation/space_switcher.dart` + `lib/shared/presentation/app_shell.dart`
- [x] T035 [P] [US2] Create `CreateSpaceSheet` (name, emoji avatar, currency, "Our income", bring-in-past choice) in `lib/features/spaces/presentation/create_space_sheet.dart`
- [x] T036 [P] [US2] Create `SpaceSettingsSection` (space identity, Our income, members + roles, invite, transfer, delete) and `InviteSheet` (invite local profile or create new, pick role; Owner-only) in `lib/features/spaces/presentation/space_settings_section.dart` + `invite_sheet.dart`; register the section in `lib/features/settings/presentation/settings_screen.dart`
- [x] T037 [US2] Wire context switching: selecting a space sets `activeSpaceIdProvider`, selecting a profile clears it; both update `lastActiveAt`; dashboard/expenses/medical/settings render the space context via `budgetContextProvider` (I2/I5, contracts/context-router)

**Checkpoint**: User Stories 1 AND 2 both work independently (multi-profile and space+invites).

---

## Phase 5: User Story 3 - I bring my existing month in (whole-month sharing) (Priority: P1)

**Goal**: Move a complete financial month (budget, income, expenses, medical bills, reimbursements) from a personal profile into a shared space as one single copy — Move, never Copy — with income carried over and double-move blocked (spec US3).

**Independent Test**: Move an existing month with mixed expenses/medical bills/reimbursements into a space, then add an expense as an Editor and confirm both members saw the same updated single copy; moving the same year-month into the target again is blocked (US3).

### Tests for User Story 3 (MUST fail before implementation)

- [x] T038 [P] [US3] Write month-move lifecycle tests: move in/out, single copy (origin empty), income carried under space pot, double-move blocked with message, sealed past month allowed with totals identical (FR-007/008/010, SC-006) in `test/features/spaces/month_move_operations_test.dart`

### Implementation for User Story 3

- [x] T039 [P] [US3] Implement `moveMonth(from, to, yearMonth, {targetProfileId})` as ONE writeTxn in `lib/features/spaces/repositories/month_move_operations.dart`: guard `to.canView` + block if target owns the month; re-point MonthlyBudget/Expense/Reimbursement(originYearMonth)/MedicalBill context columns; re-point linked `Expense.budgetId`; move referenced directory rows (dedupe by name) (contracts/month-move-lifecycle §2, R5)
- [x] T040 [P] [US3] Implement income carry helper (one-cut round-half-away-from-zero via month seal/live table; verbatim when same currency) per `contracts/shared-income.md` §3 in `lib/features/finance/repositories/income_carry.dart`
- [x] T041 [P] [US3] Create `MoveMonthSheet` UI (choose target personal profile or space; error message when target already owns the month) in `lib/features/spaces/presentation/move_month_sheet.dart`, mounted from the dashboard month menu
- [x] T042 [US3] Integrate: move refuses for viewer/non-member and for target-already-owns case; sealed-month moves never modify stored amounts or seals (US3 AC4, spec edge cases)

**Checkpoint**: User Stories 1–3 independently functional (share a whole month).

---

## Phase 6: User Story 4 - Roles decide what each person can do (Priority: P1)

**Goal**: Viewer reads only, Editor edits money, Owner also manages people/space; enforcement holds at the data layer for every shared write and sealed months stay frozen for every role (spec US4).

**Independent Test**: As a Viewer attempt every edit action; as an Editor attempt every people-management action; verify both are refused with no data changes (US4 Independent Test).

### Tests for User Story 4 (MUST fail before implementation)

- [X] T043 [P] [US4] Write role-enforcement matrix at the data layer: each role (owner/editor/viewer/non-member) attempts every write path (expense, reimbursement, medical bill, month income, convert-to, space manage) and the guard refuses correctly; both/null-context writes refused; sealed shared month frozen for all roles (FR-005/012, SC-005) in `test/features/spaces/role_guard_matrix_test.dart`
- [X] T044 [P] [US4] Write viewer read-only widget test: in a shared space a Viewer sees months/expenses/bills but no add/edit/delete control is offered (US4 AC1) in `test/features/spaces/viewer_readonly_test.dart`

### Implementation for User Story 4

- [X] T045 [P] [US4] Apply guard to shared-space expense writes (add/edit/delete/restore/discard) in `lib/features/expenses/repositories/expense_repository.dart` (require canEdit; sealed-month refusal)
- [X] T046 [P] [US4] Apply guard to shared-space reimbursement writes (log, restore, discard) in `lib/features/expenses/repositories/reimbursement_repository.dart` and orphan ops in `expense_repository.dart`
- [X] T047 [P] [US4] Apply guard to shared-space medical writes (bill save/state/paid/logReimbursement, directory edits, `_syncLinkedExpense`) in `lib/features/medical/repositories/medical_repository.dart` (R3)
- [X] T048 [P] [US4] Apply guard to shared-space month-finance writes (income override, convert-to, opening balance) in `lib/features/finance/repositories/month_finance_repository.dart`
- [X] T049 [US4] Wire role capability into shared-space UI controls (hide add/edit/delete for Viewer; hide manage for Editor) in expenses/medical/dashboard/settings screens — UI mirrors the guard, guard stays authoritative (US4 AC3)

**Checkpoint**: User Stories 1–4 independently functional (full role safety).

---

## Phase 7: User Story 5 - The space keeps going forward (Priority: P2)

**Goal**: The sharing unit is the space, not the month: at creation choose how much past to bring in (this month / this year so far / everything) and every future month appears automatically with the same sealed-history guarantees (spec US5).

> **Note (2026-10-10)**: T050–T052 are pulled forward and implemented in the **Phase 10** iteration alongside the space-deletion flow and the current-month provisioning fix (see T062–T063).

**Independent Test**: Create a space with "this year so far", then let a new month begin and verify it appears with no action and behaves like a personal month (US5 Independent Test).

### Tests for User Story 5 (MUST fail before implementation)

- [x] T050 [P] [US5] Write space progression tests: bring-in-past (thisMonth/thisYear/everything) yields exactly the expected months; a new month appears automatically via context-aware `ensureMonth`; shared closed months behave like personal (offline, immutable, seal-driven) (US5 AC1-4, FR-011, SC-004) in `test/features/spaces/space_progression_test.dart`

### Implementation for User Story 5

- [x] T051 [P] [US5] Implement bring-in-past on space creation (seed `MonthlyBudget` rows for the chosen months inside the create-space transaction) in `lib/features/spaces/repositories/spaces_repository.dart` (data-model §2.1, FR-010)
- [x] T052 [US5] Ensure future months appear automatically: context-aware `ensureMonth(contextRef, ym)` on navigation in `lib/features/finance/repositories/month_finance_repository.dart` + `selectedMonthProvisioningProvider` in `lib/features/finance/providers/finance_providers.dart` (FR-011)

**Checkpoint**: User Stories 1–5 functional (spaces keep going without re-sharing).

---

## Phase 8: User Story 6 - Analytics placeholder (Priority: P2)

**Goal**: A context-aware Analytics placeholder on the dashboard in both personal and shared contexts — computes nothing, defers all real content to the separate Analytics feature (spec US6, FR-015).

**Independent Test**: Open the dashboard in a personal profile and then in a shared space; verify a visible placeholder appears in both, always matching the active context, and computes nothing (US6 Independent Test).

### Tests for User Story 6 (MUST fail before implementation)

- [X] T053 [P] [US6] Write Analytics placeholder widget test: visible in personal context, visible & distinct in shared context, re-renders on switch with no numbers lingering from the previous context, computes nothing (FR-015, SC-008) in `test/features/dashboard/analytics_placeholder_test.dart`

### Implementation for User Story 6

- [X] T054 [P] [US6] Create `AnalyticsPlaceholderCard` widget (reads `budgetContextProvider` for the label/section, no financial computation) in `lib/shared/presentation/widgets/analytics_placeholder_card.dart`
- [X] T055 [P] [US6] Mount `AnalyticsPlaceholderCard` on the dashboard `ListView` after `MonthSummaryDetails` in `lib/features/dashboard/presentation/dashboard_screen.dart:69` and on the shared dashboard view (same widget, context-aware)

**Checkpoint**: All six user stories independently functional.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation.

- [x] T056 [P] Re-label personal income settings to "My income" in `lib/features/finance/presentation/net_salary_section.dart`; confirm "Our income" lives in `SpaceSettingsSection` (FR-009 labels, shared-income contract)
- [x] T057 [P] Onboarding polish: after first profile creation, offer creating a first shared space immediately (spec edge "First launch / no profile yet") in `lib/features/budget_setup/`
- [x] T058 [P] Verify offline-everything: context switch, move, delete space, invites all work with airplane mode on (FR-016) — spot-test per `quickstart.md` V8
- [x] T059 Run final validation gate per `quickstart.md`: `dart format`, `flutter analyze`, `flutter test` all green; run quickstart V1–V10 scenarios; fix any regressions

---

## Phase 10: Space lifecycle completion — bring-in-past, provisioning fix, and space deletion (follow-up iteration, 2026-10-10)

**Why**: User playground of Phase 5 exposed two gaps: (1) a space with any month can never be deleted — the owner sees "move or delete its month first" but no per-month resolution UI and no delete-month operation exists; (2) moving the current personal month into a newly created space is refused with "the target already owns this month" because `selectedMonthProvisioningProvider` eagerly writes an empty current-month budget on context switch, while `createSpace` silently ignores the create-sheet's bring-in choice.

**Decisions locked with the user**:
- Space deletion = per-month resolution (move-back-to-profile or delete), then a **GitHub-style typed-name confirmation**; history is never silently destroyed.
- A brand-new space must NOT auto-provision its current month — provision shared months only once the space owns ≥1 month.
- The create-sheet **bring-in-past choice is wired now** (US5 T050–T052 are pulled forward into this iteration).
- Scope excludes deleting personal profiles (not in 011's FRs) — defer.

**Note**: This phase implements Phase 7 (US5) T050–T052 plus the new deletion/provisioning work below; complete T050–T052 in the same pass.

### Tests (MUST fail before implementation)

- [x] T060 [P] [US3] Write space-deletion + provisioning tests: a newly created space owns **no** month and a current-month move-in then succeeds; `deleteMonth` removes the month's `MonthlyBudget`+`Expense`+`Reimbursement(originYearMonth)`+`MedicalBill` and refuses a Viewer / non-member; per-month resolution (move-back and delete) empties a space so `deleteSpace` then succeeds; last-Owner guard still holds; typed-name confirm gates the delete button (FR-010/014, US3 AC4) in `test/features/spaces/space_deletion_test.dart`
- [x] T061 [P] [US5] Extend the progression tests (T050): bring-in-past (thisMonth/thisYear/everything) moves exactly the creator's eligible personal months into the space at creation and leaves other personal months untouched; a future month still appears automatically **after** the space has ≥1 month (FR-010/011, SC-004) in `test/features/spaces/space_progression_test.dart`

### Bring-in-past (US5, pulled forward)

- [x] T062 [US5] Wire the bring-in-past choice end-to-end: pass `draft.bringIn` from `SpaceSwitcher._createSpace` (`space_switcher.dart`) into `SpacesRepository.createSpace`, and inside the same create-space transaction move the **creator profile's** eligible personal months into the space — thisMonth (current YYYY-MM), thisYear (Jan..current YYYY), everything (all personal months) — reusing `MonthMoveOperations` rules (move never copy, block already-owned, income carry via `IncomeCarry`, sealed months unchanged) per FR-007/010; skip non-existent months (refines T051) in `lib/features/spaces/repositories/spaces_repository.dart`, `lib/features/spaces/presentation/space_switcher.dart`
- [x] T063 [US5] Refine auto-provisioning (T052): `selectedMonthProvisioningProvider` MUST NOT create a month in a space that owns no months; provision shared months only once the space has ≥1 budget row (personal-context provisioning unchanged, FR-011) in `lib/features/finance/providers/finance_providers.dart` (+ any gate needed in `month_finance_repository.dart`)

### Delete-month operation

- [x] T064 [P] [US3] Implement `deleteMonth(ContextRef context, String yearMonth, {required int actingProfileId})` as ONE writeTxn in `lib/features/spaces/repositories/month_move_operations.dart`: shared → `assertManage` (Owner-only), personal → acting profile must equal `context.profileId`; delete the `MonthlyBudget(context, ym)`, its `Expense(context, ym)`, `Reimbursement(context, originYearMonth == ym)`, `MedicalBill(context, ym)`; leave context-level directory rows (family members/providers) intact (contracts/month-move-lifecycle §3)

### Delete-space flow + typed-name confirm

- [x] T065 [US2] Build `DeleteSpaceSheet` in `lib/features/spaces/presentation/delete_space_sheet.dart`: list the space's months (from `monthlyBudgets.filter().sharedSpaceIdEqualTo(spaceId)`) with totals; per month choose **Move to** a personal profile (`moveMonth(space→personal)`) or **Delete** (`deleteMonth`); when the chosen profile already owns that month, surface the existing refusal and steer the Owner to Delete; end with the typed-name confirm
- [x] T066 [US2] Add the GitHub-style typed-name confirmation dialog (Delete enabled only when the input equals the space name) and wire `SpaceSettingsSection._delete` (`space_settings_section.dart`) to use it — empty space → confirm → `deleteSpace`; non-empty space → `DeleteSpaceSheet`
- [x] T067 [US3] Execute the deletion resolution: apply each month's disposition sequentially (`moveMonth` / `deleteMonth`), then call `deleteSpace` so members + space are removed atomically once no money remains; keep it resumable if interrupted (space stays deletable) and update the refusal SnackBar copy

### Role coverage + validation

- [x] T068 [US4] Extend the role matrix (T043) with the lifecycle paths: `deleteMonth`, the delete-space flow, and bring-in-past at creation are Owner-only and refused for Editor/Viewer/non-member at the data layer (FR-005/014, SC-005) in `test/features/spaces/role_guard_matrix_test.dart`
- [x] T069 Run the iteration gate: `dart format`, `flutter analyze`, `flutter test` all green; update `quickstart.md` delete/how-to-bring-a-month-in scenarios and verify by hand (FR-014/016)

**Checkpoint**: A new space starts empty, the current/past months can be brought in (at creation or by hand), and a space full of history can be resolved month-by-month and deleted with a typed-name confirmation.

---

## Phase 11: Profile deletion — delete a personal profile safely (follow-up iteration, 2026-10-11)

**Why**: User reported that a profile can be created but never deleted. The original 011 scope deliberately excluded profile deletion (see Phase 10 notes, line 228). This iteration adds it as an approved extension of US1.

**Goal**: A user can permanently delete a personal profile from Settings ▸ Profiles. Deleting a profile removes **all** of its personally-scoped money and directory rows plus its space memberships, in one atomic operation, leaving shared rows and other profiles untouched — and it refuses the two unsafe cases (last profile, sole space Owner).

**Decisions locked with the user (2026-10-11)**:
- **Hard delete only** — no reversible "archive" (no `archived` flag, no schema change).
- Show a **summary of what will be deleted** (row counts) in the confirmation.
- Reuse the **GitHub-style typed-name confirmation** (`TypedNameConfirmDialog` from T066).
- **Block** deleting the last profile, and **block** deleting a profile that is the **sole Owner** of any space (name the blocking space).
- If the **active profile** is deleted, **auto-switch** the active context to a surviving profile and clear the active space (fixes the stale-`activeProfileIdProvider` fallback edge).
- UI entry point: an **overflow ⋮ on each profile tile** in the switcher.
- Leave `SharedSpace.createdByProfileId` untouched (historical stamp; never read for logic).
- Update `spec.md` (new **FR-019**, an edge case, **SC-009**) and add a `quickstart.md` scenario.

**Schema**: none — all fields already exist; **no `build_runner` run needed**.

### Tests (MUST fail before implementation)

- [x] T070 [P] [US1] Write profile-deletion data-layer tests (real-Isar harness) in `test/features/settings/profile_deletion_test.dart`: deleting a profile removes **every** personal row (`MonthlyBudget`, `Expense`, `Reimbursement`, `SavingsVault`, `MedicalBill`, `InsuranceProfile`, `FamilyMember`, `MedicalProvider`, `MedicalServiceType`) and its `SharedMember` rows, while **shared rows and other profiles' rows remain**; refuses deleting the **last profile**; refuses a **sole Owner** and reports the blocking space name; the delete runs in one transaction (nothing partially removed on refusal) (FR-019, SC-009)
- [x] T071 [P] [US1] Write a widget test in `test/features/settings/profile_deletion_widget_test.dart`: the ⋮ delete affordance is hidden/disabled on the **last** profile tile; the typed-name confirmation gates the Delete button (enabled only when the typed name matches); a successful delete refreshes the switcher (FR-019)

### Implementation

- [x] T072 [US1] Implement `ProfileSwitcherController.deleteProfile(int profileId)` in `lib/features/settings/presentation/profile_switcher_section.dart` as ONE `writeTxn`: verify the profile exists; refuse when `userProfiles.count() <= 1` (last profile); for each `SharedMember(profileId == target, role == owner)` refuse when it is the space's only Owner (collect blocking space names); then delete the target's rows in `monthlyBudgets`, `expenses`, `reimbursements`, `savingsVaults`, `medicalBills`, `insuranceProfiles`, `familyMembers`, `medicalProviders`, `medicalServiceTypes`, `sharedMembers`; delete the `UserProfile` row; return the surviving profile id to fall back to and whether the deleted profile was the active one (FR-019)
- [x] T073 [US1] Wire the delete UI: add an overflow ⋮ to each `_ProfileTile` (hidden/disabled when it is the last profile) → "Delete profile" → counts-summary confirm (T074) → typed-name dialog (`TypedNameConfirmDialog`) → call `deleteProfile`; on success, if the deleted profile was active, set `activeProfileIdProvider` to the surviving id and set `activeSpaceIdProvider` to null, then show a confirmation SnackBar; on a sole-Owner refusal, show a SnackBar naming the blocking space(s) (FR-019, edge cases)
- [x] T074 [US1] Add the counts-summary + safety copy: in `lib/features/settings/presentation/profile_switcher_section.dart` gather per-collection row counts for the target profile and render them in the confirmation ("This deletes N expenses, M medical bills, K reimbursements, and a savings vault. This cannot be undone."); disable the tile's ⋮ for the last profile with a short explanation (FR-019)
- [x] T075 [US4] Extend the ownership matrix in `test/features/spaces/role_guard_matrix_test.dart`: profile deletion MUST NOT strip a space of its last Owner, and removes only the target's `SharedMember` rows while leaving the space and other members intact (FR-006/019, SC-005)

### Documentation + validation

- [x] T076 [US1] Update `spec.md` with **FR-019** (delete a personal profile: atomic cascade of its personal rows + memberships, leaving shared rows and other profiles intact; refused when it would leave zero profiles or a space with zero Owners; the active context moves to a surviving profile) plus a matching **Edge Cases** bullet and **SC-009** (deleting a profile leaves zero rows of that profile anywhere and never removes shared or other-profile rows — verified by tests)
- [x] T077 Run the iteration gate: `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` all green; add a delete-a-profile scenario to `quickstart.md`; verify by hand (create profile → add data → delete → confirm counts/typed-name → active context falls back) (FR-019)

**Checkpoint**: A personal profile can be deleted safely — its personal money and memberships vanish atomically, shared spaces and other profiles are untouched, the last profile and sole-Owner cases are refused with clear messages, and the active context falls back to a surviving profile.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — baseline verification only
- **Foundational (Phase 2)**: Depends on Setup; **BLOCKS all user stories** (schema, migration, context router, read-scoping, guard, harnesses)
- **US1 (Phase 3)**: Depends on Foundational only
- **US2 (Phase 4)**: Depends on Foundational only (uses guard T022 + context T013–T021); may proceed in parallel with US1
- **US3 (Phase 5)**: Depends on Foundational (T020 ensureMonth/T022 guard) + US2's space existence in practice (`SharedSpace` model is foundational; integrate after T033 for end-to-end)
- **US4 (Phase 6)**: Depends on Foundational (T022 guard) + US2 (membership); enforcement lands on the shared write paths built in US2/US3
- **US5 (Phase 7)**: Depends on US2 (space creation + bring-in-past) and Foundational (context-aware `ensureMonth`)
- **US6 (Phase 8)**: Depends on Foundational (context router); no dependency on other stories (context router drives it)
- **Polish (Phase 9)**: Depends on all desired stories being complete
- **Lifecycle completion (Phase 10)**: Depends on US2 (space + settings UI), US3 (`moveMonth`), and Phase 7 T052 (auto-provisioning); delivers US5 T050–T052 plus `deleteMonth` and the per-month space-deletion flow. Must run before Phase 9's final gate (T059)
- **Profile deletion (Phase 11)**: Follow-up iteration; depends on US1 (profile switcher), the last-Owner rules from US2/US4, and the reusable `TypedNameConfirmDialog` from Phase 10 (T066). Not part of the original 011 MVP; run after Phase 10. No schema change, so no `build_runner` step

### User Story Dependencies

- **US1 ↔ US2**: independent once foundational is done (parallelizable — different features/UI)
- **US3**: needs US2 to exist for a real end-to-end test, but its operation (`month_move_operations.dart`) is independently unit-testable after Foundational
- **US4**: tightly coupled to US2 (membership) and US3 (moved months) — sequence after both
- **US5**: after US2 (bring-in-past on create)
- **US6**: standalone (placeholder only)

### Within Each User Story

- Tests (included) MUST be written and FAIL before implementation
- Models before services; services before integration/wiring
- Story complete before moving to next priority

### Parallel Opportunities

- All Phase-1/Foundational `[P]` tasks can run in parallel where marked
- Once Foundational completes, **US1, US2 and US6** can start in parallel
- **US3** can start with US2 (its core is an independently testable operation)
- **US4** follows US2/US3; **US5** follows US2
- Every story's `[P]` test tasks run in parallel; `[P]` implementation tasks run in parallel within a story
- Different stories can be worked by different contributors (files disambiguated per task)

---

## Parallel Example: Foundational models + US2 repositories

```bash
# Foundation models in parallel (all different files):
Task: "Create SharedSpace model in lib/core/models/shared_space.dart"
Task: "Create SharedMember model in lib/core/models/shared_member.dart"
Task: "Add sharedSpaceId to Expense in lib/core/models/expense.dart"
Task: "Add sharedSpaceId to MedicalBill in lib/core/models/medical_bill.dart"

# US2 repo + sheets in parallel after T022/T023 (different files):
Task: "Implement SpacesRepository in lib/features/spaces/repositories/spaces_repository.dart"
Task: "Create CreateSpaceSheet in lib/features/spaces/presentation/create_space_sheet.dart"
Task: "Create SpaceSettingsSection + InviteSheet in lib/features/spaces/presentation/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002–T024) — CRITICAL, blocks everything
3. Run tests for US1 (T025–T026) — confirm they FAIL
4. Complete Phase 3: US1 (T027–T030)
5. **STOP and VALIDATE**: tests green, manual profile-switch check (US1 Independent Test, quickstart V1/V2)
6. Reset `activeProfileIdProvider` fallback path; ensure single-profile users are unaffected (default to lowest-id)

### Incremental Delivery

1. Foundational → US1 (**MVP**: multi-profile ready, prior single-profile behaviour unchanged)
2. + US2 → test → validate (spaces exist, invites, roles)
3. + US3 → test → validate (whole-month move, no drift)
4. + US4 → test → validate (data-layer role matrix green)
5. + US5 → test → validate (spaces keep going automatically)
6. + US6 → test → validate (placeholder in both contexts)
7. Polish + final gate + quickstart V1–V10

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T002–T024, parallel where `[P]`)
2. Once Foundational is done:
   - Developer A: US1 (profiles) — MVP
   - Developer B: US2 (spaces + invites)
   - Developer C: US6 (placeholder, independent)
3. Developer B → US3 (move) → US5 (progression) → US4 supervision as write paths land
4. Stories integrate via `budgetContextProvider` and `SpaceAccessGuard` only — single seams, no conflicts

---

## Notes

- **Git hands-off**: no commits/pushes by the agent — the user pushes (Phase-Builder rule).
- **[P] tasks** = different files, no dependencies; keep them truly parallel.
- **[Story] labels** map to spec.md user stories for traceability.
- Each story independently completable and testable; verify tests fail before implementing.
- `build_runner` must run after any model edit (T011 and after each story that touches `lib/core/models/`).
- Avoid: vague tasks, same-file conflicts, cross-story dependencies that break independence.
- The savings vault is personal-only (FR-017): no task in any story touches `SavingsVault` scoping or shared-spaces acceptance of vault data.