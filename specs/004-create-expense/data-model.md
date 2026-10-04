# Phase 1: Data Model - Create Expense

## Entities

### `Expense` (Isar @collection)
- `id` (Id): Auto-increment
- `title` (String)
- `amount` (Double): Must be > 0
- `currency` (String): e.g., 'HUF', 'USD'
- `categoryId` (String)
- `status` (String): 'planned' or 'paid'
- `isReimbursable` (bool): default false
- `guiltLevel` (String): 'Essential', 'Guilt-Free Splurge', 'Oops'
- `receiptPhotoPath` (String?): Optional local path
- `createdAt` (DateTime)
- `paidAt` (DateTime?): Set when status changes to 'paid'
- `profileId` (int): Indexed, to link to the active user profile

### `ExpenseTemplate` (Isar @collection)
- `id` (Id): Auto-increment
- `title` (String)
- `amount` (Double)
- `currency` (String)
- `categoryId` (String)
- `guiltLevel` (String)
- `profileId` (int): Indexed

## Validation Rules
- `amount` must be greater than 0.
- `title` must not be empty.
- `currency` must be supported (HUF, USD, CAD, EUR).
