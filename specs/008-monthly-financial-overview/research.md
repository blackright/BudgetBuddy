# Phase 0 Research: Monthly Financial Overview & Medical Bills

**Feature**: `008-monthly-financial-overview` | **Date**: 2026-10-04 | **Plan**: [plan.md](./plan.md)

Every `NEEDS CLARIFICATION` in the Technical Context is resolved below. Each entry records the decision, the reason, and the alternatives that were evaluated and rejected. Decisions marked **[CONSTITUTION]** are cross-cutting and referenced by the plan's Complexity Tracking table.

---

## R01 — Store the opening balance in the existing per-month record **[CONSTITUTION]**

**Decision**: Reuse `MonthlyBudget.baseAvailableAmount` as the per-month opening balance. Do not add a parallel field or collection.

**Rationale**: `MonthlyBudget` is already keyed by `yearMonth`, holds the month's starting figure, and is already read by `trueAvailableProvider` as `baseAmount`. The constitution itself calls this concept the user's "available amount" for the month, which is precisely an opening balance. FR-008's formula then reduces to an existing expression:

```
money in bank = baseAvailableAmount + income − paid + reimbursements
trueAvailable  = baseAvailableAmount − paid + reimbursements
⇒ money in bank = trueAvailable + income
```

So the bank figure needs one new term (income) on top of a calculation that already exists and is already reactive.

**Alternatives considered**:
- *New `OpeningBalance` collection* — rejected. Duplicates the month key, adds a second lookup on every month open, and forces a join to answer a question that is already stored per month.
- *New `openingBalance` field on `MonthlyBudget`* — rejected. A pure rename in Isar 3.1 is indistinguishable from drop-and-add; the existing value would be silently orphaned to `0`. Keeping the field name and changing its documented meaning is migration-free.
- *Derive the opening balance from the previous month's closing balance* — rejected by FR-007 explicitly. The user stated each month is independent and must be entered by hand; deriving it would silently reintroduce carryover.

---

## R02 — Where income lives

**Decision**: Two fields, split by scope.
- `UserProfile.defaultNetSalary` — the profile-wide default (FR-001, FR-002).
- `MonthlyBudget.netSalaryOverride` — a nullable per-month value (FR-003).

Effective income for a month = `netSalaryOverride ?? profile.defaultNetSalary`.

**Rationale**: FR-002 ("applies to every month that does not define its own value") and FR-003 ("without affecting any other month") are exactly the semantics of a nullable override column. FR-004 (a settings change must not retroactively alter reviewed months) falls out for free: past months that were resolved against the default at the time they were reviewed must be *pinned*, which means a settings change must not silently rewrite them.

**Alternatives considered**:
- *Store an effective salary on every `MonthlyBudget` row, written at month creation* — rejected. It makes FR-004 impossible to honour without a "has the user reviewed this?" flag, which is a second piece of state doing the same job as a nullable override.
- *A `MonthlyIncome` collection* — rejected. It would duplicate `MonthlyBudget`'s month key and add no information the override column cannot hold.
- *Keep salary in `UserProfile.monthlyAvailableAmount`* — rejected. That field is the pre-onboarding starting figure written once by `budget_setup_provider`; conflating it with take-home pay would break the onboarding flow and the currency defaulting that depends on it.

---

## R03 — Promote month selection to shared state

**Decision**: Replace the hardcoded `currentYearMonthProvider` (a plain `Provider<String>` returning `DateFormat('yyyy-MM').format(DateTime.now())`) with a `StateProvider<String>` in a new `lib/core/providers/selected_month_provider.dart`, plus helpers for previous / next / today.

**Rationale**: This is the highest-leverage change in the feature. `currentYearMonthProvider` has exactly one definition and feeds `activeBudgetProvider`, which in turn has 12 consumers across the dashboard, expense list, add/edit expense, expense detail and medical providers. Because every month-scoped query already resolves through `activeBudgetProvider`, FR-027 ("the selected month remains in effect when moving between the dashboard, expenses, medical bills and reports") is satisfied by making the single funnel stateful — with no changes to any consuming screen and no route-level plumbing.

It also makes FR-028 (past months editable) and FR-029 (future months openable) automatic, because editing already writes to `activeBudgetProvider`'s month.

**Alternatives considered**:
- *Per-screen month state passed via router arguments* — rejected. Requires touching 12 call sites plus the router, duplicates state across screens, and guarantees the screens can disagree — the opposite of FR-027.
- *A `ScopedWidget` / inherited month per branch* — rejected. GoRouter's `StatefulShellRoute` keeps branch state alive independently, so an inherited value would be silently discarded on tab switch. A provider is the only mechanism guaranteed to survive navigation.

