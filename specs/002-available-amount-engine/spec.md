# Feature Specification: Available Amount Calculation Engine

**Feature Branch**: `feature/002-available-amount-engine`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Feature: Available Amount Calculation Engine..."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Daily Pacing & Safe to Spend (Priority: P1)

Users need to see exactly how much they can spend today without accidentally using money planned for upcoming bills.

**Why this priority**: Core value of the "friendly assistant" vibe is preventing user mistakes before they happen.

**Independent Test**: Can be fully tested by creating planned and paid expenses, and observing the updated Daily Pacing and Safe-to-Spend amounts.

**Acceptance Scenarios**:

1. **Given** a user has a $1000 monthly budget, 10 days remaining in the month, and a $200 planned rent expense, **When** they view the dashboard, **Then** they should see a Safe-to-Spend amount of $800 and a Daily Limit of $80/day.
2. **Given** the user then logs a $50 paid grocery expense, **When** they view the dashboard, **Then** their Safe-to-Spend should update to $750 and Daily Limit to $75/day.

---

### User Story 2 - Multi-Currency Smart Normalization (Priority: P2)

Users who travel or make online purchases in foreign currencies need their budget accurately tracked in their primary currency.

**Why this priority**: Essential for accurate budgeting in a multi-currency context, but slightly lower priority than the core single-currency math.

**Independent Test**: Can be fully tested by adding a foreign expense and verifying it converts properly into the primary currency limit.

**Acceptance Scenarios**:

1. **Given** the user is online with a primary currency of USD, **When** they add a 10 EUR expense, **Then** the system automatically fetches the exchange rate and deducts the USD equivalent from their True Available Amount.
2. **Given** the user is completely offline, **When** they add a 10 EUR expense, **Then** the app prompts them to manually enter the exchange rate to apply.

---

### User Story 3 - End of Month Savings Vault Sweep (Priority: P3)

Users need to feel rewarded when they spend less than their budget, rather than just having it roll over opaquely.

**Why this priority**: Gamification element that drives long-term retention.

**Independent Test**: Fast-forwarding the system time to a new month should trigger the sweep and populate the Vault.

**Acceptance Scenarios**:

1. **Given** the user has $150 True Available at 11:59 PM on the last day of the month, **When** the new month begins, **Then** $150 is added to their lifetime Savings Vault and the new month starts fresh.
2. **Given** the user has $0 True Available at the end of the month, **When** the new month begins, **Then** the Savings Vault remains unchanged.

---

### Edge Cases

- What happens when a user logs an expense that exceeds their Safe-to-Spend? (Status changes to `Critical`, Daily limit goes to $0).
- How does the system handle a reimbursement that exceeds the original expense amount? (System should cap the reimbursement or reject the overage to prevent artificial budget inflation).
- How does the system handle negative monthly budget setups? (Rejected at the source).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST compute `trueAvailable` as: `monthlyAvailableAmount - sum(paidExpenses) - sum(paidMedicalBills) + sum(reimbursements)`.
- **FR-002**: System MUST compute `safeToSpend` as: `trueAvailable - sum(plannedExpenses)`.
- **FR-003**: System MUST compute `dailyLimit` as: `max(0, safeToSpend / daysRemainingInMonth)`.
- **FR-004**: System MUST ONLY reduce `trueAvailable` for items in the `Paid` state.
- **FR-005**: System MUST ONLY reduce `safeToSpend` (not `trueAvailable`) for items in the `Planned` state.
- **FR-006**: System MUST ignore items in the `Cancelled` state for all calculations.
- **FR-007**: System MUST automatically fetch real-time exchange rates for multi-currency logging if an active internet connection is available.
- **FR-008**: System MUST gracefully fall back to requesting manual exchange rate entry when offline.
- **FR-009**: System MUST prevent a reimbursement from exceeding its parent source item's original amount.
- **FR-010**: System MUST expose a Budget Health Status enum (`Healthy` > 20%, `Warning` 0-20%, `Critical` <= 0 based on `safeToSpend`).
- **FR-011**: System MUST sweep any positive `trueAvailable` balance into a global "Savings Vault" upon the transition to a new calendar month.

### Key Entities *(include if feature involves data)*

- **UserProfile / MonthlyBudget**: Source of the original `monthlyAvailableAmount` and primary currency.
- **Expense / MedicalBill**: Records with an `amount`, `currency`, and `status` (Planned, Paid, Cancelled).
- **Reimbursement**: Record linked to an expense/bill that returns funds.
- **SavingsVault**: A global accumulator tracking total lifetime unspent swept funds.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Calculation functions execute and emit updated states in under 16ms to ensure 60fps UI updates.
- **SC-002**: Foreign currency expenses fetch their exchange rate and update the budget within 2 seconds on a standard 4G connection.
- **SC-003**: 100% of calculation functions are covered by unit tests (verifiable offline deterministic math).
- **SC-004**: Users successfully log foreign currency offline without app crashes 100% of the time.

## Assumptions

- Users have intermittent but generally reliable internet access for fetching exchange rates.
- Exchange rate APIs used will not be aggressively rate-limited for standard user logging volumes.
- Riverpod (or chosen state management) can handle reactive recalculations efficiently without memory leaks.
- Timezone changes do not negatively impact the "End of Month" sweep (local device time is the source of truth).
