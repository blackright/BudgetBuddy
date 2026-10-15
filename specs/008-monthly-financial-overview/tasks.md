---

description: "Task list for Monthly Financial Overview & Medical Bills"
---

# Tasks: Monthly Financial Overview & Medical Bills

**Input**: Design documents from `/specs/008-monthly-financial-overview/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md, `.specify/memory/constitution.md` (v1.2.0)

**Tests**: Test tasks **are** included. `contracts/month-summary.md` (10 invariants, 10 worked examples), `contracts/medical-bill-lifecycle.md` §11 (16-case test matrix) and `quickstart.md` §3/§10 define them as acceptance oracles, and Constitution Principle II requires testability.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g. US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile (Flutter)**: `lib/` for source, `test/` for tests, `android/` for platform config
- Models in `lib/core/models/`, feature logic in `lib/features/<domain>/`, shared UI in `lib/shared/presentation/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Schema changes and migration scaffolding that every user story depends on.

- [X] T001 [P] Create `MedicalServiceType` collection with `profileId`, `name`, `isDefault`, `sortOrder`, `archived` and the six seed-name constants in `lib/core/models/medical_service_type.dart`
- [X] T002 [P] Add `double defaultNetSalary = 0.0` to `UserProfile` in `lib/core/models/user_profile.dart`
- [X] T003 [P] Add `bool openingBalanceConfirmed = false` and `double? netSalaryOverride` to `MonthlyBudget` in `lib/core/models/monthly_budget.dart`, documenting `baseAvailableAmount` as the month's opening balance
- [X] T004 [P] Add `@Index() late String originYearMonth` and change `late int expenseId` to `int? expenseId` in `lib/features/expenses/models/reimbursement.dart`
- [X] T005 Register `MedicalServiceTypeSchema` in the `Isar.open` collection list in `lib/core/database/isar_helper.dart`
- [X] T006 Create `lib/core/database/schema_migrations.dart` with a version-stamp constant, a key/value stamp accessor, and an idempotent `runSchemaMigrations(Isar isar)` entry point that executes its numbered steps in one transaction
- [X] T007 Regenerate Isar code with `dart run build_runner build --delete-conflicting-outputs`
- [X] T008 Verify the schema-only baseline: run `flutter analyze` and `flutter test` and confirm both are green before behavioural changes begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Month-scoped infrastructure that MUST be complete before ANY user story can be implemented.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T009 [P] Create `selectedYearMonthProvider` as a `StateProvider<String>` defaulting to the current month, plus pure helpers `shiftMonth(String yearMonth, int delta)`, `previousMonth()`, `nextMonth()` and `goToToday()` in `lib/core/providers/selected_month_provider.dart`
- [X] T010 [P] Create `MonthFinanceRepository` in `lib/features/finance/repositories/month_finance_repository.dart` with `ensureMonth`, `watchMonth`, `getMonth`, `saveOpeningBalance`, `saveNetSalaryOverride`, `getDefaultNetSalary` and `saveDefaultNetSalary`, provisioning new months with the active profile's currency and `openingBalanceConfirmed = false`
- [X] T011 [P] Create `finance_providers.dart` in `lib/features/finance/providers/` exposing `monthFinanceProvider`, `resolvedIncomeProvider`, `monthCompletenessProvider`, and a `selectedYearMonthProvider` listener that calls `ensureMonth` on every navigation
- [X] T012 [P] Create `MonthSummary` as a pure value object with no Isar or Riverpod imports in `lib/features/engine/month_summary.dart`, exposing `income`, `paymentsMade`, `moneyReturned`, `planned`, `cancelled`, `medicalPaid`, `openingBalance`, `kept`, `moneyInBank`, `excessReturned`, `usesOverriddenIncome` and `isComplete` per `contracts/month-summary.md` §3
- [X] T013 [P] Define the FR-019 semantic colour tokens (moneyIn green, moneyOut red, planned orange, bank neutral) in `lib/features/medical/presentation/medical_theme.dart`
- [X] T014 Rewire `lib/core/providers/active_budget_provider.dart` to watch `selectedYearMonthProvider` instead of the hardcoded `currentYearMonthProvider`
- [X] T015 Rewire the `currentYearMonthProvider` reference at line 20 of `lib/features/engine/providers/sweep_provider.dart` to `selectedYearMonthProvider`
- [X] T016 Create `monthSummaryProvider` in `lib/features/engine/providers/month_summary_provider.dart`, assembling `MonthSummary` for the selected month from the expense, reimbursement and finance streams
- [X] T017 Add migration step 6 to `lib/core/database/schema_migrations.dart`: mark every pre-existing `MonthlyBudget` row `openingBalanceConfirmed = true`, since its `baseAvailableAmount` was a user-entered figure (FR-010)
- [X] T018 Extend `test/features/medical/repositories/medical_test_harness.dart` to register `MedicalServiceTypeSchema` and to expose a harness that can open a database at the pre-migration schema for migration tests
- [X] T019 Verify the foundation: run `flutter analyze` and `flutter test`, confirm green, and confirm `runSchemaMigrations` is idempotent when executed twice

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 1 - See what I kept this month (Priority: P1) — MVP