**Consequence**: `sweep_provider.dart` also reads `currentYearMonthProvider` (line 20). It must be updated to the new provider name. It is otherwise out of scope.

---

## R04 — The month report is a pure derived value object

**Decision**: Create `lib/features/engine/month_summary.dart` as a plain Dart class with no Isar or Riverpod imports, constructed from one month's rows. Expose it through `monthSummaryProvider`.

**Rationale**: FR-017 says the month summary is "never stored, always recalculated", and the constitution's "modular financial logic" principle wants all arithmetic outside presentation. FR-024 requires the dashboard and the Medical tab to read the medical total from "a single source so they cannot disagree" — a shared pure function is the only way to make disagreement structurally impossible. SC-004's "zero discrepancies across 10 months" is then verifiable as a plain unit test with no database.

**Alternatives considered**:
- *Extend `trueAvailableProvider` and add sibling providers* — rejected. It spreads one report across six providers that each recompute overlapping subsets; nothing structurally prevents the dashboard and the Medical tab from diverging, which is exactly what FR-024 forbids.
- *Persist a `MonthSummary` row* — rejected by FR-017, and it would need invalidation on every expense write.

---

## R05 — Reimbursement carries its own origin month **[CONSTITUTION]**

**Decision**: Add an indexed `originYearMonth` to `Reimbursement`, and make `expenseId` nullable.

**Rationale**: This fixes the active data-loss defect in User Story 3 and satisfies FR-032/FR-033. Today `monthlyReimbursementsProvider` derives the reimbursement set from the *current month's expense ids*:

```dart
final expenses = ref.watch(monthlyExpensesProvider).value ?? [];
final expenseIds = expenses.map((e) => e.id).toList();
return repository.watchReimbursementsForExpenses(expenseIds);
```

A reimbursement entered in April against a January expense is therefore invisible not only in April but in **January** — the month it belongs to — so the money never appears anywhere. Denormalizing the origin month onto the reimbursement row makes the correct query a direct indexed filter that does not depend on the expense still existing.

Making `expenseId` nullable is required by FR-035: a reimbursement whose expense was deleted must survive, be surfaced to the user, and be removable only by explicit action. Today the linkage is non-nullable, so an orphaned reimbursement cannot even be represented.

**Alternatives considered**:
- *Join through `expense.yearMonth` at query time* — rejected. Requires the expense row to exist, so it cannot satisfy FR-035 at all, and it repeats the join on every month switch.
- *Reuse `reimbursement.date`* — rejected. `date` is when the user *recorded* it, which is precisely what FR-032 says must not drive attribution.
- *Add `yearMonth` to the reimbursement and let the user choose* — rejected. FR-032 mandates the expense's month; offering a choice would let the user re-introduce the bug.

---

## R06 — Attribution is read, never written at entry time

**Decision**: `originYearMonth` is copied from the target expense's (or bill's) `yearMonth` when the reimbursement is recorded, and is immutable thereafter. Month totals sum reimbursements by `originYearMonth`.

**Rationale**: SC-005 requires a reimbursement entered up to 12 months late to credit the original month "in 100% of cases". Copying the value at entry time makes attribution stable even if the expense is later moved between months, and makes the write path a single place to get right.

**Alternatives considered**:
- *Resolve attribution dynamically from the linked expense on every read* — rejected. Moving an expense to a different month would silently reassign a historical payout, breaking the reconciliation the user relies on when reviewing a closed month.

---

## R07 — The linked `Expense.amount` is a function of method, share and state **[CONSTITUTION]**

**Decision**: Keep `Expense` as the sole record of money impact. `MedicalRepository._syncLinkedExpense` computes the written amount from `(paymentMethod, patientSharePercent, billedAmount, state)` instead of always writing `billedAmount`:

| Payment method | State | `Expense.amount` | Requirement |
|---|---|---|---|
| Insurer-paid | waiting / paid / finished | `billed × patientShare% ÷ 100` | FR-042, FR-043 |
| Insurer-paid | rejected | `billed` (full charge) | FR-051 |
| Insurer-paid | planned | `0` — stays a planned expense | FR-053 |
| Self-paid | waiting / paid / finished | `billed` | FR-045 |
| Self-paid | rejected | `billed` (unchanged, no return) | FR-050 |
| Either | planned | `0` until the user marks it paid | FR-053 |

The expense's `yearMonth` becomes the bill's owning month (FR-055), derived from the service date with a user override — today it is hardcoded to the *active budget's* month, which misfiles any bill whose service date differs from the month being viewed.

