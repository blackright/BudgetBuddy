# Feature Specification: Multi-User Profiles & Shared Financial Spaces (Unified)

**Feature Branch**: `[011-shared-financial-spaces]`

**Created**: 2026-10-09

**Status**: Draft

**Input**: User description: "Multi-User Profiles & Shared Financial Spaces (Unified) — whole-month sharing with roles (Owner/Editor/Viewer); Move a complete month from personal into a shared space; My income / Our income pots; space-level sharing that keeps going into future months; context-aware Analytics placeholders (real Analytics deferred)."

## Purpose

Let couples, families, roommates and partners use BudgetBuddy on one device with full separation: several independent personal profiles, plus shared spaces where a **whole financial month** — budget, income, every expense, every medical bill, reimbursements, dashboard — is managed together with role-based access. Personal and shared money can never cross. Switching between any profile and any shared space is instant and offline-first, and the shipped multi-currency promises ("the past never changes") hold identically in both worlds.

## Clarifications

### Session 2026-10-09

- Q: Should the savings vault — the only money feature beyond expenses, medical bills and reimbursements — be explicitly excluded from shared spaces in this feature? → A: Yes — the vault stays personal-only; shared spaces cover monthly budgets, expenses, medical bills and reimbursements, and FR-003 is scoped to those records.
- Q: When a space is deleted, should the Owner keep any of its months, or do all shared months go away with the space? → A: Both A+B — all shared months are removed atomically with the space, but the deletion flow first prompts the Owner to move any month back to a personal profile or to delete it, so an accidental deletion cannot silently destroy history.
- Q: After the Owner transfers ownership to another member, do they automatically become an Editor, or can they choose to leave the space at the same time? → A: B — on transfer, the former Owner becomes an Editor and can either stay and keep working in the space or leave afterwards if they wish.
- Q: When an Editor adds an expense or bill in a shared month, must someone else approve it before it counts toward the shared totals — or do entries apply immediately like a personal month? → A: A — no approval workflow; entries apply immediately to the shared totals the moment an Editor saves them, exactly like a personal month.
- Q: When a viewer or editor first opens a shared space, do they need to be actively added by the Owner, or can they join the space themselves? → A: A — membership is invite-only; only the Owner invites profiles and only invited profiles can join a space.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - I am my own profile (Priority: P1)

As a user, I can create and switch between several personal profiles on one device, each with its own name, avatar, main currency, income, font and theme — the dashboard instantly shows that profile's data and nothing else.

**Why this priority**: Independent multi-profile support is the base layer of the whole feature; without it there is no clean seam between "my money" and "our money".

**Independent Test**: Create a second profile, enter different expenses and a different main currency in each, switch between them, and verify every screen shows only the active profile's data within one frame.

**Acceptance Scenarios**:

1. **Given** two personal profiles with different data, **When** I switch from profile A to profile B, **Then** the dashboard, expenses, medical bills and currency all show profile B's data and none of A's.
2. **Given** a personal profile, **When** it is assigned its own avatar, main currency, income, font and theme, **Then** those settings persist and render only inside that profile.
3. **Given** profile A is active, **When** I add an expense, **Then** it is attributed to A and is never visible or used by any other profile.

---

### User Story 2 - I create a shared space and invite people (Priority: P1)

As a user, I create a shared space (name + emoji avatar), set its "Our income" and shared currency, and invite local profiles as members with a role (Owner / Editor / Viewer); the creator becomes Owner.

**Why this priority**: This is the entry point to collaboration; roles and the owner/member rules determine who can do what everywhere else.

**Independent Test**: Create a space, invite a second profile as Viewer, and verify the Owner can edit space settings while the Viewer cannot.

**Acceptance Scenarios**:

1. **Given** a fresh shared space, **When** the Owner sets its name, avatar, currency and "Our income", **Then** these exist independently of every member's personal values.
2. **Given** a shared space, **When** the Owner invites profiles and assigns roles, **Then** the creator is Owner, and roles persist.
3. **Given** an Owner, **When** only one Owner exists and tries to leave, **Then** leaving is blocked until ownership is transferred or the space is deleted; a space never has zero Owners.
4. **Given** a member who is not the Owner, **When** they attempt to rename the space, change roles, remove a member or delete it, **Then** the action is refused.

