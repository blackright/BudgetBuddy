# Research: Available Amount Calculation Engine

## 1. Multi-Currency Normalization Strategy
**Decision**: Use a caching HTTP client (like `dio` with `dio_cache_interceptor` or a manual Isar fallback) to fetch exchange rates from a free API (e.g., exchangerate-api.com).
**Rationale**: The app is offline-first. When logging an expense, if the network is available, it fetches the rate and caches it. If offline, it uses the last cached rate, or prompts the user if no rate exists.
**Alternatives considered**: Requiring manual entry always (too tedious), fetching all rates daily (might consume unnecessary bandwidth if the user doesn't log foreign expenses often).

## 2. End-of-Month Sweep Trigger
**Decision**: Implement a lazy evaluation trigger on app startup or when the dashboard is loaded.
**Rationale**: Mobile OS background tasks are unreliable. When the user opens the app, the engine checks if `lastOpenedMonth < currentMonth`. If true, it computes the final True Available for the past month, adds it to the SavingsVault, and updates `lastOpenedMonth`.
**Alternatives considered**: Native background periodic tasks (`workmanager`), which are brittle and heavily restricted by iOS/Android battery optimizations.

## 3. Real-time Calculation Performance
**Decision**: Use Riverpod computed providers (e.g., `Provider` that watches `ExpenseListProvider` and `MedicalBillProvider`).
**Rationale**: Riverpod handles dependency tracking and caches the result. It only recalculates when the underlying lists change, ensuring instant 60fps UI updates.
**Alternatives considered**: Re-calculating on every build (bad for performance) or storing the running balance in the database (violates single source of truth and is prone to desync).