**Goal**: Record a net salary with per-month overrides, derive "kept this month" as income − payments + returned, and present it as the single largest figure on a rebuilt dashboard.

**Independent Test**: Enter a net salary and expenses of different statuses, open the dashboard, confirm "kept this month" equals income minus paid plus returned, and confirm it does not change when a planned expense is added, deleted or marked paid.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T020 [P] [US1] Create `test/features/engine/month_summary_test.dart` asserting invariants I1–I10 and worked examples E1, E2, E3, E7 and E10 from `contracts/month-summary.md`
- [X] T021 [P] [US1] Create `test/features/finance/month_finance_repository_test.dart` covering month provisioning, income resolution and month isolation
- [X] T022 [P] [US1] Create `test/features/dashboard/dashboard_summary_test.dart` asserting hero hierarchy (SC-002), colour roles (FR-019), the collapsed detail group (FR-021) and absence of prohibited content (FR-023)

### Implementation for User Story 1

- [X] T023 [US1] Implement `resolveIncome(String yearMonth)` in `lib/features/finance/repositories/month_finance_repository.dart` returning `netSalaryOverride ?? profile.defaultNetSalary` plus `usesOverriddenIncome` (FR-002, FR-003, FR-005)
- [X] T024 [US1] Add the FR-004 case to `test/features/finance/month_finance_repository_test.dart`: changing `defaultNetSalary` must not rewrite months that already exist
- [X] T025 [P] [US1] Create `lib/features/finance/presentation/net_salary_section.dart` with a default-salary editor and a per-month override control that marks overridden months (FR-005)
- [X] T026 [US1] Embed `NetSalarySection` into `lib/features/settings/presentation/settings_screen.dart`
- [X] T027 [P] [US1] Create `lib/features/dashboard/presentation/widgets/month_summary_card.dart` rendering the hero kept figure, the supporting income/payments line, and the four labelled lines (FR-018)
- [X] T028 [P] [US1] Create `lib/features/dashboard/presentation/widgets/month_summary_details.dart` holding the collapsed group: bank line, medical portion, cancelled total, override marker and excess returned (FR-021)
- [X] T029 [P] [US1] Create `lib/shared/presentation/widgets/month_incomplete_banner.dart` marking a month incomplete when income or opening balance is missing (FR-025)
- [X] T030 [US1] Rebuild `lib/features/dashboard/presentation/dashboard_screen.dart` to render the summary card and details group, removing Safe to Spend and True Available from the default view while keeping their providers intact (FR-023, plan Technical Context)
- [X] T031 [US1] Route the medical portion line from `lib/features/dashboard/presentation/widgets/month_summary_details.dart` to the `/medical` route in `lib/core/routing/app_router.dart`, preserving the selected month (FR-022, FR-027)
- [X] T032 [US1] Run the US1 acceptance scenarios E1, E2 and E3 in `quickstart.md` §4.2 and record the results

