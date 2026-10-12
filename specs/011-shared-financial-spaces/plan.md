# Implementation Plan: Multi-User Profiles & Shared Financial Spaces (Unified)

**Branch**: `011-shared-financial-spaces` | **Date**: 2026-10-09 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/011-shared-financial-spaces/spec.md`

## Summary

Give BudgetBuddy true multi-user support: multiple independent personal profiles on one device, plus **shared spaces** (rooms) where a **whole financial month** — budget, income, every expense, every medical bill, reimbursements, dashboard — is owned and managed together with role-based access (Owner / Editor / Viewer). Whole-month sharing is implemented as **Move-not-copy**: a month lives in exactly one context (a personal profile *or* a shared space), and moving it re-points its `MonthlyBudget` plus all its money rows and medical-directory references in one atomic write transaction. A single **Context Router** resolves "which room am I in" so every screen recomputes within one frame on switch, and every scoped query walks through it (FR-004). Income splits into **"My income"** (existing personal pot, labels only) and **"Our income"** (new shared pot with default + per-month override, whole minor units). Closed-month immutability, device-global month seals and the single conversion path are inherited unchanged (FR-012), and the savings vault stays personal-only (FR-017). An Analytics placeholder rides the Context Router into both rooms and computes nothing (FR-015).

Technical approach: extend the existing Isar store with two collections (`SharedSpace`, `SharedMember`) and schema steps 12–13 (additive nullable context columns on `MonthlyBudget`, `Expense`, `Reimbursement`, `MedicalBill` and the medical-directory rows; ownership backfill step); promote `activeProfileProvider` from `profiles.first` to an explicit selection; add an active-space provider and a `budgetContextProvider` that all engines/screens resolve; introduce a data-layer `SpaceAccessGuard` that enforces FR-003/FR-005 no matter what the UI shows; re-point the month-finance and engine repositories to context-scoped queries; add spaces feature UI (switcher, create/invite, members, move month, delete-space flow, My/Our income settings) and the Analytics placeholder; extend the real-Isar test harnesses to the new schema and add context, move and role-enforcement matrices. Git 🛑 hands-off – user pushes.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.6 stable (matches features 009/010 baseline).

**Primary Dependencies**: Riverpod (state), Isar 3.1.0 (local DB, `build_runner` codegen), Dio/intl (unchanged, rate path untouched). **No new packages required.**

**Storage**: Isar 3.1.0, local-only. Two new collections (`SharedSpace`, `SharedMember`); additive nullable columns on `UserProfile`, `MonthlyBudget`, `Expense`, `Reimbursement`, `MedicalBill`, `InsuranceProfile`, `FamilyMember`, `MedicalProvider`, `MedicalServiceType`; app-level steps in `lib/core/database/schema_migrations.dart` (schemaVersion 11 → 13). Seals/rates stay device-global (unchanged).

**Testing**: `flutter_test` (357 test cases in 34 files, all green as of 2026-10-09); new unit + widget + real-Isar tests for context isolation, month move, role enforcement, shared income, migration backfill; real-Isar harnesses (`medical_test_harness.dart`, `rate_test_support.dart`) gain the two new collections. CI `.github/workflows/flutter_validation.yml` already runs `flutter test` (added in 010).

**Target Platform**: Android first; iOS/web/desktop later (Constitution I).

**Project Type**: Mobile app — single Flutter project with `lib/`, `test/`, platform directories.

**Performance Goals**: context switch recomputes every screen within 1 frame (< 1 s device (SC-002)), zero DB writes on switch beyond the active-context marker; move runs in one writeTxn; every read stays on watched streams (no new I/O on the fold path).

**Constraints**: offline-first (Constitution III) — invites, moves, switching, all ops fully local; money in whole minor units for every NEW field while the legacy major-unit profile figures stay untouched (`UserProfile.monthlyAvailableAmount`, `defaultNetSalary` are `double` and not changed by this feature); exactly-one-context invariant enforced at the data layer and tested (FR-003/SC-005); sealed past months never modified for any role (FR-012); vault personal-only (FR-017).

**Scale/Scope**: single device, N profiles, M spaces; 4 currencies; month granularity (hundreds of rows/month). Spans ~10 source areas: models, schema/migrations, context routing, month-finance + engine re-scoping, spaces feature (repositories + guard + UI), settings, onboarding, dashboard/analytics placeholder, harnesses/tests.

**Unknowns**: resolved in research.md (R1–R8). Notable: medical-directory scoping inside a shared space (R3), income pot currency/unit carry across a move (R4), move atomicity/backfill (R5), and the context-scoping cascade (R8).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Gate (Constitution) | Verdict | Evidence |
|---|---|---|---|
| I | Cross-platform & mobile-first (Flutter, Android first) | ✅ PASS | Flutter unchanged; work is pure Dart/Isar/Riverpod; no platform-specific code |
| II | Clean Architecture & testability (Riverpod; evolve without breaking financial logic) | ✅ PASS | Context Router is a provider seam; role guard + month-move are pure repository/domain services; one set of rules enforced at the data layer; shipped with unit/widget/Isar tests |
| III | Offline-first & sync-ready | ✅ PASS (strengthened) | All 011 operations are local-only; zero network dependence; multi-profile/shared spaces design for local collaboration today, sync-ready later |
| IV | Modular financial logic (planned/paid/reimbursed/cancelled; medical share rules; single source of truth) | ✅ PASS | Money impact math untouched — rows are re-scoped, not re-computed; insurance percentage still applied in the bill's own currency; one conversion/formatting path inherited from 010 |
| V | Security & privacy first | ✅ PASS | Role gates enforced at the data layer; no PII leaves the device; device auth unchanged |
| VI | Playful & modern design | ✅ PASS | Switchers/sheets follow existing Material patterns; spaces get emoji avatars per spec; theme/dark-mode inherited |
| A1 | Multi-Currency (≥ HUF/USD/CAD/EUR; primary currency; summaries in primary via fetched rates) | ✅ PASS | Shared space gets its own currency; conversion/seals untouched and reused |
| A2 | Multi-User Profiles | ✅ PASS (direct implementation) | This is the constitutional constraint's core feature: independent profiles plus shared rooms |
| A3 | Performance (lightweight, fast) | ✅ PASS | Context switch = single provider state write + already-watched stream rebuilds; no new queries per frame |
| D1 | Iterative delivery & feature encapsulation | ✅ PASS | Phased: models+migration → context router → guard+repos → space UI → settings/onboarding → tests |

**Gate result: PASS, no violations → Complexity Tracking left empty.**

*Post-design re-check (after Phase 1):* data-model, contracts and quickstart introduce no new architectural surface (no new projects, no byzantine layers); MonthRateSeal/LiveRateSet stay device-global (not context-scoped — correct, rates are market data not user money); medical-directory scoping is the one judgment call, justified in R3 with data-layer enforcement and tests. **Still PASS**, no violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/011-shared-financial-spaces/
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output (R1–R8)
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── context-router.md         # the single route: active profile/space/month resolution (FR-004)
│   ├── month-move-lifecycle.md   # Move semantics + space deletion + ownership transfer state machine
│   ├── space-roles.md            # Owner/Editor/Viewer enforcement at the data layer (FR-005/SC-005)
│   └── shared-income.md          # My/Our income pots + carry-on-move conversion rule (FR-008/009)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/                  # UserProfile +avatar/lastActiveAt; NEW: shared_space.dart, shared_member.dart (+ SharedMemberRole enum)
│   │                            # MonthlyBudget +profileId/sharedSpaceId/sharedIncomeOverride; Expense/Reimbursement/MedicalBill +sharedSpaceId
│   │                            # InsuranceProfile/FamilyMember/MedicalProvider/MedicalServiceType +sharedSpaceId
│   ├── database/                # schema_migrations.dart — NEW steps 12 (additive) + 13 (ownership backfill); isar_helper.dart registers 2 new collections
│   └── providers/               # active_profile_provider.dart — explicit selection, drop profiles.first;
│                                # NEW: active_space_provider.dart (activeSpaceId/activeSpace), budget_context_provider.dart (single Context Router)
├── features/
│   ├── spaces/                  # FEATURE: repositories (spaces_repository, space_role_guard, month_move_operations) + presentation (switcher, create/invite/members, move dialog, delete-space flow)
│   ├── finance/                 # month_finance_repository — context-aware ensureMonth/getMonth/save ops; shared income resolution; net_salary_section labelled "My income" + NEW "Our income" section
│   ├── engine/                  # true_available/month_summary/safe_to_spend/monthly expenses/reimbursements + medical — re-pointed through budgetContextProvider; INCOME resolution per pot
│   ├── settings/                # NEW: ProfileSwitcherSection, SpaceSettingsSection (roles, members, transfer/delete); NetSalarySection label → "My income"
│   ├── dashboard/               # NEW: AnalyticsPlaceholderCard mounted on the shared dashboard list (both contexts)
│   ├── budget_setup/            # onboarding: create first profile + OPTIONALLY a first shared space; drop the "keep id = 1" exclusivity for new profiles
│   └── medical/                 # medical directory providers/repository — context-scoped queries + guard
└── shared/presentation/widgets/ # NEW: analytics_placeholder_card.dart

test/
├── core/database/               # migration steps 12/13 (real-Isar harness, ownership backfill, isolation)
├── features/spaces/             # space repo, role guard matrix, month move lifecycle, delete/transfer, invitations
├── features/engine/             # context isolat ion + income-pot independence over the router
├── features/settings/           # profile switcher + shared-income settings widget tests
├── features/dashboard/          # analytics placeholder in both contexts
└── harnesses                    # medical_test_harness + rate_test_support gain the 2 new collections
```

**Structure Decision**: Single-project Flutter layout (existing, unchanged). The feature is encapsulated behind four seams: the **Context Router** provider (one route for all scoped reads/writes), the **space domain** (collections, repository, role guard, move operations), the **spaces feature UI** (switcher + management flows), and **context-aware settings/onboarding**. Existing feature folders (finance, engine, medical, dashboard, settings) are re-pointed through the router rather than duplicated — no screen clone, one set of rules.

## Complexity Tracking

No constitution violations to justify — table intentionally empty.