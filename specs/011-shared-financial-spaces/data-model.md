# Phase 1 Data Model: Multi-User Profiles & Shared Financial Spaces (Unified)

**Feature**: 011-shared-financial-spaces | **Date**: 2026-10-09
**Persistence**: Isar 3.1 (local-only) · **schemaVersion**: 11 → 13

---

## 1. Value Types

### 1.1 SharedMemberRole

| Value | Permissions (short) | Full gate |
|---|---|---|
| `owner` | view + edit + manage | canView + canEdit + canManage (FR-002/005) |
| `editor` | view + edit | canView + canEdit; refused Owner-only actions |
| `viewer` | view only | canView only; no add/edit/delete/people/space |

Enforced by `SpaceAccessGuard` (§5), **at the data layer**, never only in UI.

### 1.2 ContextRef (non-persisted router value)

| Field | Type | Meaning |
|---|---|---|
| `isShared` | bool | space context (true) vs personal context (false) |
| `profileId` | int? | the active personal profile (null when a shared space is active) |
| `spaceId` | int? | the active shared space (null for personal context) |
| `yearMonth` | String | the selected month |

**Invariant**: `isShared == (spaceId != null)` and exactly one of `profileId`/`spaceId` is set. This is the single route (FR-004) every scoped query and engine provider resolves through.

---

## 2. New Collections

### 2.1 SharedSpace — *one collaboration room*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `name` | String | required, non-empty (FR-002) |
| `avatar` | String | emoji; default `'👨‍👩‍👧'` |
| `currency` | `PrimaryCurrency` (`@enumerated`) | shared display/default currency (FR-002) |
| `defaultIncome` | int | **our-income default**, whole minor units (FR-009) |
| `createdByProfileId` | int | the creating Owner (provenance; the creator becomes Owner, FR-006) |
| `createdAt` | DateTime | creation timestamp (FR-002) |

**Bring-in-past is a creation-time choice, not stored**: `bringIn = thisMonth | thisYear | everything` is applied in the same transaction that inserts the space (creates `MonthlyBudget` rows for the selected months). From then on, future months appear automatically (FR-011) via `ensureMonth(context, yearMonth)` on navigation.

### 2.2 SharedMember — *the link between a profile and a space*

| Field | Type | Validation / Notes |
|---|---|---|
| `id` | Id | autoIncrement |
| `sharedSpaceId` | int | `@Index(unique: true, composite: [sharedSpaceId, profileId])` — one membership per (space, profile) |
| `profileId` | int | which profile is a member |
| `role` | `SharedMemberRole` (`@enumerated`) | Owner / Editor / Viewer |
| `joinedAt` | DateTime | join date (FR-006) |

**Invariants** (enforced in `spaces_repository` write paths + tests):
- A space always has **≥ 1 Owner** (FR-006; leave blocked while last Owner, FR-014).
- Creator row inserted as `owner` with `joinedAt = createdAt`.

---

## 3. Modified Entities

### 3.1 UserProfile

| Change | From | To |
|---|---|---|
| `avatar` | *(none)* | **added** `String = ''` (emoji) — FR-001 |
| `lastActiveAt` | *(none)* | **added** `DateTime?` — last context switch/use (FR-001) |
| *(used by)* | single row, id pinned to 1 at setup | **N profiles**; selection via `activeProfileIdProvider`; first profile keeps id 1 (`budget_setup_provider.dart:101-104`), later profiles auto-int (R2) |
| *(untouched)* | — | `monthlyAvailableAmount`, `defaultNetSalary` (legacy `double`), `primaryCurrency`, `fontFamily`, `themeMode` stay as-is (assumption: personal income columns kept) |

### 3.2 MonthlyBudget — *month owner becomes context-owned*

| Field | Type | Validation / Notes |
|---|---|---|
| `profileId` | `int?` | **added**; `@Index` composite `[profileId, yearMonth]` |
| `sharedSpaceId` | `int?` | **added**; `@Index` composite `[sharedSpaceId, yearMonth]` |
| `sharedIncomeOverride` | `int?` | **added** — "Our income" per-month override, whole minor units (FR-009, R4) |
| *(unchanged)* | — | `yearMonth`, `baseAvailableAmount`, `openingBalanceConfirmed`, `netSalaryOverride` (personal override, legacy `double`), `currency` (display-only convert-to, 010) |

