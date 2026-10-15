# Quickstart Validation Guide: Medical Bills & Insurance

## Setup
1. Launch the BudgetBuddy application (`flutter run`).
2. Navigate to the Medical/Health Dashboard.

## Scenario 1: Setup Insurance Profile
1. On the Health Dashboard, set the Annual Deductible to $2000 and Default Coverage to 80%.
2. **Verify**: The progress bar appears, showing $0 / $2000 met.

## Scenario 2: Log a Medical Bill
1. Tap "Add Medical Bill".
2. Enter Provider: "City Hospital", Amount: 1000, Coverage: 80%. Mark as "Paid to Provider".
3. **Verify**: The overall dashboard budget `trueAvailable` drops by 1000.
4. **Verify**: The Health Dashboard progress bar shows $200 out-of-pocket met (1000 - 80% = 200).

## Scenario 3: Log a Reimbursement
1. Tap the "City Hospital" bill.
2. Under the "Insurance Breakdown" section, tap "Log Reimbursement".
3. Enter amount: 800.
4. **Verify**: The claim status changes to `reimbursed`.
5. **Verify**: The overall dashboard budget `trueAvailable` increases by 800 (net impact of the medical bill is now exactly the 200 out-of-pocket).
