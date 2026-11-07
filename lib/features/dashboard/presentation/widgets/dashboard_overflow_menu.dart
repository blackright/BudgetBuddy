import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/active_budget_provider.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../spaces/presentation/move_month_sheet.dart';
import '../../../spaces/providers/spaces_providers.dart';
import '../dashboard_copy.dart';
import '../dashboard_view_state.dart';
import 'month_tools_sheet.dart';

enum _DashboardMenuAction { convert, move, history }

/// The single month-tools overflow on the Dashboard app bar.
class DashboardOverflowMenu extends ConsumerWidget {
  const DashboardOverflowMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(activeBudgetProvider).value;
    final canEdit = ref.watch(activeContextCanEditProvider);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final tools = DashboardMonthTools.from(
      hasBudget: budget != null,
      canEdit: canEdit,
      yearMonth: yearMonth,
    );

    return PopupMenuButton<_DashboardMenuAction>(
      key: const Key('dashboardOverflow'),
      icon: const Icon(Icons.more_vert),
      tooltip: DashboardCopy.more,
      onSelected: (action) {
        switch (action) {
          case _DashboardMenuAction.convert:
            MonthToolsSheet.show(context);
            break;
          case _DashboardMenuAction.move:
            MoveMonthSheet.show(context);
            break;
          case _DashboardMenuAction.history:
            context.push('/audit_history');
            break;
        }
      },
      itemBuilder: (context) => [
        if (tools.canConvert)
          const PopupMenuItem<_DashboardMenuAction>(
            key: Key('menuConvertMonth'),
            value: _DashboardMenuAction.convert,
            child: Text(DashboardCopy.convertMonth),
          ),
        if (tools.canMove)
          const PopupMenuItem<_DashboardMenuAction>(
            key: Key('menuMoveMonth'),
            value: _DashboardMenuAction.move,
            child: Text(DashboardCopy.moveMonth),
          ),
        const PopupMenuItem<_DashboardMenuAction>(
          key: Key('menuHistory'),
          value: _DashboardMenuAction.history,
          child: Text(DashboardCopy.history),
        ),
      ],
    );
  }
}
