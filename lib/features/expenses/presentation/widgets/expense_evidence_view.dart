import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_helper.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/expense_evidence_chunk.dart';
import '../../../../core/providers/budget_context_provider.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../../../spaces/providers/spaces_providers.dart';
import '../../providers/expense_search_provider.dart';
import '../../../../core/services/expense_evidence.dart';
import '../../repositories/expense_evidence_repository.dart';
import 'expense_evidence_editor.dart';

final expenseDocumentBytesProvider = StreamProvider.autoDispose
    .family<Uint8List?, (Expense, EvidenceDocument)>((ref, key) async* {
  final scope = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (scope.isShared) ref.watch(activeSpaceMembersProvider);
  if (scope.spaceId != key.$1.sharedSpaceId ||
      (!scope.isShared && scope.profileKey != key.$1.profileId)) {
    yield null;
    return;
  }
  final repository = ref.watch(expenseSearchRepositoryProvider);
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await repository.authorize(scope, actor);
  if (disposed) return;
  yield* IsarHelper.instance.expenseEvidenceChunks
      .filter()
      .documentGuidEqualTo(key.$2.guid)
      .watch(fireImmediately: true)
      .asyncMap((_) => ExpenseEvidenceRepository(IsarHelper.instance)
          .readDocument(key.$1, key.$2));
});

class ExpenseEvidenceView extends ConsumerWidget {
  const ExpenseEvidenceView({super.key, required this.expense});
  final Expense expense;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(budgetContextProvider);
    if (scope.spaceId != expense.sharedSpaceId ||
        (!scope.isShared && scope.profileKey != expense.profileId)) {
      return const SizedBox.shrink();
    }
    ExpenseEvidence? evidence;
    try {
      evidence = ExpenseEvidence.decode(expense.paymentEvidenceJson);
    } catch (_) {
      return const ListTile(
          leading: Icon(Icons.warning_amber),
          title: Text('Payment evidence needs review'));
    }
    if (evidence == null) {
      return const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.history),
          title: Text('Legacy · Missing payment evidence'),
          subtitle: Text(
              'No receipt or payment confirmation was recorded for this expense.'));
    }
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expenseEvidenceProblems(expense).isNotEmpty)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                            'Payment details need review. Complete missing information in Edit expense.')),
                  Text('Payment evidence',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (evidence.documents.isEmpty)
                    const Text('No documents recorded.'),
                  for (final document in evidence.documents)
                    ref.watch(expenseDocumentBytesProvider((expense, document))).when(
                        data: (bytes) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: bytes != null &&
                                    document.mediaType.startsWith('image/')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(bytes,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        cacheWidth: 96,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                                Icons.broken_image_outlined)))
                                : Icon(document.mediaType == 'application/pdf'
                                    ? Icons.picture_as_pdf_outlined
                                    : Icons.image_outlined),
                            title: Text(document.name),
                            subtitle:
                                Text(bytes == null ? 'Pending · document has not arrived on this device' : '${document.role == 'receipt' ? 'Merchant receipt' : 'Payment proof'} · Available'),
                            trailing: bytes == null ? const Icon(Icons.sync) : const Icon(Icons.open_in_full),
                            onTap: bytes == null ? null : () => openEvidenceDocument(context, bytes, document)),
                        loading: () => ListTile(title: Text(document.name), subtitle: const Text('Checking document…')),
                        error: (_, __) => ListTile(title: Text(document.name), subtitle: const Text('Unavailable · document integrity or ownership needs review'), leading: const Icon(Icons.warning_amber))),
                  if (evidence.cashAt != null)
                    Text(
                        'Cash payment confirmed · ${MaterialLocalizations.of(context).formatMediumDate(evidence.cashAt!.toLocal())}'),
                ])));
  }
}

Future<void> openEvidenceDocument(
        BuildContext context, Uint8List bytes, EvidenceDocument document) =>
    document.mediaType.startsWith('image/')
        ? showEvidenceImage(context, bytes, document.name)
        : showDialog<void>(
            context: context,
            builder: (_) => _PdfPreview(bytes: bytes, name: document.name));

class _PdfPreview extends StatefulWidget {
  const _PdfPreview({required this.bytes, required this.name});
  final Uint8List bytes;
  final String name;
  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  static const channel = MethodChannel('budget_buddy/payment_document');
  int page = 0;
  late Future<Map<Object?, Object?>?> rendered;
  Future<Map<Object?, Object?>?> render() => channel
      .invokeMapMethod('renderPdfPage', {'bytes': widget.bytes, 'page': page});
  @override
  void initState() {
    super.initState();
    rendered = render();
  }

  void change(int next) => setState(() {
        page = next;
        rendered = render();
      });
  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
      child: Scaffold(
          appBar: AppBar(title: Text(widget.name)),
          body: FutureBuilder<Map<Object?, Object?>?>(
              future: rendered,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child:
                          Text('PDF preview is unavailable on this device.'));
                }
                final result = snapshot.data;
                if (result == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final pages = result['pages'] as int;
                return Column(children: [
                  Expanded(
                      child: InteractiveViewer(
                          key: ValueKey(page),
                          minScale: .5,
                          maxScale: 8,
                          child: Center(
                              child:
                                  Image.memory(result['image'] as Uint8List)))),
                  SafeArea(
                      top: false,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                tooltip: 'Previous page',
                                onPressed:
                                    page > 0 ? () => change(page - 1) : null,
                                icon: const Icon(Icons.chevron_left)),
                            Text('Page ${page + 1} of $pages'),
                            IconButton(
                                tooltip: 'Next page',
                                onPressed: page + 1 < pages
                                    ? () => change(page + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right)),
                          ]))
                ]);
              })));
}
