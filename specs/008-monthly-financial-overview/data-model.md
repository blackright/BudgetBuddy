# Phase 1 Data Model: Monthly Financial Overview & Medical Bills

**Feature**: `008-monthly-financial-overview` | **Date**: 2026-10-04 | **Plan**: [plan.md](./plan.md) | **Research**: [research.md](./research.md)

Conventions: Isar collections use `@collection` with `part '<name>.g.dart'` codegen. Money is `double`. Months are `String` in `YYYY-MM`. Relationship fields are nullable with an `@Index()`. Only *settings* are persisted — every report figure is derived at read time (FR-017).

---

## 1. `UserProfile` — MODIFIED

Existing fields (`id`, `name`, `primaryCurrency`, `monthlyAvailableAmount`, `createdAt`, `updatedAt`) are unchanged.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `defaultNetSalary` | `double` | `0.0` | Profile-wide take-home pay applied to any month without an override (FR-001, FR-002) |

**Validation**: `>= 0`.

**Notes**: `monthlyAvailableAmount` is *not* repurposed. It is written once during onboarding by `budget_setup_provider` and is independent of take-home pay (R02).

---

## 2. `MonthlyBudget` — MODIFIED

The per-month record. One row per `yearMonth` per installation (single active profile today; multi-profile keys preserved in every other collection).

| Field | Type | Default | Purpose |
|---|---|---|---|
| `id` | `Id` | auto | — |
| `yearMonth` | `String` | — | **Uniqueness key** for the month (`YYYY-MM`) |
| `baseAvailableAmount` | `double` | `0.0` | **Reinterpreted** as the month's opening balance — money in the bank at the start of the month (FR-006) |
| `openingBalanceConfirmed` | `bool` | `false` | Distinguishes "entered as 0" from "never entered" (FR-010) |
| `netSalaryOverride` | `double?` | `null` | Income for this month only; `null` means "use `UserProfile.defaultNetSalary`" (FR-003) |
| `currency` | `PrimaryCurrency` | — | Unchanged |
| `createdAt` / `updatedAt` | `DateTime` | — | Unchanged |

**Derived (never stored)**:
```
effectiveIncome(month) = netSalaryOverride ?? profile.defaultNetSalary
usesOverride(month)    = netSalaryOverride != null
```

**Validation**:
- `baseAvailableAmount >= 0`
- `netSalaryOverride == null || netSalaryOverride >= 0`

**Relationships**: none. Income is resolved through the active profile, so there is no FK to maintain.

**Rules**:
- FR-007 — no carryover. A new row is provisioned with `baseAvailableAmount = 0.0` and `openingBalanceConfirmed = false`; nothing is copied from the previous month (R16).
- FR-011 — `baseAvailableAmount` stays editable after the month has passed.
- FR-004 — a `defaultNetSalary` change does not touch existing rows. A month only stops following the default once it has its own override.

---

## 3. `Expense` — UNCHANGED

Existing collection. **No schema change.** Its semantics are clarified, not altered:

- `amount` is the amount that has left (or will leave) the user's funds, expressed in the budget's primary currency with `exchangeRateToPrimary` applied.
- `status` remains the sole determinant of planned vs paid vs cancelled (Constitution IV, FR-053).
- `yearMonth` is the owning month.
- For a medical bill, `amount` is written by `MedicalRepository` as a function of payment method, patient share and bill state (R07) — never by the user directly.
- `paidAt` continues to mark when money actually moved.

**Relationship**: `MedicalBill.linkedExpenseId` → `Expense.id` (1:1, optional).

---

## 4. `Reimbursement` — MODIFIED

| Field | Type | Default | Purpose |
|---|---|---|---|
| `id` | `Id` | auto | — |
| `expenseId` | `int?` | **nullable** | Target expense or medical bill's linked expense. `null` = orphaned (FR-035) |
| `originYearMonth` | `String` | `''` | **Indexed.** The month the money belongs to — the target's month, never the entry date (FR-032) |
| `amount` | `double` | `0.0` | Full returned amount, all-or-nothing (FR-049) |
| `date` | `DateTime` | — | When the user *recorded* it. Display and audit only; never used for attribution |

