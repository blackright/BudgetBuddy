# Phase 0 Research: Multi-User Profiles & Shared Financial Spaces (Unified)

**Feature**: 011-shared-financial-spaces | **Date**: 2026-10-09
**Status**: All unknowns resolved. No NEEDS CLARIFICATION remain.

Source-of-truth codebase facts verified by exploration on 2026-10-09 (file:line cited below).

---

## R1. Month ownership: the single hardest gap

**Decision**: Turn `MonthlyBudget` into a context-owned record — add `profileId int?` and `sharedSpaceId int?` (+ unique-per-context composite indexes) — and add `sharedSpaceId int?` to `Expense`, `Reimbursement` and `MedicalBill` (which already carry `profileId`). Every covered record satisfies **exactly one context**: personal ⇔ `profileId != null`; shared ⇔ `sharedSpaceId != null`; both/neither is a data-layer violation (FR-003/SC-005). No table keys a month by `yearMonth` alone anymore.

**Rationale**: `MonthlyBudget` has **no owner column today** and its `yearMonth` is unindexed, un-unique (`lib/core/models/monthly_budget.dart:5-38`) — `activeBudgetProvider` filters `yearMonthEqualTo(yearMonth)` only (`lib/core/providers/active_budget_provider.dart:13-21`), which is why one month is effectively global. The 011 spec mandates "a month lives in exactly one space" (Move, not copy) and SC-003 "assigns every existing month to the active personal profile". The prior user decision (2026-10-09) was **Option A: additive owner-scoping** — nullable context columns over an existing table, rather than a new unified scope-key refactor (Option B). Expense/Reimbursement/MedicalBill already carry profileId with indexes, so the change is purely additive there.

**Alternatives considered**: Option B — unified `contextKey` refactor across every table: rejected (highest blast radius; touches every query and test in the app; no migration advantage). A separate `Month` table owning children: rejected (children already denormalize `yearMonth`/`budgetId`; a new table would still need `budgetId` rewiring identical to the chosen approach). Keeping `MonthlyBudget` global and namespacing only in providers: rejected (two profiles would share one October budget — violates FR-001/FR-007).

---

## R2. Multi-profile promotion: kill the "profiles.first" assumption

