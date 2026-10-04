import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/category.dart';
import '../providers/category_provider.dart';

class CategoryEditScreen extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryEditScreen({Key? key, this.category}) : super(key: key);

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  int _selectedColor = 0xFF4CAF50;

  final List<int> _colors = [
    0xFF4CAF50, // Green
    0xFFF44336, // Red
    0xFF2196F3, // Blue
    0xFFFF9800, // Orange
    0xFF9C27B0, // Purple
    0xFF00BCD4, // Cyan
    0xFFFFEB3B, // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _emojiController = TextEditingController(text: widget.category?.emoji ?? '🛒');
    if (widget.category != null) {
      _selectedColor = widget.category!.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(categoryRepositoryProvider);
      final newCat = widget.category ?? Category(
        categoryId: const Uuid().v4(),
        name: _nameController.text,
        emoji: _emojiController.text,
        colorValue: _selectedColor,
      );

      if (widget.category != null) {
        newCat.name = _nameController.text;
        newCat.emoji = _emojiController.text;
        newCat.colorValue = _selectedColor;
      }

      await repository.saveCategory(newCat);
      ref.invalidate(categoriesProvider);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'New Category' : 'Edit Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _emojiController,
              decoration: const InputDecoration(labelText: 'Emoji'),
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveCategory,
              child: const Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }
}
