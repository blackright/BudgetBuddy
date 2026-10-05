# Feature Specification: Unified Reimbursements

**Feature Branch**: `[009-unified-reimbursements]`

**Created**: 2026-10-05

**Status**: Draft

**Input**: User description: "1,2,3" and "Feature Specification: Reimbursements (Unified)"

## Purpose
Provide a complete system for recording reimbursements for both expenses and medical bills. This module ensures correct financial adjustments, enforces validation rules, and integrates tightly with availableAmount calculation, while supporting multi-event history, note/source tracking, and cross-currency conversions.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log a Simple Reimbursement for an Expense (Priority: P1)

As a user, I want to record that I was reimbursed for a standard expense so that my available amount accurately reflects that the money has returned to me.

**Why this priority**: General expense reimbursement is a core missing feature that brings immediate parity with medical bill tracking.

**Independent Test**: Can be fully tested by creating an expense, logging a reimbursement for the full amount, and verifying that the `availableAmount` increases by that exact amount and the expense status changes to `reimbursed`.

**Acceptance Scenarios**:

1. **Given** a paid expense of 100 USD, **When** the user logs a reimbursement of 100 USD, **Then** the expense status updates to "reimbursed" and the available budget increases by 100 USD.
2. **Given** a planned expense, **When** the user attempts to log a reimbursement, **Then** the system rejects it because source not paid.

---

### User Story 2 - Partial and Multi-Event Reimbursements (Priority: P1)

As a user, I want to log multiple partial reimbursements against a single expense or medical bill (with notes) so I can accurately track installments or partial claim approvals over time.

**Why this priority**: Reflects real-world scenarios where people pay back in chunks or insurance takes multiple steps.

**Independent Test**: Can be tested by logging two separate 50 USD reimbursements against a 150 USD expense, and verifying the total reimbursed is 100 USD with 50 USD still reimbursable.

**Acceptance Scenarios**:

1. **Given** a paid expense of 200 USD, **When** the user logs a reimbursement of 50 USD with note "First half", **Then** the expense status becomes "partially_reimbursed" (or remains paid until fully reimbursed) and the available amount increases by 50.
2. **Given** a partially reimbursed expense, **When** the user logs another reimbursement that exceeds the remaining balance, **Then** the system rejects the entry because `reimbursementAmount > allowed`.

---

### User Story 3 - Medical Bill Reimbursement (Priority: P1)

As a user, I want to record reimbursements specifically for medical bills, taking into account the userPayableAmount constraints.

**Why this priority**: Unifies the financial logic for health expenses with general expenses.

**Independent Test**: Log a reimbursement for a medical bill and verify the rules only allow reimbursement up to the `userPayableAmount`.

**Acceptance Scenarios**:

1. **Given** a paid medical bill where userPayableAmount is 50 USD, **When** the user tries to reimburse 100 USD, **Then** the system rejects it.
2. **Given** a paid medical bill where userPayableAmount is 50 USD, **When** the user logs a 50 USD reimbursement, **Then** the bill status updates to `reimbursed` and availableAmount increases by 50 USD.

---

### User Story 4 - Cross-Currency Reimbursements (Priority: P2)

As a user, I want to log a reimbursement in a different currency than the original expense so that I don't have to calculate the exchange rate manually.

**Why this priority**: Highly useful for travelers or remote workers.

**Independent Test**: Log a reimbursement in USD against a EUR expense, and verify the primary currency total matches the correct exchange-rate-converted amount in the budget.

**Acceptance Scenarios**:

1. **Given** a 100 EUR expense, **When** the user logs a reimbursement of 110 USD, **Then** the system converts the 110 USD to the primary currency and increases the available amount appropriately.
2. **Given** an unsupported currency is entered, **When** the user submits the form, **Then** the system rejects it.

---

### Edge Cases

- What happens when a reimbursement is deleted? (The available amount should decrease back, and the expense status should revert).
- How does system handle a user attempting to reimburse a cancelled expense? (It should be blocked: source not paid → reject).
- What if the exchange rate changes after a cross-currency reimbursement is logged? (The reimbursement value is locked at the rate active when it was logged).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to log one or multiple Reimbursement events against a single paid Expense or Medical Bill.
- **FR-002**: System MUST enforce that `reimbursementAmount > 0` and total reimbursements for an expense ≤ `expense.amount`.
- **FR-003**: System MUST enforce that total reimbursements for a medical bill ≤ `userPayableAmount`.
- **FR-004**: System MUST update the associated expense/bill status to `reimbursed` dynamically based on the total reimbursed amount.
- **FR-005**: System MUST allow users to attach an optional note/source text to each reimbursement event.
- **FR-006**: System MUST allow reimbursements to be logged in supported currencies (HUF, USD, CAD, EUR) and reject unsupported ones.
- **FR-007**: System MUST immediately recalculate `availableAmount` (increases by reimbursementAmount) when a reimbursement is saved.
- **FR-008**: System MUST provide a Reimbursement Entry Screen showing max allowed reimbursement and insurance breakdown (for medical).
- **FR-009**: System MUST update the Expense Details and Medical Bill Details screens to show a reimbursement section, history, and status timeline.
- **FR-010**: System MUST reject operations if `userId` does not match the active profile, or if `source` is not found/not paid.

### Key Entities

- **Reimbursement**: 
  - Fields: `id` (string), `userId` (string), `sourceType` (enum: expense, medicalBill), `sourceId` (string), `amount` (decimal > 0), `currency` (enum: HUF, USD, CAD, EUR), `createdAt` (datetime), `note` (string, optional).
- **Expense**: Represents the original outbound transaction. Status updated to reimbursed when fully paid back.
- **MedicalBill**: Represents the health transaction. Status updated to reimbursed when fully paid back.
- **UserProfile**: Identifies the user and primary currency.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Reimbursements can be accessed and logged from Expense Details, Medical Bill Details, and Dashboard quick actions.
- **SC-002**: `availableAmount` recalculation occurs instantly and accurately handles cross-currency conversions.
- **SC-003**: Attempting to reimburse beyond the allowed amount (original amount or userPayableAmount) is consistently rejected by deterministic validation rules.
- **SC-004**: System maintains offline-first capability and local persistence using Drift/Isar.

## Assumptions

- Isar is used for local persistence rather than Drift, as established in the current BudgetBuddy architecture (Drift was mentioned, but BudgetBuddy engine uses Isar).
- The `availableAmount` logic relies on the sum of all reimbursements for a month's expenses.
- Cross-currency reimbursements will use the same exchange rate provider logic already built into the engine.
