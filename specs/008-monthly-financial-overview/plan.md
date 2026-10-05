# Implementation Plan: Monthly Financial Overview & Medical Bills

**Branch**: `008-monthly-financial-overview` | **Date**: 2026-10-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/008-monthly-financial-overview/spec.md`

## Summary

Introduce income tracking and a per-month financial verdict ("kept this month"), make the selected month a first-class, navigable concept across the whole app, fix a defect that silently discards reimbursements recorded outside their originating month, and replace the medical bill model — which assumes the user always pays the full charge upfront — with a two-payment-method model that reflects how the user's insurer actually works.

The technical approach rests on three findings from the existing codebase:

1. **`MonthlyBudget.baseAvailableAmount` is already a per-month opening balance.** It is stored per `yearMonth` and read by `trueAvailableProvider` as the month's starting figure. Reusing it as the opening balance satisfies FR-006 through FR-011 with no data migration and no change to the constitution's "available amount" concept.
2. **`currentYearMonthProvider` is a single funnel for month scoping.** It has exactly one definition and 12 downstream consumers (`activeBudgetProvider` → expenses, medical, add/edit expense, dashboard). Promoting it to a `StateProvider` makes FR-027 (selected month persists across screens) fall out for free instead of requiring per-screen plumbing.
3. **The linked `Expense` is the correct single source of truth for money impact, but is currently written at the wrong amount.** `MedicalRepository._syncLinkedExpense` always writes `amount = bill.billedAmount`. Making the written amount a function of (payment method, patient share, bill state) resolves the Method A overstatement in FR-042 without introducing a parallel money path — which also satisfies FR-024's "single source" requirement.

## Technical Context

**Language/Version**: Dart 3.x (SDK `>=3.0.0 <4.0.0`), Flutter 3.x

**Primary Dependencies**: `flutter_riverpod` ^2.4.3 (state), `isar` ^3.1.0 + `isar_generator` ^3.1.0 (persistence, codegen), `go_router` ^18.0.2 (routing), `intl` ^0.20.3 (month formatting), `image_picker` ^1.2.3 / `file_picker` ^13.1.0 (FR-047 attachments), `uuid` ^4.2.0 (ids)

**Storage**: Local Isar 3.1 database (offline only, no sync layer). Medical attachments stored as local file paths referenced by the bill.

**Testing**: `flutter_test` / `package:test`. Two established patterns are reused: pure unit tests for arithmetic, and a real-Isar harness (`test/features/medical/repositories/medical_test_harness.dart`) that opens a temporary Isar instance for repository and provider tests.

**Target Platform**: Cross-platform Flutter, Android-first (`compileSdk = 36` per `android/build.gradle.kts`)

**Project Type**: Mobile Application — local-only, offline-first, single device

**Performance Goals**: Month summary recomputes synchronously from already-streamed rows (target < 16 ms); no file or database I/O during widget build; month navigation reuses existing Isar watchers rather than adding new subscriptions

**Constraints**:
- Offline-first — every figure MUST be derivable with no network access (Constitution III)
- Month isolation — no figure from one month may influence another (FR-016), and no balance may carry forward (FR-007)
- Constitution IV's medical clause was amended to v1.2.0 (approved 2026-10-04); its six-step migration plan is binding scope
- Isar 3.1 has no declarative migration API; value inversions (e.g. coverage % → patient share %) cannot be handled by automatic schema migration
- `safeToSpendProvider` has 6 consumers outside the dashboard and MUST NOT be removed, only unmounted from the dashboard (FR-023)

**Scale/Scope**: One local device, one active user profile (id = 1 today, multi-profile keys preserved), roughly 120 addressable months, ~100 expenses per month, 5 screens modified, 1 new feature module, 2 new Isar collections, 1 new collection added to an existing one

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | Evidence |
|---|---|---|
| **I. Cross-Platform & Mobile First** | PASS | Flutter throughout; no platform-conditional logic introduced. Android `compileSdk = 36` already in place. |
| **II. Clean Architecture & Testability** | PASS | New `MonthFinanceRepository` and `MedicalServiceType` collection sit behind repositories; `MonthSummary` is a pure value object with no I/O, making all arithmetic testable without a database. Existing direct-Isar writes in `dashboard_screen.dart` are left untouched to keep scope bounded. |
| **III. Offline-First & Synchronization** | PASS | All reads and writes are local Isar. Month summaries derive from already-watched streams. No network dependency is introduced; `dio` remains used only by the existing exchange-rate client. |
| **IV. Modular Financial Logic & Real-time Availability** | **PASS — amended (v1.2.0)** | The final clause originally stated: *"Medical Bills: Modeled as a special expense… User pays full bill (reduces available), later records reimbursement (increases available)."* FR-042 requires insurer-paid bills to reduce available funds by **only the patient's share**, and FR-051 requires a rejected insurer-paid bill to grow to the **full charge** — neither is expressible under the original wording. The project owner approved the replacement clause on 2026-10-04; it is ratified in `.specify/memory/constitution.md` as **v1.2.0** with the superseded text, rationale and migration plan recorded in its *Amendment Record*. The first four clauses (planned does not reduce, paid reduces, reimbursed increases, cancelled no effect) are unchanged and are reinforced by FR-014 and FR-031–FR-035. |
| **V. Security & Privacy First** | N/A | This feature introduces no new sensitive-data surface and changes no authentication or lock behaviour. Medical amounts remain behind the existing (unimplemented) app-lock boundary; no regression is introduced. |
| **VI. Playful & Modern Design** | PASS | FR-018–FR-021 deliver the "single large primary figure" treatment. FR-019/FR-020 fix colour semantics globally, which strengthens the constitution's requirement for "clear visual distinction between planned, paid, and reimbursed amounts". Dark mode continues to derive from the existing Material theme. |
| **Multi-Currency** | PASS | No change. Per-expense `exchangeRateToPrimary` conversion is preserved; income and opening balances are per-month primary-currency values, consistent with `MonthlyBudget.currency`. |
| **Multi-User Profiles** | PASS | All new records carry `profileId`; the default net salary is stored on `UserProfile`, and per-month values live on `MonthlyBudget` keyed by `yearMonth`. |
| **Performance** | PASS | `MonthSummary` is derived, never persisted (FR-017 is satisfied by retention, not by precomputation), so no new write amplification is added to the hot save path. |
| **Iterative Delivery** | PASS | The five user stories are independently testable per the spec and are sequenced P1 → P5, allowing the money-accuracy stories to ship before presentation work. |

**Gate result: PASS.** The single violation (Principle IV, medical clause) was justified by explicit user instruction, documented, and resolved by the amendment ratified as constitution v1.2.0 on 2026-10-04. Governance's requirements — documentation, approval, migration plan — are satisfied: the amendment record lives in `.specify/memory/constitution.md`, approval is recorded there, and the migration plan is the six-step procedure in `data-model.md` §10. No unresolved violations remain.

### Post-design re-check (after Phase 1)

| Check | Result |
|---|---|
| Does the design keep all money logic outside presentation? | Yes — `MonthSummary` (pure) and `MedicalRepository._syncLinkedExpense` (single write path) own every arithmetic decision; no widget computes a total. |
| Is Principle IV's *first four* clauses still honoured? | Yes — `ExpenseStatus` remains the sole determinant of planned vs paid; `MonthSummary` reads it rather than reinterpreting it. |
| Is Principle IV's *medical clause* satisfied? | Yes — ratified as constitution **v1.2.0** on 2026-10-04. The replacement clause covers both payment methods, immediate impact, all-or-nothing reimbursement, rejection growth, the absence of a deductible, a correctable per-bill patient percentage, service-month ownership, and single-source monthly totals. |
| Does any month influence another? | No — every query is keyed by `yearMonth`; `MonthSummary` takes a single month as input. |
| Is FR-024's single-source requirement met? | Yes — both the dashboard and the Medical tab read `MonthSummary.medicalPaid`. |
| Any unapproved complexity? | No — two new collections and one new feature module, each justified in `research.md`. |

## Project Structure

### Documentation (this feature)

```text
specs/008-monthly-financial-overview/
├── plan.md              # This file (/speckit-plan command output)
├── spec.md              # Feature specification (input)
├── research.md          # Phase 0 output — 16 decisions
├── data-model.md        # Phase 1 output — entities, fields, migrations
├── quickstart.md        # Phase 1 output — validation guide
├── checklists/
│   └── requirements.md  # Spec quality checklist (16/16 pass)
├── contracts/
│   ├── month-summary.md            # Calculation contract (FR-008, FR-012–FR-017)
│   ├── medical-bill-lifecycle.md   # State machine + money impact (FR-036–FR-056)
│   └── dashboard-ui.md             # Layout + colour tokens (FR-018–FR-025)
└── tasks.md             # Phase 2 output (/speckit-tasks command — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/
│   │   ├── monthly_budget.dart          # MODIFIED: opening-balance semantics, netSalaryOverride, openingBalanceConfirmed
│   │   ├── user_profile.dart            # MODIFIED: defaultNetSalary
│   │   ├── medical_bill.dart            # MODIFIED: paymentMethod, patientSharePercent, serviceTypeId, yearMonth, split photos, new state enum
│   │   ├── insurance_profile.dart       # MODIFIED: deductibles + per-year key removed, defaultPatientPercent
│   │   └── medical_service_type.dart    # NEW: user-editable service classification (FR-039, FR-040)
│   ├── database/
│   │   ├── isar_helper.dart             # MODIFIED: register MedicalServiceTypeSchema
│   │   └── schema_migrations.dart       # NEW: version-stamped one-time value migration
│   └── providers/
│       └── selected_month_provider.dart # NEW: month selection state + prev/next/Today (FR-026–FR-030)
├── features/
│   ├── engine/
│   │   ├── month_summary.dart           # NEW: pure per-month report value object
│   │   └── providers/
│   │       ├── month_summary_provider.dart  # NEW: assembles MonthSummary from streams
│   │       ├── true_available_provider.dart # MODIFIED: opening-balance + origin-month reimbursements
│   │       ├── safe_to_spend_provider.dart  # UNCHANGED: retained for expense screens
│   │       └── ...
│   ├── finance/                         # NEW MODULE
│   │   ├── presentation/
│   │   │   ├── net_salary_section.dart      # NEW: default salary + per-month override (FR-001–FR-005)
│   │   │   └── opening_balance_sheet.dart   # NEW: per-month opening balance entry (FR-006–FR-011)
│   │   ├── providers/
│   │   │   └── finance_providers.dart       # NEW: month provisioning, income, completeness
│   │   └── repositories/
│   │       └── month_finance_repository.dart # NEW: MonthlyBudget/UserProfile reads and writes
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── dashboard_screen.dart        # REBUILT: hero kept figure + 4 lines
│   │       ├── month_navigator.dart         # NEW: prev/next/Today control (FR-026)
│   │       └── widgets/month_summary_card.dart # NEW: SC-002 hierarchy guarantee
│   ├── medical/
│   │   ├── presentation/
│   │   │   ├── medical_dashboard.dart       # MODIFIED: deductible UI removed, state labels, month scoping
│   │   │   ├── medical_bill_form.dart       # MODIFIED: payment method, service type, patient %, split photos
│   │   │   ├── medical_detail_screen.dart   # MODIFIED: lifecycle transitions, rejection handling
│   │   │   └── medical_theme.dart           # MODIFIED: FR-019/FR-020 colour tokens
│   │   ├── providers/
│   │   │   └── medical_providers.dart       # MODIFIED: deductible aggregates removed, monthly totals
│   │   └── repositories/
│   │       └── medical_repository.dart      # MODIFIED: amount = f(method, share, state)
│   └── expenses/
│       ├── models/
│       │   └── reimbursement.dart           # MODIFIED: originYearMonth, nullable expenseId
│       └── repositories/
│           └── expense_repository.dart      # MODIFIED: origin-month queries
└── shared/
    └── presentation/
        ├── app_shell.dart                       # UNCHANGED: selected month is provider-scoped, not route-scoped
        └── widgets/month_incomplete_banner.dart # NEW: FR-025 / FR-010 prompt