**Checkpoint**: User Story 1 fully functional and independently testable — this is the MVP

---

## Phase 4: User Story 2 - Medical bills that reflect what I actually paid (Priority: P2)

**Goal**: Replace the full-charge medical model with two payment methods so insurer-paid bills reduce available funds by only the patient's share, remove deductibles entirely, and add user-editable service types.

**Independent Test**: Enter one insurer-paid bill and one self-paid bill, confirm the insurer-paid bill reduces available funds by only the user's share while the self-paid bill reduces it by the full charge until a reimbursement is recorded.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T033 [P] [US2] Create `test/features/medical/repositories/medical_repository_migration_test.dart` covering migration steps 0–5 against a pre-migration schema (FR-036, FR-037, FR-048, FR-052, FR-055)
- [X] T034 [P] [US2] Extend `test/features/medical/repositories/medical_repository_test.dart` with cases 1–8 and 12–16 from `contracts/medical-bill-lifecycle.md` §11, including SC-006 (insurer-paid never reduces funds by the full charge)
- [X] T035 [P] [US2] Update `test/features/medical/providers/medical_providers_test.dart` to replace deductible assertions with patient-share and monthly-total assertions

### Implementation for User Story 2

- [X] T036 [P] [US2] Rewrite `MedicalBill` in `lib/core/models/medical_bill.dart`: add `paymentMethod`, `patientSharePercent`, `serviceTypeId`, indexed `yearMonth`, `billPhotoPath` and `insurerReplyPath`; replace `insuranceCoveragePercent` with `patientSharePercent`, `claimStatus` with the five-state `MedicalBillState` enum, and `attachmentPaths` with the two photo fields
- [X] T037 [P] [US2] Remove `individualDeductible`, `familyDeductible` and the indexed `year` from `InsuranceProfile` in `lib/core/models/insurance_profile.dart`, and rename `defaultCoveragePercent` to `defaultPatientPercent`
- [X] T038 [US2] Regenerate Isar code with `dart run build_runner build --delete-conflicting-outputs` and remove every deductible reference from `lib/core/models/`
- [X] T039 [US2] Add migration step 0 to `lib/core/database/schema_migrations.dart`: seed the six service types for the active profile when none exist (FR-039)
- [X] T040 [US2] Add migration step 1 to `lib/core/database/schema_migrations.dart`: clear `individualDeductible` and `familyDeductible` on every `InsuranceProfile` row (FR-037)
- [X] T041 [US2] Add migration step 2 to `lib/core/database/schema_migrations.dart`: set `patientSharePercent = 100 − insuranceCoveragePercent` on every bill and `defaultPatientPercent = 100 − defaultCoveragePercent` (FR-048)
- [X] T042 [US2] Add migration step 3 to `lib/core/database/schema_migrations.dart`: map legacy claim states — `unclaimed`/`processing` → `waiting`, `reimbursed` → `finished`, `denied` → `rejected` (FR-052)
- [X] T043 [US2] Add migration step 5 to `lib/core/database/schema_migrations.dart`: backfill `MedicalBill.yearMonth` from `serviceDate`, falling back to the linked expense's `yearMonth` (FR-055)
- [X] T044 [US2] Rewrite `_syncLinkedExpense` in `lib/features/medical/repositories/medical_repository.dart` so `Expense.amount` is a function of payment method, patient share and bill state per the money impact table in `contracts/medical-bill-lifecycle.md` §4 (FR-042, FR-045, FR-050, FR-051)
- [X] T045 [US2] Implement state transitions in `lib/features/medical/repositories/medical_repository.dart` per §5 of the lifecycle contract, including deleting any reimbursement when a bill enters or leaves `rejected` (FR-054)
- [X] T046 [US2] Make the bill's owning month the service month with a user override in `lib/features/medical/repositories/medical_repository.dart`, mirroring `yearMonth` onto the linked `Expense` in the same transaction (FR-055, O1, O2)
- [X] T047 [US2] Enforce document validation in `lib/features/medical/repositories/medical_repository.dart`: neither photo required for insurer-paid bills, and `insurerReplyPath` rejected for insurer-paid bills (FR-044, FR-047, D1, D2)
- [X] T048 [P] [US2] Add service type CRUD and case-insensitive name de-duplication to `lib/features/medical/repositories/medical_repository.dart`, archiving rather than deleting (FR-040)
- [X] T049 [US2] Remove `DeductibleProgress` and all deductible aggregation from `lib/features/medical/providers/medical_providers.dart`, replacing them with patient-share totals scoped to the selected month (FR-036, FR-038)
- [X] T050 [US2] Add payment method, service type picker, patient-percentage and split photo inputs to `lib/features/medical/presentation/medical_bill_form.dart` (FR-041, FR-047, FR-048)
- [X] T051 [US2] Rewrite the lifecycle controls, rejection handling and reimbursement entry in `lib/features/medical/presentation/medical_detail_screen.dart`, blocking `finished` on insurer-paid bills (FR-044, FR-049, T2)
- [X] T052 [US2] Remove all deductible UI, add the five state labels and month scoping in `lib/features/medical/presentation/medical_dashboard.dart` (SC-007)
- [X] T053 [US2] Add service type add / rename / archive controls in `lib/features/medical/presentation/medical_dashboard.dart` (FR-040)
- [X] T054 [US2] Verify migration steps 0–5 against a pre-migration database using `quickstart.md` §7, and confirm idempotency and single-transaction atomicity
- [X] T055 [US2] Run the US2 acceptance scenarios in `quickstart.md` §6.1–§6.3 and record the results

