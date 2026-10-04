# Data Model: Monthly Budget Setup

## Entities

### `UserProfile`
The core profile for a specific user on the device.
- `id` (String, UUID)
- `name` (String)
- `primaryCurrency` (String, enum: HUF, USD, CAD, EUR)
- `monthlyAvailableAmount` (Decimal)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

### `MonthlyBudget` (Derived / Virtual)
Represents the financial constraints for a specific target month. This may not be a standalone DB table if derived from expenses and the `UserProfile`, but for historical isolation (as per strict buckets), it is beneficial to store it as a snapshot.
- `id` (String, UUID)
- `userId` (String, FK to UserProfile)
- `yearMonth` (String, format "YYYY-MM")
- `baseAvailableAmount` (Decimal)
- `currency` (String, enum)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

## Validation Rules
- `monthlyAvailableAmount` / `baseAvailableAmount` MUST be strictly > 0.
- `primaryCurrency` MUST be one of: HUF, USD, CAD, EUR.
- `yearMonth` MUST be a valid year-month string (e.g., "2026-10").

## State Transitions
- **On Initialization**: When a user sets up a target month, a new `MonthlyBudget` record is created for that `yearMonth` using the provided amount and currency.
- **On Edit**: Updating a past `MonthlyBudget` only modifies that specific record, with no cascading effects.