test/
└── features/
    ├── engine/
    │   ├── month_summary_test.dart              # NEW: pure arithmetic (SC-004, SC-012)
    │   └── reimbursement_attribution_test.dart  # NEW: origin-month crediting (SC-005)
    ├── finance/
    │   └── month_finance_repository_test.dart   # NEW: month isolation, salary override
    ├── dashboard/
    │   └── dashboard_summary_test.dart          # NEW: hero hierarchy, hidden group, colour roles
    └── medical/
        ├── repositories/
        │   ├── medical_test_harness.dart            # MODIFIED: new collection + migration
        │   ├── medical_repository_test.dart         # EXTENDED: payment methods, rejection, service types
        │   └── medical_repository_migration_test.dart # NEW: deductible removal, % inversion, state mapping
        └── providers/
            └── medical_providers_test.dart      # MODIFIED: deductible aggregates removed
```

**Structure Decision**: The existing `lib/core/models` + `lib/features/<domain>` layout is retained — no new architectural layer is introduced. Two decisions are worth stating explicitly:

- **`features/finance/` is a new module** rather than an extension of `settings/`. The net salary is *configured* in Settings but the opening balance and per-month income are *month-scoped records* with provisioning, completeness and repository concerns. Grouping them under `settings/` would mix a profile-level default with per-month records and contradict Constitution II. `net_salary_section.dart` is embedded into the existing `settings_screen.dart`; the repository and providers live in the new module.
- **`features/engine/month_summary.dart` is a plain Dart class, not a provider or a collection.** The constitution's "modular financial logic" principle and FR-017 ("never stored, always recalculated") both require the month report to be a pure derivation. Keeping it free of Isar and Riverpod makes SC-004 verifiable as a plain unit test.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**
>
> The one violation found — Principle IV's medical clause — was resolved by the amendment below, ratified as constitution **v1.2.0** on 2026-10-04. The table is retained as the justification record required by Governance.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| **Principle IV, medical clause** — the constitution states a medical bill means "user pays full bill (reduces available), later records reimbursement". | The user's insurer either bills the hospital directly or refunds in full after the user pays. There is no world in which the user always fronts the full charge. Under the current wording, an insurer-paid $1,000 bill at 20% patient share would overstate spending by $800 — roughly 4× the true cost — on every such bill, corrupting every total the app presents (User Story 2). FR-042 requires only the patient's share to leave funds; FR-051 requires a rejected insurer-paid bill to grow to the full charge. | **Rejected:** keeping one payment method and treating insurer-paid bills as full-payment + full reimbursement. This preserves the constitution text but is arithmetically identical to the rejected Option A the user explicitly declined — the balance dips by $1,000 and returns $800 later, which is exactly the behaviour the user said is wrong. It also fails FR-043 (impact must not wait for a month-end event). **Rejected:** modelling the patient share as a negative expense or a synthetic reimbursement. This keeps the constitution text but fabricates money movements the insurer never made, breaking FR-046's requirement that only real returns credit funds, and double-counts in `money returned`. |
| **Amendment required by Constitution Governance** — satisfied 2026-10-04. Governance states: "Amendments require documentation, approval, and a migration plan if necessary." | Principle IV's medical clause was factally wrong for this user, and the constitution "supersedes all other practices". Shipping FR-042 against the unamended text would have made the codebase non-compliant by construction. | **Rejected:** shipping the medical model and recording the conflict as a known issue. This leaves the constitution asserting a rule the code contradicts, which the Governance section explicitly forbids ("All PRs/reviews MUST verify compliance"). **Rejected:** adding a third payment method to represent insurer-paid bills. FR-041 fixes the count at two and FR-051's growth-on-rejection rule only makes sense for the insurer-paid case; a third method would be an untested fourth concept the user did not ask for. |

### Ratified amendment to Principle IV — constitution v1.2.0

Approved by the project owner on 2026-10-04 and applied to `.specify/memory/constitution.md`, where the superseded text, the reason, the approval and the migration plan are recorded in the *Amendment Record*. The clause now in force:

> **IV. Modular Financial Logic & Real-time Availability** … *(planned does not reduce / paid reduces / reimbursed increases / cancelled no effect — unchanged)* …
> - **Medical Bills**: Modeled as an expense whose effect on available funds depends on the payment method. **(a) Insurer-paid** — the insurer bills the provider directly; only the patient's share reduces available funds, immediately at the moment the bill is entered; no reimbursement is recorded and no payout document is required. **(b) Self-paid** — the full charge reduces available funds immediately; any insurer return increases it as a reimbursement. Reimbursement is all-or-nothing; partial reimbursement MUST NOT be modelled or accumulated. A rejected insurer-paid claim raises the patient's obligation to the full charge; a rejected self-paid claim returns nothing. **No deductible applies.** The percentage the patient is responsible for MUST be recorded per bill and MUST be correctable after entry, with all affected figures updating. Medical spending MUST appear in general monthly totals as an ordinary category, read from a single source so that no two screens can disagree. A medical bill belongs to the month of the service it describes, with a user override. Must clearly show total medical expenses, patient share, reimbursed, and net impact.

Migration plan required by Governance: the six-step data migration in `data-model.md` §10, executed atomically by `lib/core/database/schema_migrations.dart`, together with removal of all deductible UI from `lib/features/medical/presentation/medical_dashboard.dart`.

## Phase 0 → Phase 1 Traceability

| Requirement group | Decisions | Contract | Primary tests |
|---|---|---|---|
| FR-001–FR-005 income | R02, R04 | `month-summary.md` | `month_finance_repository_test.dart` |
| FR-006–FR-011 opening balance, no carryover | R01, R03, R04 | `month-summary.md` | `month_summary_test.dart` |
| FR-012–FR-017 the monthly report | R04, R06, R14 | `month-summary.md` | `month_summary_test.dart` (SC-004, SC-012) |
| FR-018–FR-025 dashboard presentation | R04, R15 | `dashboard-ui.md` | widget tests in `quickstart.md` §5 |
| FR-026–FR-030 month navigation | R03 | `month-summary.md` | `month_finance_repository_test.dart` |
| FR-031–FR-035 reimbursement correctness | R05, R06, R14 | `month-summary.md` | `reimbursement_attribution_test.dart` (SC-005) |
| FR-036–FR-038 no deductible | R12, R13 | `medical-bill-lifecycle.md` | `medical_repository_migration_test.dart` |
| FR-039–FR-040 service types | R10 | `medical-bill-lifecycle.md` | `medical_repository_test.dart` |
| FR-041–FR-051 payment methods | R07, R08, R09 | `medical-bill-lifecycle.md` | `medical_repository_test.dart` (SC-006) |
| FR-052–FR-054 bill states | R09 | `medical-bill-lifecycle.md` | `medical_repository_test.dart` |
| FR-055 service-month ownership | R07 | `medical-bill-lifecycle.md` | `medical_repository_test.dart` |
| FR-056 medical in general totals | R04, R07 | `month-summary.md`, `dashboard-ui.md` | SC-009 cross-check test |