**Validation**: `amount > 0`.

**Rules**:
- FR-034 — at most one reimbursement per target. Re-recording replaces `amount` and deletes any extra rows, so the engine never sees a doubled payout. `MedicalRepository.logReimbursement` already collapses duplicates; `expense_repository` must gain the same guarantee for non-medical expenses.
- FR-033 — a reimbursement is never discarded because it was entered in a different month than its target.
- FR-035 — a reimbursement whose `expenseId` no longer resolves is retained, listed as orphaned, and removed only on explicit user action.

**Relationship**: `expenseId` → `Expense.id`. Deliberately not a hard constraint: the row must outlive its target.

---

## 5. `MonthSummary` — NEW (pure value object, not an Isar collection)

`lib/features/engine/month_summary.dart`. No persistence, no Riverpod, no Isar. Constructed for exactly one `yearMonth` (R04).

| Field | Type | Formula | Requirement |
|---|---|---|---|
| `yearMonth` | `String` | — | — |
| `income` | `double` | `netSalaryOverride ?? profile.defaultNetSalary` | FR-012 |
| `paymentsMade` | `double` | `Σ Expense.amount × exchangeRateToPrimary` where `status == paid` | FR-012 |
| `moneyReturned` | `double` | `Σ Reimbursement.amount` where `originYearMonth == yearMonth` | FR-012, FR-032 |
| `planned` | `double` | `Σ Expense.amount × exchangeRateToPrimary` where `status == planned` | FR-018 |
| `medicalPaid` | `double` | `Σ` of the above where `categoryId == 'health'` **or** `type == medical` | FR-022, FR-024, FR-056 |
| `openingBalance` | `double?` | `baseAvailableAmount`, `null` when `!openingBalanceConfirmed` | FR-006, FR-010 |
| `cancelled` | `double` | `Σ` where `status == cancelled` — reported in hidden detail only | Constitution IV |
| `kept` | `double` | `income − paymentsMade + moneyReturned` | FR-012 |
| `moneyInBank` | `double?` | `openingBalance + income − paymentsMade + moneyReturned`; `null` when `openingBalance == null` | FR-008 |
| `excessReturned` | `double` | `max(0, moneyReturned attributable to a target − that target's paid amount)` | R14 |
| `usesOverriddenIncome` | `bool` | `netSalaryOverride != null` | FR-005 |
| `isComplete` | `bool` | `openingBalance != null && income > 0` | FR-025 |

**Invariants** (asserted in `month_summary_test.dart`):
1. `kept == income − paymentsMade + moneyReturned` for every input (SC-004).
2. `planned` never appears in `kept`, `moneyInBank`, or `paymentsMade` (FR-014, FR-015).
3. `openingBalance` has no term in `kept` (FR-013).
4. `moneyInBank == null` iff the month has no confirmed opening balance (FR-010).
5. `moneyInBank == trueAvailable + income` whenever the opening balance is confirmed (R01).
6. `medicalPaid <= paymentsMade` (FR-056).
7. `kept` and `moneyInBank` are never floored to zero by an excess reimbursement (R14).
8. Constructing a summary for month A cannot be influenced by any row belonging to month B (FR-016).

---

## 6. `MedicalBill` — MODIFIED