---

### User Story 3 - I bring my existing month in (whole-month sharing) (Priority: P1)

As a user who already has a month with expenses, medical bills and reimbursements entered, I move that whole month into the shared space and George (per his role) sees or manages it.

**Why this priority**: This is the heart of the feature — sharing the full month, not line-by-line, with one single copy that can never drift.

**Independent Test**: Move an existing month with mixed expenses, medical bills and reimbursements into a space, then add an expense as an Editor and confirm both people saw the same updated month throughout.

**Acceptance Scenarios**:

1. **Given** a complete personal month (budget/income, expenses, medical bills, reimbursements), **When** I move it into a shared space, **Then** the whole month becomes the space's month as one single copy.
2. **Given** a moved month, **When** it carries a recorded income figure, **Then** that figure carries over and is reported under the space's income from then on.
3. **Given** a month brought into a space, **When** any member edits it within their role, **Then** the single copy updates for everyone instantly — no second version exists.
4. **Given** a personal month already in a space, **When** I try to move another month with the same year-month into that space, **Then** the move is blocked with a clear message (a month lives in exactly one space).

---

### User Story 4 - Roles decide what each person can do (Priority: P1)

Members access the space by role: **Viewer** follows the money read-only; **Editor** views and edits the shared money; **Owner** also manages people and the space.

**Why this priority**: The whole collaboration safety model; enforcement must hold at the data layer, not just the UI.

**Independent Test**: As a Viewer attempt every edit action; as an Editor attempt every people-management action; verify both are refused and no data changes.

**Acceptance Scenarios**:

1. **Given** a Viewer, **When** they open the space's months, expenses, medical bills and currency views, **Then** they can see everything but no add/edit/delete control is offered **and** no write path grants one.
2. **Given** an Editor, **When** they add or update a shared expense, medical bill, reimbursement or this month's income, **Then** the change persists; when they try to manage members, roles or the space, **Then** the action is refused.
3. **Given** the Owner, **When** any Owner-only action is performed, **Then** it succeeds, and these rules are enforced by the same code that enforces all rules — not only by hiding buttons.
4. **Given** any sealed (past) month, **Then** no role can modify it; the past stays frozen for everyone.

---

### User Story 5 - The space keeps going forward (Priority: P2)

The sharing unit is the space, not each month: at creation I choose how much past to bring in (this month only / this year so far / everything), and every future month appears in the space automatically — no re-sharing each month.

**Why this priority**: Sharing must be sustainable; nobody wants to re-invite or re-share month after month, and future months must keep the same sealed-history guarantees.

**Independent Test**: Create a space bringing in "this year so far", then let a new month begin; verify the new month appears in the space without any action and behaves like a personal month would.

**Acceptance Scenarios**:

1. **Given** a space created with "this month only", **When** a new calendar month begins, **Then** it appears in the space automatically.
2. **Given** a space created with "this year so far", **When** I inspect the space, **Then** all months of the current year are present and older months are absent.
3. **Given** a space created with "everything", **When** I inspect the space, **Then** all existing history is present.
4. **Given** a closed shared month, **When** it is viewed later, offline or in any currency, **Then** its totals are identical to how the same month behaved in a personal context and its rates come from the same sealed source.

---

### User Story 6 - Analytics placeholder (deferred to the Analytics feature) (Priority: P2)

Analytics is a later feature. This specification ships a context-aware placeholder only, for both personal and shared contexts, so real analytics can be fully implemented later without touching this feature's structure again.

**Why this priority**: The context routing this feature introduces must exist for both rooms from day one, or a future Analytics feature would have to retrofit it per room.

**Independent Test**: Open the dashboard in a personal profile and then in a shared space and verify a visible placeholder section appears in both, always matching the active context, and computes nothing.

**Acceptance Scenarios**:

1. **Given** a personal profile, **When** I open the dashboard, **Then** a visible Analytics placeholder section is present.
2. **Given** a shared space, **When** I open its dashboard, **Then** the placeholder section is present and distinct from the personal one's data.
3. **Given** either context, **When** I switch to another context, **Then** the placeholder re-renders with the newly active context and no numbers from the previous context linger.

