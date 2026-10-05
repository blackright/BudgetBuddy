# Quickstart Validation Guide: Unified Reimbursements

This guide provides steps to validate the end-to-end functionality of the Unified Reimbursements feature without duplicating implementation code.

## Prerequisites
- The app must be running locally (`flutter run`).
- At least one active user profile must exist.
- You need a baseline `availableAmount` visible on the Dashboard.

## Validation Scenarios

### Scenario 1: General Expense Reimbursement
1. **Setup**: Create a general expense of **100 USD** and mark it as **paid**. Verify `availableAmount` decreases by 100 USD.
2. **Action**: Open the Expense Details screen and log a Reimbursement of **100 USD** with the note "Company playback".
3. **Validation**:
   - Verify the expense status immediately updates to `reimbursed`.
   - Return to the Dashboard and verify `availableAmount` has **increased by 100 USD**.

### Scenario 2: Multi-Event & Partial Reimbursement
1. **Setup**: Create a general expense of **200 USD** and mark it as **paid**.
2. **Action 1**: Log a reimbursement of **50 USD**.
3. **Validation 1**:
   - Verify the expense status updates to `partially_reimbursed` (or similar indicator).
   - Verify `availableAmount` increases by **50 USD**.
4. **Action 2**: Attempt to log another reimbursement of **160 USD**.
5. **Validation 2**: 
   - Verify the system **rejects** the entry with a validation error (max allowed is 150).
6. **Action 3**: Log a reimbursement of **150 USD**.
7. **Validation 3**:
   - Verify the expense status updates to `reimbursed`.
   - Verify `availableAmount` increases by **150 USD**.

### Scenario 3: Medical Bill Cap Enforcement
1. **Setup**: Create a Medical Bill. Assume the original charge is 1000 USD, but the patient share (`userPayableAmount`) is **200 USD**. Mark it as **paid**.
2. **Action**: Open Medical Bill Details and attempt to log a reimbursement of **300 USD**.
3. **Validation**: 
   - Verify the system **rejects** the entry (max allowed is 200).
4. **Action 2**: Log a reimbursement of **200 USD**.
5. **Validation 2**:
   - Verify the medical bill status updates to `reimbursed`.
   - Verify `availableAmount` increases by **200 USD**.

### Scenario 4: Cross-Currency Reimbursement
1. **Setup**: Ensure your profile's primary currency is **USD**. Create a paid expense for **100 EUR**. 
2. **Action**: Log a reimbursement in **USD** against the EUR expense (e.g., 110 USD, assuming 1 EUR = 1.10 USD exchange rate applied).
3. **Validation**:
   - Verify the UI accepts the currency difference.
   - Verify the `availableAmount` correctly increases by **110 USD**.