**Decision**: `activeProfileProvider` changes from `profiles.isNotEmpty ? profiles.first : null` (`lib/core/providers/active_profile_provider.dart:7-13`) to watch a **selected profile id** (`activeProfileIdProvider`, a `StateProvider<int?>`, persisted marker) and return the matching row; fallback to lowest-id (today's first) until the user picks. New-profile creation in `budget_setup_provider` drops the "pin id = 1" exclusivity (`budget_setup_provider.dart:101-104` — first profile keeps id 1 for backwards compatibility; subsequent profiles take auto-increment ids). Existing single-row writers (`month_finance_repository.dart:152,165`, `settings_provider.dart:51,73`, `font_setting_section.dart:47-55`) are re-pointed at the active profile's id instead of `.findFirst()`.

**Rationale**: 41 references read `activeProfileProvider`; the smallest correct seam is to change what it returns, not to rewrite every consumer. Spec FR-001 requires per-profile data + per-profile theme/font/currency; theme/font already read the profile, so they become per-profile for free once the active profile is real. The `findFirst()` write paths are genuine single-profile bugs that would write Profile B's salary into Profile A — they must be scoped.

**Alternatives considered**: A tabs-per-profile shell (each tab a provider container): rejected (duplicates the whole provider graph, theme/money engines included). Storing the selected profile inside `UserProfile` itself: rejected (turns a preferences row into mutable global state).

---

## R3. Medical directory inside a shared space

**Decision**: The four directory collections — `InsuranceProfile`, `FamilyMember`, `MedicalProvider`, `MedicalServiceType` (`lib/core/models/insurance_profile.dart`, `medical_service_type.dart`) — become **space-owned exactly like bills**: each gains nullable `sharedSpaceId`, with the same exactly-one-context invariant as money rows. A shared space has its own insurance profile, family members, providers and service types; bills inside the space reference that directory. `_syncLinkedExpense` (`medical_repository.dart:870-935`, sets `expense.profileId`) becomes context-aware so medical-created expenses land in the space.

**Rationale**: The spec did not list the directory in FR-003's covered records, but medical bills ("must follow the established insurance lifecycle", FR-013) depend on it: `MedicalBill.familyMemberId/providerId/serviceTypeId` are plain-id references into the directory (`medical_bill.dart:27-38`). If the directory stayed personal, a shared bill would reference a member of the entering profile's private directory — invisible/mis-scoped for other room members, and the deletion flow ("remove entire unused directory" per profile) would fight the data. Keeping the directory context-scoped preserves the existing queries (the added column is additive) and matches the spec's own principle "rows belong to the space, not the member".

**Alternatives considered**: Bills carry denormalized directory snapshots (name text, insurer text): rejected (duplicates the five-state lifecycle state and plan details; breaks round-trip editing). A "bring your own directory" aggregate per space created lazily from the creator's: equivalent to space-owned rows with a seeding step — documented as the create-space seed behavior in data-model §6.

---

## R4. Income pots and carrying a figure across a move

**Decision**: Two pots, resolved independently (FR-009, SC-007):
- **"My income" (personal)**: unchanged storage — `UserProfile.defaultNetSalary` + `MonthlyBudget.netSalaryOverride` (both legacy `double` major units, untouched), same `ResolvedIncome.resolve` (`month_finance_repository.dart:25-33`).
- **"Our income" (shared)**: new — `SharedSpace.defaultIncome int` (whole minor units) + `MonthlyBudget.sharedIncomeOverride int?` (new column, minor units). Resolution mirrors `ResolvedIncome` on integers.

**Carry-on-move rule (FR-008)**: moving a month carries its resolved income figure into the target pot's **per-month override**. Personal→shared: `sharedIncomeOverride = roundMinorUnits(resolvedPersonalIncome, targetPotCurrency)` where the round uses the month's seal/live table *once at the boundary* (sealed month → its own seal; open month → live table), round half-away-from-zero. Shared→personal: `netSalaryOverride` takes the shared resolved figure converted back **to the personal main currency** the same one-cut way. If source == target currency, the override is carried verbatim (byte-identical). This is the *only* intentional write alongside the context re-pointing during a move, and it is what makes "the figure reports under the space's income from then on" work while "pre-move totals identical" (SC-006) holds for same-currency moves.

**Rationale**: The personal covariates cannot be integerized without touching the legacy migration surface (010 deliberately kept `double` income in R6-style re-labelling); the spec assumption says personal income columns stay as-is. New shared fields must be minor units per the same assumption. One-cut conversion at a boundary is exactly the house rule from 010 research R5.

**Alternatives considered**: Leave the shared override in `double` for symmetry: rejected (new fields must be whole minor units). Refuse cross-currency moves: rejected (a space can honestly have a different currency from a member's profile; spec sanctions any move, and its sealed-history/all-currency-view promises handle display). Duplicate pots in both units: rejected (two sources of truth).

---

## R5. Move atomicity and child re-parenting

**Decision**: Moves, space deletion, membership changes and ownership transfer are **one `writeTxn` each**, implemented in `lib/features/spaces/repositories/`. `moveMonth({from, to, yearMonth, targetProfileId?})`:
1. Rejects when the target context already owns a `MonthlyBudget` for that yearMonth (blocked with message, FR-010/SC-006).
2. Same `writeTxn`: updates `MonthlyBudget` context columns; swaps context columns on every `Expense`, `Reimbursement`, `MedicalBill` of that month (Expense by `profileId/sharedSpaceId + yearMonth`; Reimbursement by `originYearMonth`; MedicalBill by `profileId/sharedSpaceId + yearMonth`); updates R4's income override carry; re-points referenced **directory rows** (move the referenced `FamilyMember/Provider/ServiceType/InsuranceProfile` rows into the target context, or recycle if a row with the same name+detail already exists there — the move never duplicates on re-entry); updates linked `Expense.budgetId` to the target budget row.
3. Deletion of a space (FR-014): outside any txn, prompt Owner per month — "move back to a personal profile (choose which)" or "delete" — then **one atomic removal** of whatever rows remain (space's budgets, expenses, reimbursements, bills, directory rows, `SharedSpace`, `SharedMember` rows). Member profiles untouched.

**Rationale**: The single monthly seal is keyed strictly to `yearMonth` device-global, so a move does not change any sealed rate (FR-012 / spec edge "moving a sealed past month: allowed"). Reimbursement "credit" is `originYearMonth`-scoped (`true_available_provider.dart:29-36`, `month_summary_provider.dart:18-24`, `reimbursement_repository.dart:51-63`) — this is the hinge the exploration flagged: moving a month must move its reimbursements' **origin** month rows, or the money returns to the wrong room. The one-transaction rule keeps the "single copy, no drift" promise from ever being observable as a torn move.

**Alternatives considered**: Copy-then-delete two-phase move: rejected (a crash between phases would leave a duplicate — the spec forbids copies). Soft-delete tombstone (`isDeleted`) rows: rejected (extra lifecycle state, more migration surface, no user value).

---

## R6. Seals & rates stay device-global under multi-context

**Decision**: `MonthRateSeal`, `LiveRateSet`, and the `RateTableRegistry` (`lib/features/engine/providers/rate_registry_provider.dart:16-95`) remain **device-global, keyed by `yearMonth` only**. The seal coordinator's month-discovery must change: `_eligibleMonths` reads `isar.monthlyBudgets.where().findAll()` (`seal_coordinator.dart:177`) — with per-context budgets this still works (it needs every calendar month that has any budget), but it must use **distinct `yearMonth`** across contexts so profile A's October and space S's October don't double-consider. The rest of the coordinator (`:147,203,221`) touches only seals/rates and is untouched.

**Rationale**: A shared space "never captures its own separate rate splits" (spec assumption). Currency is user-visible but not user-private money, mirroring exactly the 010 decision (R5 there). Sealed past months are immutable "for every role" (FR-012) — that guarantee is per-month and context-independent, and the existing seal tests (`month_seal_lifecycle_test`) already pin it.

**Alternatives considered**: Per-context seals: rejected (a space forking rates from the device would split the "the past never changes" promise into per-room histories; exactly what the spec says it must not do). Per-profile rate caches: same rejection, plus duplicates storage.

---

## R7. Role enforcement must live at the data layer

**Decision**: A `SpaceAccessGuard` (pure Dart class, unit-testable) sits on every shared-space **write** path in the space/finance/medical repositories. It answers `canView(c, role)`, `canEdit(c)` (Editor+), `canManage(c)` (Owner-only) against the member row fetched inside the same read, and throws `UnauthorizedSpaceAction` for: any action by a non-member; an Owner-only action by an Editor/Viewer; any sealed-month write for any role (FR-012/SC-005). Viewer write controls stay hidden in the UI **and** every repository write re-checks the guard — never trust the UI (FR-005, spec US4). Transfer, invite, leave, rename, role-change and delete are guarded Owner-only (FR-002/014), with the last-owner invariant proved by tests (FR-006).

**Rationale**: The exploration confirmed all current writes flow through repositories (expense/medical/reimbursement/month-finance) and all reads through providers — so one guard wired into the repository write methods is a single enforcement point. The spec's own US4 warning ("not only by hiding buttons") plus SC-005 ("enforced and tested at the data layer") make the data-layer gate non-negotiable.

**Alternatives considered**: Guarding only in widgets: rejected (spec explicit). Ambient-authority checks scattered per repository manually: same thing, but drift-prone; a dedicated guard keeps the matrix testable in one file. A Riverpod-role provider consulted at call sites: helpful for UI, useless as a security boundary (providers can be overridden) — used for UI state, not the enforcement gate.

---

## R8. Context-scoping cascade (provider inventory)

**Decision**: Introduce `budgetContextProvider` = derived `(isShared, profileId?, spaceId?)` from `selectedProfileIdProvider` + `activeSpaceIdProvider` + `selectedYearMonthProvider`. Re-point every context-scoped read through it. Verified inventory of reads that must become context-aware (from exploration):

| Current read | File:line | Change |
|---|---|---|
| `activeBudgetProvider` (yearMonth-only) → becomes per-context budget | `lib/core/providers/active_budget_provider.dart:13-21` | filter by context composite |
| `monthlyExpensesProvider` (profile.id + budget.source) | `lib/features/engine/providers/true_available_provider.dart:13-19` | filter by context (profile **or** sharedSpaceId) |
| `monthlyReimbursementsProvider` (yearMonth-only!) | `true_available_provider.dart:29-36` | filter by context |
| `monthlyOriginReimbursementsProvider` (yearMonth-only!) | `month_summary_provider.dart:18-24` | filter by context |
| `trueAvailableProvider` / `safeToSpendProvider` / `dailyLimitProvider` | `true_available_provider.dart:40-66`, `safe_to_spend_provider.dart:10-28`, `daily_limit_provider.dart` | read context budget + context streams |
| `monthSummaryProvider` | `month_summary_provider.dart:32-70` | context income + context streams |
| `ExpensesNotifier._loadExpenses` (budgetId-only) | `expenses_provider.dart:65-69` | context |
| Medical: `medicalBillsProvider`, `medicalDisplayCurrencyProvider`, `medicalBudgetImpactProvider`, `patientShareTotalsProvider`, `medicalBillContextProvider`, directory providers | `medical_providers.dart:41-48, 50-66, 93-127, 133-140, 155-183` | context profile/space scoping |
| Reimbursement/orphaned reads (yearMonth/expenseId/`orphaned`-only) | `expense_repository.dart:121-194`, `reimbursement_repository.dart:33-63` | context scoping |
| `mainCurrencyProvider` (reads profile) | `settings_provider.dart:15-18` | resolve **space currency** when a space is active |
| `MonthFinanceRepository` `ensureMonth/getMonth/saveSaveOpeningBalance/saveConvertTo/saveNetSalaryOverride` | `month_finance_repository.dart:54-184` | context-aware |
| `seal_coordinator._eligibleMonths` | `seal_coordinator.dart:177` | distinct `yearMonth` across contexts (R6) |

**Rationale**: The exploration proved there is no single route today — the de-facto "who am I / which month" is three independent primitives. The spec FR-004 explicitly demands ONE route and "no query can stumble into another context's data"; SC-002 adds the 1-second/frame budget. A single synchronous derived provider + already-watched streams satisfies both: switching the selected space id (one `StateProvider` write) re-derives every dependent stream in the same frame. Transactions that delete rows (expense delete → reimbursement orphan-flag, `expense_repository.dart:34-46`) are unchanged — they stay context-local because the guard already verified the writer's role.

**Alternatives considered**: One provider per feature thread (dashboard uses X, medical uses Y): rejected (exactly the drift SC-001/SC-002 exist to prevent). Passing context objects through widget constructors: rejected (defeats provider reactivity, impossible for 41 profile references). Forked per-space providers at switch time: rejected as premature tuning — the streams are already watched and cheap.

---

## R9. Migration plan shape

**Decision**: Two numbered steps, additive-first, consistent with the repo's immutable-step convention (`schema_migrations.dart:84-105`, latest step `_step11AddThemePreference`, `schemaVersion = 11`):
- **Step 12** (additive, empty body — matches the house pattern, `schema_migrations.dart:148-159`): registers `SharedSpace`, `SharedMember` collections (created by Isar on open) and all nullable columns/indexes above. Zero data movement.
- **Step 13** (backfill, idempotent): assign `profileId` to every existing `MonthlyBudget` (`findAll`, choose the single profile — create id-1 'User' if none); assign `profileId` to any `MedicalBill` whose profileId is null by resolving via linked expense or the single profile (`_pickProfile` behavior, `medical_repository.dart:807-816`); ensure Expense/Reimbursement/Bill rows are never all-null-context. Re-runnable (each row only touched when null).
`schemaVersion` 11 → 13. Monetary amounts are **never rewritten** — SC-003's "byte-identical" holds for every amount, seal and month total.

**Rationale**: Matches the house migration discipline (the failed alternative — schema regeneration from scratch — has no rollback story, same as 010 research R6). Step 12 is best-effort schema shape; step 13 is where data actually moves, separated so the additive cut ships independently reviewable from the backfill.

**Alternatives considered**: One combined step: rejected (mixing additive-vs-data movement breaks the 010 pattern where additive and imperative steps are separate). Backfill by foreign keys instead of a single-profile resolve: impossible today (bills without profileId have no FK to follow).