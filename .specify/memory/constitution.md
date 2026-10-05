<!-- Sync Impact Report
Version: 1.1.0 → 1.2.0
Added Sections: Features for Initial Versions, Platform Data & Security
Amended: Core Principle IV (medical clause) — see "Amendment Record"
Removed Sections: None
Deferred Intents: 
- Create/edit/delete expenses (including medical bills and planned expenses)
- Basic categories (food, rent, medical, transport, subscriptions, etc.)
- Per-month and per-category summaries
- Simple dashboard showing available amount, total planned, total paid, total reimbursed
- Key charts (expenses per category, per month)
- Future roadmap features (rich charts, budget planning, notifications, AI insights, export/import)
-->
# BudgetBuddy Constitution

## Core Principles

### I. Cross-Platform & Mobile First
The app MUST be built as a cross-platform Flutter application, prioritizing Android for initial development. The design and structure MUST scale gracefully to other platforms (iOS, web, desktop) in the future.

### II. Clean Architecture & Testability
The architecture MUST use a scalable, testable architecture (Clean Architecture) with state management (Riverpod or Bloc). The app MUST be designed to evolve version by version, adding features like advanced analytics, AI insights, and richer dashboards without breaking the core financial logic.

### III. Offline-First & Synchronization
The application MUST be fully functional offline; all core features MUST function without the internet. Data MUST be stored locally by default. Cloud synchronization is optional and user-controlled, but the architecture MUST fully support multi-device sync when enabled.

### IV. Modular Financial Logic & Real-time Availability
Users have an "available amount" representing money they can spend. Core logic strictly dictates:
- **Planned**: Do NOT reduce the available amount until marked paid.
- **Paid**: Reduces available amount.
- **Reimbursed**: Increases available amount.
- **Cancelled**: No effect.
- **Medical Bills**: Modeled as an expense whose effect on available funds depends on the payment method. **(a) Insurer-paid** — the insurer bills the provider directly; only the patient's share reduces available funds, immediately at the moment the bill is entered; no reimbursement is recorded and no payout document is required. **(b) Self-paid** — the full charge reduces available funds immediately, and any insurer return increases it as a reimbursement. Reimbursement is all-or-nothing; partial reimbursement MUST NOT be modelled or accumulated. A rejected insurer-paid claim raises the patient's obligation to the full charge; a rejected self-paid claim returns nothing. **No deductible applies.** The percentage the patient is responsible for MUST be recorded per bill and MUST be correctable after entry, with all affected figures updating. Medical spending MUST appear in general monthly totals as an ordinary category, read from a single source so that no two screens can disagree. A medical bill belongs to the month of the service it describes, with a user override. Must clearly show total medical expenses, patient share, reimbursed, and net impact.

### V. Security & Privacy First
Access to the application MUST be secured using local device authentication (native phone PIN and biometrics like fingerprint/face). Sensitive data MUST NOT be visible until authenticated. The design MUST account for future encryption of local data.

### VI. Playful & Modern Design
The app MUST feel like a playful personal assistant—friendly and encouraging but serious about money. The UI MUST be clean, modern, and fluent (Material You / contemporary patterns), featuring strong usability and dark mode support. There MUST be a clear visual distinction between planned, paid, and reimbursed amounts.

## Additional Constraints

- **Multi-Currency**: The system MUST support at least HUF, USD, CAD, and EUR. Users can set a primary currency, but individual expenses can be in different currencies. Dashboards MUST show summaries in the primary currency using configurable/fetched exchange rates.
- **Multi-User Profiles**: The application MUST support multiple user profiles on the same device. Each profile MUST have its own available amount, expenses, and settings.
- **Performance**: The app MUST remain lightweight, fast, and user-friendly.

## Development Workflow

- **Iterative Delivery**: Features MUST be designed for iterative, version-by-version expansion.
- **Feature Encapsulation**: Complex features (Dashboards, Charts, Monthly Views, Analytics) MUST be built incrementally and adhere to the architectural guidelines.

## Governance

This constitution supersedes all other practices for the BudgetBuddy project. Amendments require documentation, approval, and a migration plan if necessary. All PRs/reviews MUST verify compliance with these core principles and architecture rules. Complexity MUST be justified.

## Amendment Record

### v1.2.0 — Core Principle IV, medical clause (2026-10-04)

**Superseded text**: "Medical Bills: Modeled as a special expense. Insurance default coverage is 80% (configurable per bill). User pays full bill (reduces available), later records reimbursement (increces available)."

**Reason**: The prior clause assumed the user always fronts the full charge. Many insurers instead bill the provider directly and the patient settles only their share at the hospital. Under the prior text, a $1,000 bill at 20% patient share would overstate spending by $800 — roughly 4× the true cost — on every such bill, corrupting every total the application presents. The clause also permitted only one payment method and provided for no deductible-free policy.

**Approved by**: project owner, 2026-10-04. Approved as part of feature `008-monthly-financial-overview` (`specs/008-monthly-financial-overview/`).

**Migration plan**: `specs/008-monthly-financial-overview/data-model.md` §10, six idempotent steps executed atomically by `lib/core/database/schema_migrations.dart`:
1. Clear stored deductible values from medical settings.
2. Invert coverage percentage into patient-share percentage on every bill and default.
3. Map legacy claim states onto the five-state bill lifecycle.
4. Backfill reimbursement origin months from their target expenses.
5. Backfill bill owning months from service dates.
6. Mark pre-existing monthly budgets as having a confirmed opening balance.

**Unaffected**: the first four clauses of Principle IV — planned does not reduce available, paid reduces it, reimbursed increases it, cancelled has no effect — are unchanged and remain in force.

---

**Version**: 1.2.0 | **Ratified**: 2026-10-04 | **Last Amended**: 2026-10-04
