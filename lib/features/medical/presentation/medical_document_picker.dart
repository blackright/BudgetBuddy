import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Attach evidence to one management event using camera, gallery or a file.
class MedicalDocumentPicker extends StatelessWidget {
  const MedicalDocumentPicker({
    super.key,
    required this.paths,
    required this.onChanged,
    this.label = 'Supporting documents',
  });

  final List<String> paths;
  final ValueChanged<List<String>> onChanged;
  final String label;

  Future<void> _add(BuildContext context) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(sheet, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(sheet, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Choose file'),
              onTap: () => Navigator.pop(sheet, 'file'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    String? path;
    if (source == 'file') {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
      );
      path = file?.path;
    } else {
      final picked = await ImagePicker().pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 85,
      );
      path = picked?.path;
    }
    if (path == null || !context.mounted) return;
    onChanged([...paths, path]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (paths.isNotEmpty)
          for (var i = 0; i < paths.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title:
                  Text(paths[i], maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                tooltip: 'Remove document',
                icon: const Icon(Icons.close),
                onPressed: () => onChanged([...paths]..removeAt(i)),
              ),
            ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label:
                Text(paths.isEmpty ? 'Add document' : 'Add another document'),
          ),
        ),
      ],
    );
  }
}
