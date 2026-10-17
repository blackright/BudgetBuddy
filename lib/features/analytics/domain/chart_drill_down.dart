import '../../../core/models/expense.dart';

/// A typed request emitted when a chart segment is tapped (data-model §4.3).
///
/// It is sent at `full` size only (contract chart-ui.md §5). The presentation
/// layer maps it to an existing `/expenses` filter rather than building a
/// second list screen.
sealed class ChartDrillDown {
  const ChartDrillDown();
}

/// Drill into expenses for a single category, optionally further filtered by
/// a specific [ExpenseStatus].
class ChartDrillDownCategory extends ChartDrillDown {
  const ChartDrillDownCategory({
    required this.categoryId,
    this.status,
  });

  final String categoryId;
  final ExpenseStatus? status;
}

/// Drill into expenses filtered to a specific [ExpenseStatus].
class ChartDrillDownStatus extends ChartDrillDown {
  const ChartDrillDownStatus({
    required this.status,
  });

  final ExpenseStatus status;
}

/// Drill into shared expenses for a single member ([profileId]) — applies to
/// the contribution chart.
class ChartDrillDownMember extends ChartDrillDown {
  const ChartDrillDownMember({
    required this.profileId,
  });

  final int profileId;
}
