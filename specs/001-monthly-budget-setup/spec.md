# Feature Specification: Monthly Budget Setup

**Feature Branch**: `001-monthly-budget-setup`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Feature Specification: Monthly Budget Setup..."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initial Onboarding Setup (Priority: P1)

As a new user, I want to define my monthly available amount, primary currency, and select a specific target month (e.g., "October 2026") so that I can establish my baseline budget for that timeframe.

**Why this priority**: It is the mandatory first step to use the core functionality of the app.
**Independent Test**: Can be tested by launching the app for the first time, completing the setup screen, and verifying the UserProfile is updated with the correct amount and currency.

**Acceptance Scenarios**:

1. **Given** a new user profile, **When** I enter a monthly available amount of 2000, select USD, and select "October 2026", **Then** my profile is updated and the monthly context is initialized for October 2026 with 2000 USD.
2. **Given** a new user profile, **When** I enter 0 or a negative amount, **Then** the system rejects the input and shows an error message.

---

### User Story 2 - Monthly Reset (Priority: P2)

As an existing user, I want to explicitly select a future or past month and set my available amount for it so that I can plan ahead or backfill data.

**Why this priority**: Required for ongoing retention and accurate monthly tracking.
**Independent Test**: Can be tested by triggering a month-end transition and ensuring the user can update the amount, creating a fresh bucket while preserving historical data.

**Acceptance Scenarios**:

1. **Given** an existing profile, **When** I explicitly select a new target month (e.g., "November 2026") and confirm a new amount of 2500 USD, **Then** a new budget context is created specifically for November 2026, preserving prior months' data.
2. **Given** a new month setup screen, **When** it opens, **Then** the amount and currency fields are automatically pre-filled using the previous month's values.

---

### User Story 3 - Adjusting Settings (Priority: P3)

As an existing user, I want to change my primary currency or adjust my available amount midway through the month from the settings screen.

**Why this priority**: Important for flexibility, but less critical than initial setup or resets.
**Independent Test**: Navigate to settings, change the primary currency from USD to EUR, and verify that the dashboard now reflects the new primary currency.

**Acceptance Scenarios**:

1. **Given** an active monthly context, **When** I change my primary currency to EUR, **Then** the system warns me that all historical dashboard views will be recalculated in EUR.
2. **Given** the warning prompt, **When** I confirm the currency change, **Then** my profile is updated and all aggregated views across all months use EUR.

### Edge Cases

- What happens if the user tries to set an unsupported currency? (System must reject).
- What happens if the device is offline during setup? (Must complete successfully as the app is offline-first).
- How are unspent balances handled? (Strict buckets: unspent money does not carry over to inflate the next month's available amount).
- What happens when a user edits a past month's budget? (Data is recalculated only for that specific past month; no cascading effects since there are no rollovers).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a UI screen (Monthly Budget Setup) to input the monthly available amount, select a primary currency, and explicitly select a target month/year.
- **FR-002**: System MUST validate that the monthly available amount is strictly greater than 0.
- **FR-003**: System MUST validate that the selected currency is one of the supported enumerations (HUF, USD, CAD, EUR).
- **FR-004**: System MUST update the `UserProfile` entity with the new `monthlyAvailableAmount` and `primaryCurrency`.
- **FR-005**: System MUST initialize a new monthly context tied to the explicitly selected target month (identified by a `yearMonth` field) when the amount is set or changed.
- **FR-006**: System MUST persist the previous month's financial data for read-only analytics when a new month is initialized.
- **FR-007**: System MUST pre-fill the monthly setup form with the user's most recently used amount and currency to reduce friction.
- **FR-008**: System MUST display a confirmation warning when changing the primary currency, stating that historical dashboards will be recalculated into the new currency.
- **FR-009**: System MUST perform all operations offline, persisting data locally.

### Key Entities *(include if feature involves data)*

- **UserProfile**: The core entity storing `monthlyAvailableAmount` and `primaryCurrency`.
- **MonthlyBudget**: A derived virtual context representing the financial constraints for a specific target month (e.g., identified by `yearMonth`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully complete the initial budget setup in under 30 seconds.
- **SC-002**: The system correctly rejects 100% of invalid amounts (<= 0) and unsupported currencies.
- **SC-003**: Setup data is persisted locally and available instantly upon app restart without network connectivity.

## Assumptions

- While users can explicitly select a target month for budgeting, the app may still automatically prompt the user for the upcoming month's setup as it approaches.
- Supported currencies (HUF, USD, CAD, EUR) are hardcoded or managed securely on the client side for offline availability.
- Recurring/planned expenses carryover is out of scope for this setup feature and will be handled by a dedicated "Recurring Expenses" feature.