---

### Edge Cases

- **Last Owner leaving**: leaving is blocked until ownership is transferred or the space is deleted; a space never has zero Owners. On transfer the former Owner becomes an Editor and may stay or leave.
- **Deleting a space**: deleting a space MUST first ask the Owner per month — move it back to a personal profile or delete it — and then remove the space's remaining rows atomically; member profiles are untouched.
- **Deleting a personal profile**: deletion is blocked when it is the last profile, and blocked when the profile is the sole Owner of a space (until ownership is transferred or the space is deleted); the user confirms by typing the profile's name after seeing what will be deleted, and the active context falls back to a surviving profile if the deleted one was active.
- **Moving a month that already exists in the target space**: blocked with a clear message; a month lives in exactly one space.
- **Moving a sealed past month**: allowed; moving never modifies stored amounts or sealed rates — only which room the month belongs to.
- **Removing a member who entered data**: nothing is orphaned — rows belong to the space, not the member.
- **Irregular shared income months** (bonus, holiday, unpaid stretch): handled by the per-month income override inside the shared space, same as personal months today.
- **Switching context mid-entry**: the in-progress form and the active context resolve to the same room; a partial personal entry is never written into a shared space.
- **First launch / no profile yet**: onboarding creates the first profile; it may also create a shared space immediately.
- **Offline invites**: invites are local-only by definition; nothing depends on the network. Only the Owner can invite; a profile never joins a space on its own.
- **Unknown exchange-rate situation in a shared space**: identical handling to personal — values shown with the shared "unreliable/unavailable" label, never a fabricated 1:1 rate.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support any number of personal profiles; every profile MUST have its own name, avatar, main currency, income, font, theme and fully isolated money data.
- **FR-002**: A shared space MUST own a name, an emoji avatar, a shared currency, a shared default income and a creation timestamp, all independent of every member's personal values. Membership is invite-only: only the Owner invites profiles, and only invited profiles can join.
- **FR-003**: Every financial record covered by this feature — monthly budgets, expenses, medical bills and reimbursements — MUST belong to exactly one context, a personal profile **or** a shared space, never both, never neither; the savings vault stays personal-only, and this rule MUST be enforced at the data layer and covered by tests.
- **FR-004**: All screens MUST resolve the active context through one single route, so switching contexts recomputes every screen within one frame and no query can stumble into another context's data.
- **FR-005**: Shared-space access MUST be role-based with exactly three roles — Owner, Editor, Viewer — and membership MUST gate every shared write; Owner-only actions MUST be enforced at the data layer, not only hidden in the UI.
- **FR-006**: Each space member MUST have a role and a join date; the creator MUST become Owner; a space MUST always have at least one Owner.
- **FR-007**: A month's budget, income figure, expenses, medical bills and reimbursements MUST move together as one unit from a personal profile into a shared space — a move, never a copy — leaving other personal months untouched.
- **FR-008**: A moved month MUST keep its recorded income figure and MUST report it under the shared space's income from then on.
- **FR-009**: Income MUST exist as two separate pots — the profile's default income plus a per-month override for personal months, and the space's default income plus a per-month override for shared months — and the two MUST never influence each other.
- **FR-010**: At space creation the Owner MUST choose how much past to bring in: this month only, this year so far, or everything; while a year-month already exists in the target space, the move MUST be blocked.
- **FR-011**: From creation onward, every new month MUST appear in the shared space automatically, without re-sharing, and MUST carry the same sealed-history guarantees as personal months.
- **FR-012**: Closed months MUST remain immutable for every role in every context, using the same device-global sealed rate set, with zero new conversion behaviour.
- **FR-013**: A shared space's medical bills MUST follow the established insurance lifecycle (insurer-paid / self-paid, patient share, states) and its reimbursements MUST credit the shared space.
- **FR-014**: A member MUST be able to leave at any time; an Owner MUST transfer ownership or delete the space before leaving; on transfer, the former Owner MUST become an Editor and MAY then stay or leave; deleting a space MUST first prompt the Owner per month — move it back to a personal profile or delete it — then remove the space's remaining rows atomically while leaving member profiles intact.
- **FR-015**: A visible Analytics placeholder MUST be present on the dashboard in both personal and shared contexts, MUST follow the active context on every switch, MUST compute no numbers in this feature, and MUST defer all real content to the separate Analytics feature.
- **FR-016**: The app MUST remain fully functional offline for every operation in this feature, including moving months, inviting members and switching contexts.
- **FR-017**: The savings vault MUST remain personal-only; shared spaces MUST NOT offer or accept vault data in this feature.
- **FR-018**: Shared-space entries MUST apply immediately with no approval step — an Editor's saved expense, bill or reimbursement updates the shared totals at once, exactly as in a personal month.
- **FR-019**: A user MUST be able to permanently delete a personal profile. Deletion MUST remove all of that profile's personal records — monthly budgets, expenses, reimbursements, medical bills, insurance/family/provider/service-type rows and the savings vault — and its space memberships, in one atomic operation, while leaving shared-space rows and every other profile's rows untouched (shared money belongs to the space, not the member). Deletion MUST be refused when it would leave the app with zero profiles or leave a shared space with no Owner; when the deleted profile is the active one, the active context MUST move to a surviving profile.