**Checkpoint**: User Stories 1 AND 2 both work independently

---

## Phase 5: User Story 3 - Money that comes back is never lost (Priority: P3)

**Goal**: Credit every reimbursement to the month of the expense or bill it belongs to, regardless of when the user records it, replacing rather than stacking on re-entry.

**Independent Test**: Record an expense in one month, record its reimbursement three months later, and confirm the money is credited to the original month and that the month totals still reconcile.

### Tests for User Story 3

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T056 [P] [US3] Create `test/features/engine/reimbursement_attribution_test.dart` looping entry offsets of 1, 3, 6 and 12 months and asserting the origin month's `moneyReturned` in every case (SC-005), plus replacement (FR-034) and orphan retention (FR-035)

### Implementation for User Story 3

- [X] T057 [US3] Add migration step 4 to `lib/core/database/schema_migrations.dart`: backfill `Reimbursement.originYearMonth` from the target expense's `yearMonth`, falling back to the reimbursement's own month when the expense is missing (FR-032)
- [X] T058 [US3] Add an origin-month indexed query in `lib/features/expenses/repositories/expense_repository.dart` and stop deriving the reimbursement set from the viewed month's expense ids in `lib/features/engine/providers/true_available_provider.dart` (FR-033)
- [X] T059 [US3] Guarantee at most one reimbursement row per target for non-medical expenses in `lib/features/expenses/repositories/expense_repository.dart`, replacing the amount on re-entry (FR-034)
- [X] T060 [US3] Retain reimbursements whose target expense is deleted, flag them as orphaned and expose them for the user to resolve in `lib/features/expenses/repositories/expense_repository.dart` (FR-035)
- [X] T061 [US3] Read `moneyReturned` and `excessReturned` by `originYearMonth` in `lib/features/engine/month_summary.dart` and `lib/features/engine/providers/month_summary_provider.dart` (FR-032, R14)
- [X] T062 [P] [US3] Surface the orphaned-reimbursement warning with remove-or-restore choices in `lib/features/expenses/presentation/expenses_screen.dart` (FR-035)
- [X] T063 [US3] Run the US3 acceptance scenarios and the 1/3/6/12-month offset checks in `quickstart.md` §4.2 and record the results