| Field | Type | Default | Purpose |
|---|---|---|---|
| `id` | `Id` | auto | — |
| `profileId` | `int?` | `null` | Indexed |
| `linkedExpenseId` | `int?` | `null` | Indexed; 1:1 → `Expense.id` |
| `familyMemberId` | `int?` | `null` | Indexed (kept; dependents are out of scope but the key already exists) |
| `providerId` | `int?` | `null` | Indexed → `MedicalProvider.id` |
| `serviceTypeId` | `int?` | `null` | Indexed → `MedicalServiceType.id` (FR-039) |
| `paymentMethod` | `MedicalPaymentMethod` | `selfPaid` | Indexed. Which of the two methods applied (FR-041) |
| `patientSharePercent` | `double` | `20.0` | Percentage **the user** is responsible for (FR-048). Renamed and inverted from `insuranceCoveragePercent` |
| `state` | `MedicalBillState` | `waiting` | Replaces `ClaimStatus` (FR-052) |
| `yearMonth` | `String` | `''` | **Indexed.** Owning month, from service date with user override (FR-055) |
| `serviceDate` | `DateTime?` | `null` | Indexed; drives the default `yearMonth` |
| `billedAmount` | `double` | `0.0` | Full charge |
| `billPhotoPath` | `String?` | `null` | Replaces the `attachmentPaths` list (FR-047) |
| `insurerReplyPath` | `String?` | `null` | Only meaningful for self-paid bills (FR-047) |
| `followUpDate` | `DateTime?` | `null` | Unchanged (pending-claim reminder) |
| `reimbursedAmount` | `double` | `0.0` | Denormalised copy of the linked reimbursement; `0` when none |
| ~~`insuranceCoveragePercent`~~ | — | — | **REMOVED** — superseded by `patientSharePercent` (R08) |
| ~~`claimStatus`~~ | — | — | **REPLACED** by `state` (R09) |
| ~~`attachmentPaths`~~ | — | — | **REPLACED** by the two photo fields (R11) |

**Derived (never stored)**:
```
patientShareAmount = billedAmount × patientSharePercent ÷ 100
isPending          = state == waiting
```

**Validation**:
- `billedAmount > 0`
- `0 <= patientSharePercent <= 100`
- `insurerReplyPath` requires `paymentMethod == selfPaid`
- `state == finished` with `paymentMethod == insurerPaid` is invalid (FR-044 — no reimbursement exists to finish)

**State transitions** (FR-052, FR-054; full effect table in `contracts/medical-bill-lifecycle.md`):

| From | To | `Expense.status` | `Expense.amount` | Reimbursement |
|---|---|---|---|---|
| — | `planned` | `planned` | `0` until paid | none |
| `planned` | `waiting` / `paid` | `paid` | insurer-paid: share · self-paid: full | none |
| `waiting` | `finished` | `paid` | unchanged | self-paid: **required** |
| `waiting` / `paid` | `rejected` | `paid` | insurer-paid: **full charge** · self-paid: unchanged | **deleted** (FR-050) |
| any | `rejected` → `waiting`/`paid` | `paid` | recomputed from method + share | none |

---

## 7. `MedicalServiceType` — NEW collection

FR-039/FR-040 require a user-editable classification list.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `id` | `Id` | auto | — |
| `profileId` | `int?` | `null` | Indexed |
| `name` | `String` | `''` | Display name |
| `isDefault` | `bool` | `false` | One of the six seeded types; protects it from casual deletion |
| `sortOrder` | `int` | `0` | Stable ordering in pickers |
| `archived` | `bool` | `false` | Soft-delete so historical bills keep a valid reference (R10) |

**Seed data** per profile (FR-039): `Radiology`, `Lab Work`, `Specialist Consultation`, `Generalist Consultation`, `Surgery`, `Medicine / Pharmacy`.

**Validation**: `name` non-empty after trimming; names unique per profile, case-insensitive.

**Rules**:
- FR-040 — add, rename, and archive are all permitted.
- Archiving does not affect existing bills; archived types remain readable on historical bills.

---

## 8. `InsuranceProfile` — MODIFIED

