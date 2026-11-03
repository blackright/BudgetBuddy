# Pending Actions

Everything that needs the user, in one place (release 022).

- `models/` — presentation view models (the persisted row lives in
  `lib/core/models/pending_action.dart`).
- `services/` — `PendingActionService` (create/update/read/complete) and, in a
  later phase, the synthesizer that maps existing attention sources.
- `providers/` — active-context service and streams.
- `presentation/` — the `/pending_actions` centre (later phase).

An action is attention metadata only. Creating, reading or completing one never
changes money, allocations, Vault entries or month totals.
