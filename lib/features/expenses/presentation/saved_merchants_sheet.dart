import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/budget_context_provider.dart';
import '../../../shared/presentation/modals/app_modal_tokens.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import '../providers/expense_search_provider.dart';

/// A searchable list of the merchants saved for the active profile or space.
///
/// The list is ordered by the most recent expense in that same context, so the
/// merchant used yesterday is one tap away. Selecting one returns its canonical
/// name; the caller fills the merchant field and never creates a second row for
/// a case/whitespace variant.
class SavedMerchantsSheet extends ConsumerStatefulWidget {
  const SavedMerchantsSheet({super.key, this.selected});

  /// The current merchant text, marked in the list.
  final String? selected;

  static Future<String?> show(BuildContext context, {String? selected}) =>
      showAppSheet<String>(
        context,
        builder: (_) => SavedMerchantsSheet(selected: selected),
      );

  @override
  ConsumerState<SavedMerchantsSheet> createState() =>
      _SavedMerchantsSheetState();
}

class _SavedMerchantsSheetState extends ConsumerState<SavedMerchantsSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final scope = ref.watch(budgetContextProvider);
    final merchants = ref.watch(savedMerchantsProvider);
    final visible = (merchants.valueOrNull ?? const [])
        .where((m) =>
            _query.isEmpty ||
            m.canonicalName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return AppSheet(
      title: 'Saved merchants',
      subtitle:
          scope.isShared ? 'Saved for this space' : 'Saved for this profile',
      bodyScrollable: false,
      body: Padding(
        padding: AppModalTokens.sheetBodyPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search merchants',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: merchants.when(
                loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator())),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(children: [
                    const Text('Saved merchants could not be loaded.'),
                    TextButton(
                        onPressed: () {
                          ref.invalidate(expenseSearchMerchantsProvider);
                          ref.invalidate(expenseSearchRowsProvider);
                        },
                        child: const Text('Retry')),
                  ]),
                ),
                data: (_) {
                  if (visible.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        _query.isEmpty
                            ? 'No saved merchants yet. Type a name and save one expense.'
                            : 'No merchant matches "$_query".',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final merchant = visible[index];
                      final selected =
                          merchant.canonicalName == widget.selected;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          child: Icon(Icons.storefront_outlined,
                              color: scheme.onPrimaryContainer),
                        ),
                        title: Text(merchant.canonicalName),
                        subtitle: merchant.aliases.isEmpty
                            ? null
                            : Text(merchant.aliases.join(', '),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: selected ? const Icon(Icons.check) : null,
                        onTap: () =>
                            Navigator.of(context).pop(merchant.canonicalName),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