| Field | Type | Purpose |
|---|---|---|
| `id` | `Id` | — |
| `profileId` | `int?` | Indexed |
| `defaultPatientPercent` | `double` | Renamed from `defaultCoveragePercent` and inverted. Default `20.0` (R08) |
| ~~`individualDeductible`~~ | — | **REMOVED** (FR-037, R12) |
| ~~`familyDeductible`~~ | — | **REMOVED** (FR-037, R12) |
| ~~`year`~~ (indexed) | — | **REMOVED** — existed only because deductibles reset annually. One row per profile now |

**Rules**:
- FR-038 — every bill is treated as if no deductible applies. There is no field, calculation, or display path for one.
- `watchInsuranceProfile(profileId)` no longer filters by year, simplifying the lookup to a single row.

---

## 9. `MedicalProvider`, `FamilyMember`, `Category` — UNCHANGED

Retained as-is. `FamilyMember` stays because dependents are out of scope for this feature but the existing bill link must not be orphaned by the `MedicalBill` rewrite.

---

## 10. Schema migration — NEW

`lib/core/database/schema_migrations.dart`, run once after `IsarHelper.init()` inside a single transaction (R13). Registered alongside a new `MedicalServiceTypeSchema` in `isar_helper.dart`.

| # | Step | Requirement |
|---|---|---|
| 0 | Provision `MedicalServiceType` seed rows for the active profile if none exist | FR-039 |
| 1 | Zero `individualDeductible` and `familyDeductible` on every `InsuranceProfile` | FR-037 |
| 2 | `patientSharePercent = 100 − insuranceCoveragePercent`; `defaultPatientPercent = 100 − defaultCoveragePercent` | FR-048 |
| 3 | Map claim states: `unclaimed/processing → waiting`, `reimbursed → finished`, `denied → rejected` | FR-052 |
| 4 | Backfill `Reimbursement.originYearMonth` from the target expense's `yearMonth`; fall back to the reimbursement's own `YYYY-MM` when the expense is missing | FR-032, FR-035 |
| 5 | Backfill `MedicalBill.yearMonth` from `serviceDate`; fall back to the linked expense's `yearMonth` | FR-055 |
| 6 | Mark every pre-existing `MonthlyBudget` row `openingBalanceConfirmed = true` (its `baseAvailableAmount` was a user-entered figure) | FR-010 |

**Properties**:
- Idempotent — safe to re-run; guarded by a version stamp so it executes exactly once.
- Atomic — all steps in one transaction, so a partially migrated database is impossible.
- Non-destructive — no collection is dropped and no user-entered figure is discarded; step 1 clears only values the specification declares meaningless.

---

## 11. Entity relationships

```text
UserProfile ──1:N──> MonthlyBudget            (via yearMonth; implicit, no FK)
UserProfile ──1:1──> InsuranceProfile         (defaultPatientPercent)
UserProfile ──1:N──> MedicalServiceType       (seeded list)
UserProfile ──1:N──> MedicalProvider
UserProfile ──1:N──> FamilyMember

MonthlyBudget ──1:N──> Expense                (implicit, via yearMonth)
Expense ──1:N──> Reimbursement               (soft link; expenseId nullable)
MedicalBill ──1:1──> Expense                  (linkedExpenseId)
MedicalBill ──N:1──> MedicalServiceType       (serviceTypeId)
MedicalBill ──N:1──> MedicalProvider          (providerId)
MedicalBill ──N:1──> FamilyMember             (familyMemberId)

MonthSummary ──derived from──> Expense, Reimbursement, MonthlyBudget, UserProfile
                              (never stored)
```

## 12. Isar collection registration

`IsarHelper.init()` must add `MedicalServiceTypeSchema`. Existing registrations (`UserProfileSchema`, `MonthlyBudgetSchema`, `ExpenseSchema`, `ExpenseTemplateSchema`, `ReimbursementSchema`, `SavingsVaultSchema`, `CategorySchema`, `MedicalBillSchema`, `InsuranceProfileSchema`, `FamilyMemberSchema`, `MedicalProviderSchema`) are unchanged.