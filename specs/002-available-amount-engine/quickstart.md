# Quickstart & Validation Guide

## Prerequisites
- Flutter SDK installed.
- Isar dependencies generated (`dart run build_runner build -d`).

## Validation Scenarios

### Scenario 1: Verify Core Engine Math
1. Launch the app in debug mode (`flutter run`).
2. Set a Monthly Budget of $1000 for the current month.
3. Observe the Dashboard:
   - True Available: $1000
   - Safe-to-Spend: $1000
4. Add a **Planned** Expense for $200.
   - Observe True Available remains $1000.
   - Observe Safe-to-Spend updates to $800.
5. Add a **Paid** Expense for $50.
   - Observe True Available updates to $950.
   - Observe Safe-to-Spend updates to $750.

### Scenario 2: Test Foreign Currency Fallback
1. Turn off device Wi-Fi and Cellular (Airplane Mode).
2. Attempt to add an Expense of 50 EUR (when primary is USD).
3. Observe the UI prompting for a manual exchange rate.
4. Enter `1.10`.
5. Verify the calculation engine deducts $55 USD from the available amounts.

### Scenario 3: Verify Savings Vault Sweep
1. Add $100 to the current month's True Available.
2. Manually edit the device OS clock to jump forward 1 month.
3. Open the app.
4. Observe a "Savings Vault" notification or view indicating $100 was swept into savings.
5. Observe the new month's True Available starts fresh based on the Monthly Budget setup.
