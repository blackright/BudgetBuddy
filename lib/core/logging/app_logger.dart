import 'dart:developer' as developer;

class AppLogger {
  const AppLogger._();

  static void log(
    String message, {
    String name = 'BudgetBuddy',
    Object? error,
    StackTrace? stackTrace,
    int level = 800,
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: level,
    );
  }

  static void medical(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'Medical', error: error, stackTrace: stackTrace, level: level);
  }

  static void expense(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'Expense', error: error, stackTrace: stackTrace, level: level);
  }

  static void medicalRepo(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'MedicalRepo',
        error: error,
        stackTrace: stackTrace,
        level: level);
  }

  static void expenseRepo(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'ExpenseRepo',
        error: error,
        stackTrace: stackTrace,
        level: level);
  }

  static void medicalReceipt(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'MedicalReceipt',
        error: error,
        stackTrace: stackTrace,
        level: level);
  }

  static void medicalWithholding(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'MedicalWithholding',
        error: error,
        stackTrace: stackTrace,
        level: level);
  }

  static void medicalSettlement(String message,
      {Object? error, StackTrace? stackTrace, int level = 800}) {
    log(message,
        name: 'MedicalSettlement',
        error: error,
        stackTrace: stackTrace,
        level: level);
  }
}
