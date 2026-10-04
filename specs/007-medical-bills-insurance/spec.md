# Feature Specification: Medical Bills & Insurance

**Feature Branch**: `007-medical-bills-insurance`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Medical Bills & Insurance (Unified) ... Option 1 The Smart Claim & Deductible Approach"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add Medical Bill & Track Deductible (Priority: P1)

Users need to log medical bills to track their out-of-pocket expenses towards their annual deductible.

**Why this priority**: Core functionality; without logging bills, the system provides no value.

**Independent Test**: Can be fully tested by adding a medical bill and verifying the out-of-pocket amount is calculated and displayed on the dashboard deductible progress bar.

**Acceptance Scenarios**:

1. **Given** the user is on the Health Dashboard, **When** they add a new medical bill with provider "Dr. Smith", amount 1000, and 80% coverage, **Then** the bill is saved, the estimated out-of-pocket is 200, and the deductible progress bar increases by 200.

---

### User Story 2 - Pay Provider (Priority: P2)

Users need to mark a bill as paid to the provider so it correctly impacts their `trueAvailable` budget.

**Why this priority**: Connects medical tracking to the core BudgetBuddy engine.

**Independent Test**: Can be tested by marking an unpaid bill as paid and verifying the budget is reduced.

**Acceptance Scenarios**:

1. **Given** a pending medical bill, **When** the user marks it as paid, **Then** the `trueAvailable` budget is reduced by the full billed amount.

---

### User Story 3 - Log Insurance Reimbursement (Priority: P3)

Users need to log insurance payouts so their budget is replenished with the reimbursed amount.

**Why this priority**: Closes the lifecycle of the claim and corrects the budget.

**Independent Test**: Can be tested by logging a reimbursement for a paid bill and verifying `trueAvailable` increases.

**Acceptance Scenarios**:

1. **Given** a paid medical bill, **When** the user marks the claim as reimbursed for 800, **Then** the claim status is updated and `trueAvailable` increases by 800.

### Edge Cases

- What happens if the insurance denies the claim? (Claim status becomes `denied`, no budget replenishment).
- What happens if the reimbursed amount is higher/lower than expected? (The actual reimbursement amount is what is injected into the budget).
- What if the user deletes a medical bill that was already reimbursed? (Needs a warning or soft-lock, as it affects past budget states).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to create medical bills with provider, patient, billed amount, and expected insurance coverage percentage.
- **FR-002**: System MUST automatically calculate the insurance covered amount and estimated out-of-pocket cost.
- **FR-003**: System MUST link each medical bill to a core Expense for budget tracking.
- **FR-004**: System MUST reduce `trueAvailable` by the full billed amount when a bill is marked as paid to the provider.
- **FR-005**: System MUST increase `trueAvailable` by the reimbursed amount when a claim is marked as reimbursed.
- **FR-006**: System MUST visualize annual deductible progress based on total out-of-pocket costs.
- **FR-007**: System MUST allow users to attach images or PDFs (receipts, EOBs) to a medical bill.
- **FR-008**: System MUST maintain a directory of Medical Providers for easy selection and autofill.
- **FR-009**: System MUST allow users to set a follow-up reminder date for pending claims.

### UI/UX Requirements

- **UX-001**: All screens MUST fully support Dark Mode to ensure eye protection.
- **UX-002**: The Light Mode theme MUST use soft, muted background colors (avoiding harsh pure white) to reduce glare and eye strain.

### Key Entities *(include if feature involves data)*

- **MedicalBill**: Represents a medical service, storing provider, patient, amounts, and statuses. Links to a core Expense. Can contain attachments and follow-up reminders.
- **FamilyMember**: Represents individuals in the user's family (Self, Spouse, Children) to track whose bill it is.
- **MedicalProvider**: A directory entry for a doctor or hospital to avoid repetitive typing.
- **InsuranceProfile**: Stores the user's individual and family annual deductible limits, and default coverage percentage.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can log a medical bill and its expected coverage in under 30 seconds.
- **SC-002**: Budget (`trueAvailable`) instantly reflects payments and reimbursements without manual double-entry.
- **SC-003**: System correctly calculates annual out-of-pocket totals and deductible progress with 100% accuracy.

## Assumptions

- Users have a single primary insurance policy per profile.
- Reimbursed amounts may differ slightly from the estimated insurance covered amount.
- The app operates offline-first using local Isar storage.
