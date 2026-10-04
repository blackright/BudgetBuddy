# Phase 0: Research & Technical Clarifications

## Local Storage Engine (Database)
**Decision**: Isar Database.
**Rationale**: The app requires offline-first, fast local storage for multiple user profiles, complex expenses, and multi-currency data. Isar provides excellent Flutter support, fast querying, and handles relations (like user profiles to expenses) gracefully in an offline environment.
**Alternatives considered**: 
- `sqflite`: Good but slower and requires manual SQL mapping which slows down iteration.
- `shared_preferences`: Only good for simple key-value pairs, not suitable for complex financial data.

## State Management
**Decision**: Riverpod.
**Rationale**: Constitution specifies Riverpod or Bloc. Riverpod is modern, compile-safe, and excellent for dependency injection and state management in Flutter.
**Alternatives considered**: Bloc.
