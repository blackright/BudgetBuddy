# Research & Technical Decisions: Unified Reimbursements

## Unknowns Resolved

- **Storage Strategy for Reimbursements**: 
  - **Decision**: Create a new standalone Isar collection `Reimbursement` linked to `Expense` via `sourceId`.
  - **Rationale**: The user requires multi-event reimbursements (e.g. paying back in chunks) and notes/source tracking. A standalone collection is best for 1-to-many relationships without bloating the Expense object. It natively supports querying and aggregating by `sourceId`.
  - **Alternatives considered**: Storing reimbursements as a list of embedded objects inside `Expense`. While Isar supports embedded objects, maintaining them requires updating the parent expense every time. A standalone collection is cleaner for independent timeline events and avoids massive Expense objects.

- **Handling Medical Bills vs General Expenses**:
  - **Decision**: Both Medical Bills and General Expenses will use `expense.id` as the universal `sourceId` for reimbursements.
  - **Rationale**: Since Medical Bills in BudgetBuddy wrap an underlying `Expense`, they share the same ID or reference the same expense lifecycle. Thus, `sourceType` can be used to distinguish the UI context, but the underlying foreign key is the `expense.id`.
  - **Alternatives considered**: Creating two different fields (`expenseId` and `medicalBillId`), which adds complexity to queries.

- **Available Amount Recalculation**:
  - **Decision**: The `availableAmount` provider will aggregate reimbursements on-the-fly or cache the total per month, similar to how expenses are aggregated.
  - **Rationale**: Adheres to the principle of single source of truth. When a reimbursement is added, Riverpod providers watching the reimbursements stream for a specific month will trigger a recalculation of the `availableAmount`.