**Invariant**: exactly one of `profileId` / `sharedSpaceId` set (FR-003). Uniqueness per context: `(profileId, yearMonth)` and `(sharedSpaceId, yearMonth)` are the operational keys. `ensureMonth` becomes `ensureMonth(contextRef)`.

**Personal-pot re-labelling only**: `netSalaryOverride` + `defaultNetSalary` stay; the user-facing labels become "My income" (FR-009, assumption). The shared pot is a *separate* field so "the two never influence each other".

### 3.3 Expense

| Field | Type | Change |
|---|---|---|
| `sharedSpaceId` | `int?` | **added**, `@Index` |
| `profileId` | `int` | unchanged (still indexed) |
| `yearMonth`, `amount`, `currency`, `budgetId`, `status` ... | — | unchanged; `budgetId` re-pointed to the target budget on move |

**Invariant**: exactly one of `profileId` (personal) / `sharedSpaceId` (shared) set. Personal rows keep `profileId != null`, `sharedSpaceId == null`; shared rows the mirror.

### 3.4 Reimbursement

| Field | Type | Change |
|---|---|---|
| `sharedSpaceId` | `int?` | **added**, `@Index` |
| `profileId`, `expenseId`, `originYearMonth`, `orphaned`, `amount`, `currency` | — | unchanged |

**invariant**: same exactly-one-context rule. **Crucial**: credit goes to the **`originYearMonth`'s context** (`true_available_provider.dart:29-36`, `month_summary_provider.dart:18-24`) — a move shifts these rows' origin month rows too (R5).

### 3.5 MedicalBill

| Field | Type | Change |
|---|---|---|
| `sharedSpaceId` | `int?` | **added**, `@Index` |
| `profileId` | `int?` | unchanged (nullable today) |
| `linkedExpenseId`, `familyMemberId`, `providerId`, `serviceTypeId` | — | unchanged; ids stay valid because the referenced directory rows move with the bill's context (R3/R5) |
| `yearMonth`, `state`, `paymentMethod`, `patientSharePercent`, `billedAmount`, `currency`, derived getters | — | unchanged (insurance math untouched, FR-013) |

### 3.6 Medical directory — InsuranceProfile · FamilyMember · MedicalProvider · MedicalServiceType

| Field | Type | Change |
|---|---|---|
| `sharedSpaceId` | `int?` | **added**, `@Index` to each — **space-owned directory** when the space has bills (R3) |

`InsuranceProfile.defaultPatientPercent` / `MedicalServiceTypeDefaults.seed(profileId)` become context-aware (seed(spaceId) when a space activates medical for the first time).

### 3.7 SavingsVault — *unchanged, personal-only*

No `sharedSpaceId`, no space acceptance. Queries stay `profileIdEqualTo` (`vault_repository.dart:16-29`). FR-017: shared spaces must not offer/accept vault data.

### 3.8 MonthRateSeal / LiveRateSet — *unchanged, device-global*

No context column. Sealed past months remain immutable for **every role in every context** (FR-012). The seal coordinator stays device-global; only `_eligibleMonths` uses distinct `yearMonth` across contexts (R6).

---

## 4. Context Routing & Query Scoping

```
ContextRef
  ├── personal:  [profileId]      → budget  = MonthlyBudget(profileId,  yearMonth)
  ├── shared:    [spaceId]        → budget  = MonthlyBudget(spaceId,    yearMonth)
  ├── expenses   = Expense.filter().profileIdEqualTo(p)      or  .sharedSpaceIdEqualTo(s)  + yearMonth
  ├── reimbursements = ... originYearMonth + context
  ├── bills      = MedicalBill.filter().profileIdEqualTo(p)  or  .sharedSpaceIdEqualTo(s)  + yearMonth
  └── directory  = FamilyMember/Provider/ServiceType/InsuranceProfile ... + context
```

Engine providers (`trueAvailableProvider`, `safeToSpendProvider`, `monthSummaryProvider`, `dailyLimitProvider`, medical providers) and month-finance operations read `budgetContextProvider` (a synchronous derived provider) — a context switch is one `activeSpaceId` write and every dependent stream rebuilds in the same frame (FR-004/SC-002). All scoped reads/writes go through this route; **no query filters on `yearMonth` alone anymore in feature code** (with the single documented exception: seal coordinator month discovery, which is deliberately device-global, R6).

---

## 5. SpaceAccessGuard — data-layer role gate

