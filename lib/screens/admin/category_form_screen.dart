import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/services/category_service.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryService = CategoryService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<Category> _parentCategories = [];
  String? _selectedParentId;
  bool _isLoading = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _loadParentCategories();
    if (_isEditing) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
      _imageUrlController.text = widget.category!.imageUrl ?? '';
      _selectedParentId = widget.category!.parentCategoryId;
    }
  }

  Future<void> _loadParentCategories() async {
    try {
      final categories = await _categoryService.getParentCategories();
      setState(() {
        _parentCategories = categories;
        if (_isEditing) {
          _parentCategories.removeWhere((c) => c.id == widget.category!.id);
        }
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'parentCategoryId': _selectedParentId,
        'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      };

      if (_isEditing) {
        await _categoryService.updateCategory(widget.category!.id, data);
      } else {
        await _categoryService.createCategory(data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        showToast(context, 'Lưu thất bại: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa danh mục' : 'Thêm danh mục'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Tên danh mục là bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Mô tả là bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Đường dẫn ảnh (tùy chọn)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                key: ValueKey(_parentCategories.length),
                initialValue: _parentCategories.any((c) => c.id == _selectedParentId) ? _selectedParentId : null,
                decoration: const InputDecoration(labelText: 'Danh mục cha (tùy chọn)', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Không')),
                  ..._parentCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (value) => setState(() => _selectedParentId = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEditing ? 'Chỉnh sửa' : 'Tạo mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