**Checkpoint**: User Stories 1, 2 AND 3 all work independently

---

## Phase 6: User Story 4 - Any month, past or future (Priority: P4)

**Goal**: Let the user move between months, audit and edit past ones, plan in future ones, and keep the selection consistent across every section.

**Independent Test**: Navigate to a previous month, confirm its figures are shown, edit an expense in it and confirm the change is reflected, then navigate to a future month and confirm a planned expense can be entered.

### Tests for User Story 4

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T064 [P] [US4] Extend `test/features/finance/month_finance_repository_test.dart` with navigation cases: past months fully editable, future months provisioned with their own income and opening balance, and no figure carried forward (FR-028, FR-029, FR-030, SC-012)

### Implementation for User Story 4

- [x] T065 [P] [US4] Create `lib/features/dashboard/presentation/month_navigator.dart` with previous, next, month label and Today controls (FR-026)
- [x] T066 [US4] Wire `MonthNavigator` into the app bar of `lib/features/dashboard/presentation/dashboard_screen.dart` and confirm each move reaches its target in two interactions or fewer (SC-008)
- [x] T067 [US4] Provision the target month through `ensureMonth` on every navigation in `lib/features/finance/providers/finance_providers.dart`, showing no error state when a month has no record (R16, N6)
- [x] T068 [US4] Confirm in `lib/features/dashboard/presentation/dashboard_screen.dart` that past months render no read-only state and accept edits (FR-028, N3)
- [x] T069 [US4] Confirm in `test/features/finance/month_finance_repository_test.dart` that planned entries in a future month leave the current month's figures untouched (FR-030, N5)
- [x] T070 [US4] Confirm the selected month persists across Dashboard, Expenses, Medical and Analytics tabs in `test/features/medical/presentation/medical_navigation_test.dart` (FR-027, N2)

**Checkpoint**: User Stories 1–4 all work independently



---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Verification that the five stories hold together under Constitution v1.2.0.

- [x] T077 [P] Audit month isolation in `test/features/engine/month_summary_test.dart`: mutating one month's rows must not change any other month's summary (FR-016, SC-012)
- [x] T078 [P] Sweep every screen rendering a figure and replace screen-local colour literals with the `medical_theme.dart` tokens (FR-020, C1)
- [x] T079 [P] Sweep `lib/` for any surviving deductible value, field or progress indicator, starting from `lib/core/models/insurance_profile.dart` and `lib/features/medical/` (SC-007)
- [x] T080 Assert in `test/features/dashboard/dashboard_summary_test.dart` that the dashboard medical figure and the Medical tab figure are identical for the same month (FR-024, SC-009)
- [x] T081 [P] Verify in `test/features/dashboard/dashboard_summary_test.dart` that the hero figure is visible without interaction and is the largest element (SC-001, SC-002)
- [x] T082 Confirm Safe to Spend is still correct on the add, edit and detail expense screens in `lib/features/expenses/presentation/` (plan regression scope)
- [x] T083 Confirm the Analytics screen in `lib/features/analytics/presentation/analytics_screen.dart` still renders after the engine rewiring
- [x] T084 Confirm onboarding still creates the first month correctly in `lib/features/budget_setup/providers/budget_setup_provider.dart`
- [x] T085 Confirm per-expense multi-currency conversion via `exchangeRateToPrimary` is unchanged in `lib/features/engine/providers/true_available_provider.dart`
- [x] T086 Run full validation per `quickstart.md` §10: `flutter analyze`, `flutter test`, `flutter build apk --debug`, and every acceptance-scenario walkthrough, then mark this file's completed tasks

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Stories (Phases 3–7)**: All depend on Foundational completion
  - US1, US2, US3 and US4 can proceed in parallel once Foundational is done
  - US5 depends on US1 (income must resolve before a bank figure is meaningful)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Foundational — no dependencies on other stories. **MVP.**