| Gate | Roles allowed | Actions gated |
|---|---|---|
| `canView(context, member)` | owner/editor/viewer | opening a space, reading its months/money |
| `canEdit(context, member)` | owner/editor | add/edit/delete expense, reimbursement, medical bill, budget income, convert-to |
| `canManage(context, member)` | owner only | rename space, change avatar/currency/income, invite, change roles, remove member, transfer ownership, delete space |

Rules (all enforced in repository write txns + unit-tested, FR-005/SC-005):
- non-member → throw `UnauthorizedSpaceAction` on any gate.
- sealed past month → **no role** may write, whatever the gate (FR-012).
- last Owner cannot leave / cannot be demoted (FR-006, FR-014); transfer demotes former Owner to Editor on the same txn.
- both-context or null-context record → write refused by the invariant check (§2/§3 rules), covered by tests (SC-005).

---

## 6. Move / Delete / Transfer Operations (state transitions)

### 6.1 `moveMonth(ContextRef from, ContextRef to, String yearMonth, {int? targetProfileId})`

```
guard: to-context may view  →  target does NOT already own a MonthlyBudget(yearMonth) → proceed
txn:
  1. gather rows: budgets, expenses, reimbursements (originYearMonth), bills, directory refs
  2. re-point every row's context columns (from → to)
  3. carry income per R4 (source resolved figure → target pot override, one-cut conversion if currencies differ)
  4. re-point linked Expense.budgetId to the target budget id
  5. move referenced directory rows (dedupe by name within target context) or recycle existing
```

### 6.2 `deleteSpace(spaceId, {required decisions: Map<yearMonth, moveToProfileId|delete>})`

```
for each month: user decided move-back (→ that profile) or delete   [UI, per spec FR-014]
txn: apply each decision (moveMonth or delete rows) + delete directory + SharedSpace + SharedMembers
     member profiles untouched
```

### 6.3 `transferOwnership(spaceId, newOwnerProfileId)` / `leaveSpace(profileId, spaceId)`

- transfer: newOwner role → owner; formOwner role → editor (same txn).
- leave: refused while the leaver is the **only** owner; else delete membership row (rows stay — they belong to the space, not the member).

---

## 7. Data Migration Plan (steps are immutable once shipped)

| Step | Type | Contents | Phasing |
|---|---|---|---|
| **12** | additive, reversible | create `SharedSpace`, `SharedMember`; add nullable context columns + composite indexes (§3); add `UserProfile.avatar`, `lastActiveAt`. Empty imperative body (house pattern, `schema_migrations.dart:148-159`) | ships first; zero data movement |
| **13** | backfill, idempotent | assign `profileId` to every existing `MonthlyBudget` (single profile, create id-1 'User' if absent); assign `profileId` to null-context `MedicalBill` rows via linked expense / `_pickProfile` (`medical_repository.dart:807-816`); guarantee no money row is all-null-context | data movement; amounts byte-identical (SC-003) |

`schemaVersion` 11 → 13. **No monetary amount, seal or month total is rewritten** — SC-003's byte-identical clause.

---

## 8. Validation Rules Summary (traceable to spec)

| Rule | FR |
|---|---|
| Personal rows of any profile unreadable anywhere else; exactly-one-context enforced + tested | FR-001/003, SC-001/005 |
| Shared space carries own name/avatar/currency/income; invite-only; creator Owner | FR-002/006 |
| One route resolves active context; every screen recomputes in the same frame; switch writes nothing but the context marker | FR-004, SC-002 |
| Roles enforced by `SpaceAccessGuard` at the data layer | FR-005, SC-005 |
| Move = one transaction, single copy, no drift; blocked when target already owns the month | FR-007/010, SC-006 |
| Moved month keeps its recorded income under the target pot | FR-008, SC-007 |
| Personal vs shared income pots never influence each other; new fields whole minor units | FR-009, SC-007 |
| Future months appear automatically; sealed months immutable for every role | FR-011/012, SC-004 |
| Medical bills keep insurance lifecycle; reimbursements credit the shared space | FR-013 |
| Leave/transfer/delete rules incl. per-month move-back prompt and atomic removal | FR-014 |
| Analytics placeholder present in both contexts, compute-nothing | FR-015, SC-008 |
| Fully offline for every op | FR-016 |
| Vault stays personal-only | FR-017 |
| Shared entries apply immediately, no approval | FR-018 |