### Key Entities *(include if feature involves data)*

- **UserProfile**: the app's user — extended with an avatar (emoji) and a last-active timestamp; keeps its main currency, income, font, theme and personally-scoped money.
- **SharedSpace**: one collaboration room — name, emoji avatar, shared currency, shared default income (whole minor units), creation timestamp; owns its own months and money.
- **SharedMember**: the link between a profile and a space — which space, which profile, which role (Owner / Editor / Viewer), when joined.
- **MonthlyBudget**: one month's budget within one context — its income figure (default or override) and its display-only convert-to currency; unique per (context, year-month).
- **Expense**, **MedicalBill**, **Reimbursement**: money records — each scoped to exactly one context (personal or shared), keeping every amount, currency, status and insurance behaviour already defined.
- **SavingsVault**: remains personal-only in this feature; not shared, not accepted by shared spaces (FR-017).
- **MonthRateSeal** / **LiveRateSet**: the device-global sealed and live exchange-rate sets, shared by every context (unchanged by this feature).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Personal rows of any profile are unreadable from every other profile and every shared space in 100% of cross-context tests.
- **SC-002**: Switching between any profile and any shared space updates every screen within 1 second and changes no stored record other than the marker of the active context.
- **SC-003**: Upgrading an existing installation leaves every stored amount, seal and month total byte-identical, and assigns every existing month to the active personal profile.
- **SC-004**: A shared space's closed months behave exactly like personal months: offline-viewable, immutable, re-renderable in any currency using only the device-global seals.
- **SC-005**: No write path permits a non-member write, a member-only Owner action, or a record with both contexts set — enforced and tested at the data layer.
- **SC-006**: A moved month appears in exactly one space, keeps its income and numbers, and its pre-move totals are identical before and after the move.
- **SC-007**: The personal income and the shared income resolve independently per context in 100% of months, and a moved month reports its income under the shared space's pot.
- **SC-008**: The Analytics placeholder is visible in both contexts immediately after any context switch and computes nothing.
- **SC-009**: Deleting a personal profile leaves zero rows of that profile in any collection and removes only its memberships, never removing a shared row or another profile's row — verified by tests; deletion is refused for the last profile and for a sole space Owner.

## Assumptions

- Local persistence remains the existing on-device database and its migration discipline; this feature adds collections and columns only through numbered additive upgrade steps.
- Money stays in whole minor units for every new field; the legacy major-unit figure on the profile is untouched by this feature.
- The shared sealed/live exchange-rate sets are device-global market data — a shared space never captures its own separate rate splits.
- Invites are local-only in this iteration: invite an existing profile on the same device or create a new one.
- The personal income columns are kept as they are; only the user-facing labels change to "My income" and "Our income".
- Analytics is out of scope: this feature ships placeholders only; real content lands with the Analytics feature and consumes the same active-context route and single conversion path.
- A "month" means the calendar month, matching how monthly budgets and medical service months already behave.
- The savings vault is personal-only by decision (2026-10-09); sharing it out of scope of this feature.