**Rationale**: FR-042 and FR-051 are both statements about how much money leaves funds. Writing that amount into the one record the engine already reads (`Expense.amount`) means FR-043's "at the moment the bill is entered" is satisfied by the existing Isar watcher with no new notification path, and FR-056 (medical bills are an ordinary category in general totals) holds for free. It also satisfies FR-024's single-source requirement without a parallel calculation.

**Alternatives considered**:
- *Keep `Expense.amount = billedAmount` and subtract the insurer's share at read time* — rejected. The engine sums raw expense amounts in three places (`trueAvailableProvider`, `safeTo_spend_provider`, `expenses_provider`); a read-time adjustment in only one of them guarantees disagreement, and `safeToSpendProvider` has 6 consumers that would each need the same adjustment.
- *Store the patient share as a second expense field and branch in the engine* — rejected. Moves domain rules into the summation layer, contradicting Constitution IV's modular-logic principle, and multiplies the work at every read site.

---

## R08 — Store the patient's percentage, not the insurer's

**Decision**: Replace `MedicalBill.insuranceCoveragePercent` with `patientSharePercent`, holding the share the **user** is responsible for (20 or 0 for the user's plan). Derive `patientShareAmount = billedAmount × patientSharePercent ÷ 100`.

**Rationale**: FR-048 says "the percentage **the user is responsible for** MUST be recorded per bill". The user reasons in these terms throughout — "you pay 20%", "you pay nothing" — and 100% coverage means `patientSharePercent = 0`, which cannot be represented in a coverage field without special-casing. Storing the user's share also makes FR-042's formula read directly off the stored value with no inversion at every calculation site.

**Alternatives considered**:
- *Keep `insuranceCoveragePercent`* — rejected. Every consumer must invert it (`100 − x`), and 100% coverage degenerates to `patientShare = billed`, which is easy to get wrong. It also mismatches the UI language the user asked for.
- *Store both* — rejected. Two fields that must agree is a permanent inconsistency risk for no benefit.

**Migration**: `patientSharePercent = 100 − insuranceCoveragePercent` (see R13).

---

## R09 — Replace `ClaimStatus` with a five-state bill lifecycle

**Decision**: Replace `ClaimStatus { unclaimed, processing, reimbursed, denied }` with `MedicalBillState { planned, waiting, paid, finished, rejected }`, per FR-052, and map each state to its effect on totals:

| State | Counts as | `Expense.status` | Reimbursement |
|---|---|---|---|
| `planned` | planned | `planned` | none |
| `waiting` | paid | `paid` | none (insurer-paid: share already paid) |
| `paid` | paid | `paid` | none |
| `finished` | paid | `paid` | self-paid: exactly one, all-or-nothing |
| `rejected` | paid | `paid` | none — funds do not return |

**Rationale**: The existing `ClaimStatus` models the *insurer's* workflow and is deliberately independent of `ExpenseStatus` (see the doc comment on `MedicalBill`). That independence is what allowed Method A to be unimplementable: there is no state meaning "the insurer is handling this and I have already paid my share". FR-052/FR-053 require the state to drive the planned/paid classification, so the two lifecycles must be unified into one. FR-049 (all-or-nothing) is enforced by collapsing to a single reimbursement row, which `logReimbursement` already does.

**Alternatives considered**:
- *Keep `ClaimStatus` and add a `hasUserPaidShare` flag* — rejected. Two overlapping state machines for one bill is the ambiguity that produced the current overstatement.
- *Reuse `ExpenseStatus` directly with no bill-specific state* — rejected. Cannot express "waiting for insurance" or "rejected", which FR-052 requires.

**Migration mapping**: `unclaimed → waiting`, `processing → waiting`, `reimbursed → finished`, `denied → rejected`.

---

## R10 — Service types are data, not an enum

**Decision**: New `MedicalServiceType` Isar collection (`profileId`, `name`, `isDefault`, `sortOrder`, `archived`), seeded per profile with the six types named in FR-039. Bills reference it by `serviceTypeId`.

**Rationale**: FR-040 requires the user to add, rename and remove service types. A Dart enum cannot be extended at runtime, so FR-039's "user-editable list" is unimplementable as an enum. Archiving rather than hard-deleting preserves historical bills that reference a removed type (FR-055 requires bills to stay attributable to their month; a dangling reference would break that).

**Alternatives considered**:
- *Dart enum + a free-text override field* — rejected. Two competing sources of truth for the same concept; grouping would have to merge both and would drift.
- *Free-text `serviceType` string on the bill* — rejected. FR-040's "add, rename and remove" implies a managed list; free text produces spelling variants that fragment grouping.

---

## R11 — Split the attachments

**Decision**: Replace `List<String> attachmentPaths` with two optional fields: `billPhotoPath` and `insurerReplyPath`.

**Rationale**: FR-047 distinguishes "a picture of the bill and a picture of the insurer's reply" — two documents with different meanings and different lifecycles. A single ordered list cannot express which is which, so the UI would depend on list position. Both are optional, which is what makes FR-044 possible: an insurer-paid bill legitimately has neither.

**Alternatives considered**:
- *Keep the list and store a role prefix* — rejected. Encodes structure in string prefixes inside a file-path field.
- *A separate `MedicalDocument` collection* — rejected. Two documents per bill does not justify a fourth collection; nullable fields are simpler and cannot get out of sync with the bill.

---

## R12 — Remove deductibles and the per-year insurance key **[CONSTITUTION]**

**Decision**: Delete `InsuranceProfile.individualDeductible`, `InsuranceProfile.familyDeductible` and the indexed `year` field. Keep one profile-level default, renamed `defaultPatientPercent` (default 20), consistent with R08. Delete `DeductibleProgress` and all deductible aggregation from `medical_providers.dart` and `medical_dashboard.dart`. Bills are treated as having no deductible (FR-038).

**Rationale**: FR-036/FR-037/FR-038 are unambiguous: no deductible value, field, or progress indicator may survive. The `year` field existed *only* because deductible limits reset annually — its own doc comment says so — so it becomes dead weight once deductibles are gone, and removing it collapses "one insurance profile per profile per year" to one row per profile, which is what `watchInsuranceProfile` actually wants.

SC-007 ("no deductible value, progress indicator, or field appears anywhere in the running application") is a whole-app check, so this decision spans the model, the providers, and the presentation layer.

**Alternatives considered**:
- *Keep the fields but stop displaying them* — rejected. FR-037 requires removal from stored settings, and SC-007 would pass while dead data persisted.
- *Keep `year` for future per-year policy changes* — rejected as speculative. FR-039/FR-040 already give the user the extensibility they asked for; an unused per-year key would need a migration whenever it is eventually justified.

---

## R13 — Explicit version-stamped migration, not Isar auto-migration **[CONSTITUTION — APPROVED]**

**Decision**: Add `lib/core/database/schema_migrations.dart` with a version stamp stored in a small key/value collection (or `Isar` metadata). It runs once after `IsarHelper.init()` and performs, in one transaction:

1. **Clear deductibles** — zero `individualDeductible` and `familyDeductible` on every `InsuranceProfile` row (FR-037).
2. **Invert coverage to patient share** — `patientSharePercent = 100 − insuranceCoveragePercent`; `defaultCoveragePercent → defaultPatientPercent = 100 − value`. Preserves the user's real data instead of resetting it to a guess.
3. **Map claim states** — `unclaimed/processing → waiting`, `reimbursed → finished`, `denied → rejected` (R09).
4. **Backfill `originYearMonth`** on every `Reimbursement` from its expense's `yearMonth`, defaulting to the reimbursement's own `YYYY-MM` where the expense is missing (FR-032, FR-035).

**Rationale**: Isar 3.1 has no declarative migration API. Its automatic schema migration handles *added* properties but cannot invert or remap *values*, and a rename is indistinguishable from drop-plus-add — so relying on it would silently reset every existing bill's percentage to a default and every deductible to zero. Because the app is local-only and single-device, a one-time stamped pass is sufficient and cheap. Doing this in a single transaction means a partially migrated database is impossible.

**Alternatives considered**:
- *Recreate the database and ask the user to re-enter everything* — rejected. The medical data is the user's most sensitive and most expensive-to-recreate data, and the constitution's Governance section treats migration as a first-class concern.
- *Lazy migration at read time* — rejected. Repeated checks on hot read paths, and no single point at which correctness can be asserted.

**Ratified amendment** — approved by the project owner on 2026-10-04 and applied to `.specify/memory/constitution.md` as **v1.2.0**, with the superseded text, rationale and migration plan recorded in that file's *Amendment Record*:

> **IV. Modular Financial Logic & Real-time Availability** … *(planned does not reduce / paid reduces / reimbursed increases / cancelled no effect — unchanged)* …
> - **Medical Bills**: Modelled as an expense whose effect on available funds depends on the payment method. **(a) Insurer-paid** — the insurer bills the provider directly; only the patient's share reduces available funds, immediately at entry; no reimbursement is recorded. **(b) Self-paid** — the full charge reduces available funds immediately; any insurer return increases it as a reimbursement. Reimbursement is all-or-nothing; partial reimbursement is not modelled. A rejected insurer-paid claim raises the patient's obligation to the full charge. **No deductible applies.**

Migration plan accompanying the amendment, recorded in the constitution's *Amendment Record* and specified in `data-model.md` §10: steps 1 and the deductible UI removal in `medical_dashboard.dart` (FR-036/SC-007), step 2 (FR-048), step 3 (FR-052), step 4 (FR-032), step 5 (FR-055), step 6 (FR-010).

---

## R14 — Over-reimbursement is surfaced, never netted

**Decision**: `Money returned` credits the reimbursement's full recorded amount. If it exceeds the associated payment, the difference is exposed as `excessAmount` on `MonthSummary` and displayed as a distinct line. `Payments made` is never reduced below zero and `kept this month` is never floored at zero by an excess.

**Rationale**: The spec's edge case requires that "the bank and kept figures must not silently produce a negative expense; the excess must be shown as a distinct amount rather than hidden". Clamping or silently absorbing the excess would hide a real event — typically a provider refund or an insurer overpayment — that the user needs to see and act on. Keeping `excessAmount` separate also preserves SC-004's exactness: `kept = income − payments + returned` remains true as written.

**Alternatives considered**:
- *Clamp the reimbursement to the expense amount* — rejected. It hides the discrepancy and makes the recorded amount disagree with the displayed total.
- *Let `payments made` go negative* — rejected. It breaks the meaning of "payments made" and makes the dashboard unreadable.

---

## R15 — Colour tokens are centralised, not repeated

**Decision**: Define the FR-019 semantic colours once (income and returned = green, payments = red, planned = orange) in `medical_theme.dart` as the existing shared location for medical colour semantics, and consume them from every screen that renders a figure.

**Rationale**: FR-020 requires colour meaning to be "consistent everywhere in the app and MUST NOT vary by screen". The dashboard's current inline `Colors.green` for Safe to Spend is exactly the kind of screen-local choice that produces drift. Centralising also satisfies Constitution VI's requirement for clear visual distinction between planned, paid and reimbursed amounts, and SC-003 requires that the three remain distinguishable by label or position with colour removed.

**Alternatives considered**:
- *Inline colours per widget* — rejected; this is the drift FR-020 prohibits.
- *A new app-wide design-token file* — rejected as scope creep for one feature. The existing `medical_theme.dart` already serves this purpose in the codebase and keeps the change additive.

---

## R16 — Month rows are provisioned on demand

**Decision**: `MonthFinanceRepository.ensureMonth(yearMonth)` creates a `MonthlyBudget` row for any month the user opens, copying the active profile's currency and seeding `openingBalanceConfirmed = false`. The month-selection provider calls it when navigating to a month with no row.

**Rationale**: `activeBudgetProvider` returns `null` when no `MonthlyBudget` exists for the month, and `trueAvailableProvider` then yields `0.0`. Today rows are created only by `budget_setup_provider` during onboarding, for one month — which is why past and future months are unreachable today. FR-028 and FR-029 both require opening a month that has no row. `openingBalanceConfirmed = false` is what lets FR-010 prompt for a balance instead of silently treating an unentered month as zero.

**Alternatives considered**:
- *Have `activeBudgetProvider` return a transient in-memory budget when no row exists* — rejected. Nothing could then be saved against that month, so FR-029's "planned expenses entered against a future month" would fail.
- *Require the user to complete a setup wizard for each new month* — rejected. FR-007 requires each month to carry its own figure, but not a wizard; a single inline prompt satisfies it with less friction.

---

## Constitution compliance summary

| Requirement group | Constitutional basis | Status |
|---|---|---|
| FR-001–FR-017 income, opening balance, month report | IV (available amount per month), III (offline) | Compliant — R01, R02, R04 |
| FR-018–FR-025 dashboard | VI (clear planned/paid/reimbursed distinction) | Compliant — R15 |
| FR-026–FR-030 month navigation | IV (per-month isolation) | Compliant — R03, R16 |
| FR-031–FR-035 reimbursements | IV (reimbursed increases available) | Compliant — R05, R06 |
| FR-036–FR-038 no deductible | IV (medical clause — **amended, v1.2.0**) | Compliant — R12, R13 |
| FR-039–FR-056 medical bills | IV (medical clause — **amended, v1.2.0**), II (testability) | Compliant — R07–R11 |

**Resolved**: Principle IV's medical clause was amended to v1.2.0 and approved by the project owner on 2026-10-04. The required migration plan is steps 1–6 of `data-model.md` §10. The constitution gate no longer carries an outstanding condition, and `/speckit-tasks` may proceed.