- **User Story 2 (P2)**: Starts after Foundational — no dependencies. Runs its own migration steps 0–3 and 5.
- **User Story 3 (P3)**: Starts after Foundational — no dependencies. Migration step 4 is independent of US2's steps.
- **User Story 4 (P4)**: Starts after Foundational — no dependencies; the shared month state already exists.

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Models before services, services before UI
- Migration steps before the repository code that depends on migrated fields
- Core implementation before integration

### Critical Ordering Constraints

- T001 → T005 → T007 (model, then registration, then codegen)
- T009 → T014, T015 → T016 (month state, then rewiring, then the summary provider)
- T036, T037 → T038 → T039–T043, T044 (models, then codegen, then migration and repository)
- T004 → T057, T058 (reimbursement schema before origin-month backfill)

### Parallel Opportunities

- T001–T004 (four distinct model files) run in parallel
- T009–T013 (six distinct new files) run in parallel
- All `[P]` tasks within a story touch different files and run in parallel
- US1, US2, US3 and US4 can be worked in parallel by different developers once Foundational completes

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Create test/features/engine/month_summary_test.dart asserting invariants I1–I10"
Task: "Create test/features/finance/month_finance_repository_test.dart"
Task: "Create test/features/dashboard/dashboard_summary_test.dart"

# Launch all UI widgets for User Story 1 together:
Task: "Create lib/features/dashboard/presentation/widgets/month_summary_card.dart"
Task: "Create lib/features/dashboard/presentation/widgets/month_summary_details.dart"
Task: "Create lib/shared/presentation/widgets/month_incomplete_banner.dart"
Task: "Create lib/features/finance/presentation/net_salary_section.dart"
```

## Parallel Example: User Story 2

```bash
# Launch all tests for User Story 2 together:
Task: "Create test/features/medical/repositories/medical_repository_migration_test.dart"
Task: "Extend test/features/medical/repositories/medical_repository_test.dart"
Task: "Update test/features/medical/providers/medical_providers_test.dart"

# Launch both model rewrites together:
Task: "Rewrite MedicalBill in lib/core/models/medical_bill.dart"
Task: "Remove deductibles from InsuranceProfile in lib/core/models/insurance_profile.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T008)
2. Complete Phase 2: Foundational (T009–T019) — CRITICAL, blocks all stories
3. Complete Phase 3: User Story 1 (T020–T032)
4. **STOP and VALIDATE**: confirm US1 acceptance scenarios E1–E3 from `quickstart.md` §4.2
5. Build and demo

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. US1 → validate → **MVP: the user can finally see what they kept**
3. US2 → validate → medical totals stop overstating by ~4×, and the active data-loss defect in medical figures is fixed
4. US3 → validate → reimbursements can no longer disappear; SC-005 satisfied
5. US4 → validate → past months become auditable and future months plannable
6. US5 → validate → the live affordability check

Each story ships value on its own and none depends on a later story.

### Parallel Team Strategy

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (then US5, which depends on it)
   - Developer B: User Story 2
   - Developer C: User Stories 3 and 4
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps each task to a user story for traceability
- Each user story is independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate a story independently
- Constitution v1.2.0's amended Principle IV governs US2 — the money impact table in `contracts/medical-bill-lifecycle.md` §4 is binding, not advisory
- Migration steps are split across US2 (steps 0–3, 5) and US3 (step 4); all six execute in one transaction via `runSchemaMigrations`
- Avoid: vague tasks, same-file conflicts, cross-story dependencies that break independence
