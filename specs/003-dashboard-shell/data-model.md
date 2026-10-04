# Data Model & State: Dashboard Shell & Navigation

As this is a routing and UI foundation feature, there are no new Isar database collections or backend entities. The "Data Model" here refers to the Routing State and the Navigation Tree.

## Routing Tree Configuration

### Top-Level Shell (StatefulShellRoute)
- Maintains an `IndexedStack` to preserve the state of its 5 branches.

### Branches

1. **Dashboard Branch**
   - **Path**: `/dashboard`
   - **Screen**: `DashboardScreen`
   - **Dependencies**: Observes `trueAvailableProvider`, `safeToSpendProvider`.

2. **Expenses Branch**
   - **Path**: `/expenses`
   - **Screen**: `ExpensesScreen` (Placeholder)

3. **Medical Bills Branch**
   - **Path**: `/medical`
   - **Screen**: `MedicalScreen` (Placeholder)

4. **Analytics Branch**
   - **Path**: `/analytics`
   - **Screen**: `AnalyticsScreen` (Placeholder)

5. **Settings Branch**
   - **Path**: `/settings`
   - **Screen**: `SettingsScreen` (Placeholder)

## Fallback Route
- **Path**: `/error` or Unknown Route Handler
- **Behavior**: Redirects gracefully back to `/dashboard`.
