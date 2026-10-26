import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/services/expense_evidence.dart';
import '../../../../core/services/expense_evidence_draft.dart';
import '../../../../core/services/evidence_staging.dart';
import 'expense_evidence_view.dart' show openEvidenceDocument;

/// Both payment roles remain visible; a selected file never confirms payment.
class ExpenseEvidenceEditor extends StatefulWidget {
  const ExpenseEvidenceEditor(
      {super.key,
      required this.draft,
      required this.status,
      required this.payment,
      this.onChanged});
  final ExpenseEvidenceDraft draft;
  final ExpenseStatus status;
  final String? payment;
  final VoidCallback? onChanged;
  @override
  State<ExpenseEvidenceEditor> createState() => _ExpenseEvidenceEditorState();
}

class _ExpenseEvidenceEditorState extends State<ExpenseEvidenceEditor> {
  bool busy = false;
  String? error;
  Future<void> pick(String role) async {
    if (busy) return;
    if (widget.draft.documents.length >= 3) {
      setState(
          () => error = 'Use at most three files. Remove one to replace it.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: role == 'payment' && widget.payment == 'card'
              ? ['jpg', 'jpeg', 'png']
              : ['jpg', 'jpeg', 'png', 'pdf']);
      if (file == null) return;
      final length = await file.length();
      if (length != null && length > evidenceMaximumBytes) {
        throw const FormatException('Choose a file of 5 MB or less.');
      }
      final buffer = BytesBuilder(copy: false);
      await for (final part in file.readAsByteStream()) {
        if (buffer.length + part.length > evidenceMaximumBytes) {
          throw const FormatException('Choose a file of 5 MB or less.');
        }
        buffer.add(part);
      }
      final bytes = buffer.takeBytes();
      final prepared =
          await prepareEvidence(bytes: bytes, name: file.name, role: role);
      if (prepared.document.mediaType.startsWith('image/')) {
        final codec = await ui.instantiateImageCodec(prepared.bytes,
            targetWidth: 1024, allowUpscaling: false);
        try {
          final frame = await codec.getNextFrame();
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await const MethodChannel('budget_buddy/payment_document').invokeMethod(
            'renderPdfPage', {'bytes': prepared.bytes, 'page': 0});
      }
      if (!mounted) return;
      final staged = await EvidenceStaging.stage(prepared);
      if (!mounted) {
        await EvidenceStaging.discard(staged.stagedPath);
        return;
      }
      setState(() {
        widget.draft.documents.add(prepared.document);
        widget.draft.prepared[prepared.document.guid] = staged;
        widget.draft.changed = true;
      });
      widget.onChanged?.call();
    } catch (failure) {
      if (mounted) {
        setState(() => error = failure is FormatException
            ? failure.message
            : 'The document could not be opened. Choose another file.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paid = isPaidExpenseStatus(widget.status);
    final receipt = widget.draft.documents.any((d) => d.role == 'receipt');
    final proof = widget.draft.documents.any((d) =>
        d.role == 'payment' &&
        (widget.payment != 'card' || d.mediaType.startsWith('image/')));
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant)),
        child: Material(
            color: colors.surfaceContainerLow,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.verified_user_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Payment evidence',
                        style: Theme.of(context).textTheme.titleMedium)),
                Text('${widget.draft.documents.length}/3')
              ]),
              const SizedBox(height: 8),
              Text(
                  paid
                      ? 'Keep the purchase receipt and payment proof together.'
                      : 'Optional while planned. Complete this when you mark it paid.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              if (paid &&
                  !{'cash', 'card', 'bankTransfer'}.contains(widget.payment))
                Text(
                    'Choose Cash, Card or Bank transfer to record a paid purchase.',
                    style: TextStyle(color: colors.error)),
              _check(context, receipt, 'Merchant receipt or invoice'),
              if (widget.payment == 'card' || widget.payment == 'bankTransfer')
                _check(
                    context,
                    proof,
                    widget.payment == 'card'
                        ? 'Separate card-payment screenshot'
                        : 'Separate bank-transfer proof'),
              for (final doc in widget.draft.documents)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: widget.draft.prepared[doc.guid]?.bytes != null &&
                            doc.mediaType.startsWith('image/')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: widget.draft.prepared[doc.guid]!.stagedPath !=
                                    null
                                ? Image.file(File(widget.draft.prepared[doc.guid]!.stagedPath!),
                                    width: 44,
                                    height: 44,
                                    cacheWidth: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(
                                        width: 44,
                                        height: 44,
                                        child:
                                            Icon(Icons.broken_image_outlined)))
                                : Image.memory(
                                    widget.draft.prepared[doc.guid]!.bytes,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    cacheWidth: 96,
                                    errorBuilder: (_, __, ___) => const SizedBox(
                                        width: 44,
                                        height: 44,
                                        child:
                                            Icon(Icons.broken_image_outlined))))
                        : Icon(doc.mediaType == 'application/pdf' ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
                    title: Text(doc.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(doc.role == 'receipt' ? 'Merchant receipt' : 'Payment proof'),
                    onTap: widget.draft.prepared[doc.guid] != null
                        ? () async {
                            final prepared = widget.draft.prepared[doc.guid]!;
                            final bytes = prepared.stagedPath == null
                                ? prepared.bytes
                                : await EvidenceStaging.read(
                                    prepared.stagedPath!);
                            if (context.mounted) {
                              await openEvidenceDocument(context, bytes, doc);
                            }
                          }
                        : null,
                    trailing: IconButton(
                        tooltip: 'Remove ${doc.name}',
                        icon: const Icon(Icons.close),
                        onPressed: busy
                            ? null
                            : () {
                                setState(() {
                                  widget.draft.documents.remove(doc);
                                  EvidenceStaging.discard(widget.draft.prepared
                                      .remove(doc.guid)
                                      ?.stagedPath);
                                  widget.draft.changed = true;
                                });
                                widget.onChanged?.call();
                              })),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: busy ? null : () => pick('receipt'),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Add receipt')),
                if (widget.payment == 'card' ||
                    widget.payment == 'bankTransfer')
                  OutlinedButton.icon(
                      onPressed: busy ? null : () => pick('payment'),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Add payment proof')),
              ]),
              if (widget.payment == 'cash' && paid)
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: widget.draft.cashConfirmed,
                    title: const Text(
                        'I confirm that I paid this purchase in cash.'),
                    subtitle: const Text(
                        'This records your declaration and confirmation time.'),
                    onChanged: (value) {
                      setState(() {
                        widget.draft.cashConfirmed = value ?? false;
                        widget.draft.cashConfirmedAt =
                            value == true ? DateTime.now().toUtc() : null;
                        widget.draft.changed = true;
                      });
                      widget.onChanged?.call();
                    }),
              const SizedBox(height: 6),
              Text('JPEG, PNG or PDF · 5 MB per file · 3 files maximum',
                  style: Theme.of(context).textTheme.labelSmall),
              if (busy) const LinearProgressIndicator(),
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!, style: TextStyle(color: colors.error))),
            ])));
  }

  Widget _check(BuildContext context, bool ready, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(ready ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: ready
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(child: Text(text))
      ]));
}

Future<void> showEvidenceImage(
        BuildContext context, Uint8List bytes, String name) =>
    showDialog<void>(
        context: context,
        builder: (context) => Dialog.fullscreen(
            child: Scaffold(
                appBar: AppBar(title: Text(name)),
                body: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 8,
                    child: Center(
                        child: Image.memory(bytes,
                            cacheWidth: 2048, fit: BoxFit.contain))))));
