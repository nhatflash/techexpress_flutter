import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/models/spec_definition.dart';
import 'package:techexpress_flutter/services/spec_definition_service.dart';

class SpecDefinitionFormScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final SpecDefinition? spec;

  const SpecDefinitionFormScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.spec,
  });

  @override
  State<SpecDefinitionFormScreen> createState() => _SpecDefinitionFormScreenState();
}

class _SpecDefinitionFormScreenState extends State<SpecDefinitionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specService = SpecDefinitionService();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _acceptValueType = 'Text';
  bool _isRequired = false;
  bool _isLoading = false;

  bool get _isEditing => widget.spec != null;

  static const _valueTypes = ['Text', 'Number', 'Decimal', 'Bool'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _codeController.text = widget.spec!.code;
      _nameController.text = widget.spec!.name;
      _unitController.text = widget.spec!.unit;
      _descriptionController.text = widget.spec!.description;
      _acceptValueType = widget.spec!.acceptValueType;
      _isRequired = widget.spec!.isRequired;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'code': _codeController.text.trim(),
        'name': _nameController.text.trim(),
        'categoryId': widget.categoryId,
        'unit': _unitController.text.trim(),
        'acceptValueType': _acceptValueType,
        'description': _descriptionController.text.trim(),
        'isRequired': _isRequired,
      };

      if (_isEditing) {
        await _specService.updateSpecDefinition(widget.spec!.id, data);
      } else {
        await _specService.createSpecDefinition(data);
      }

      if (mounted) {
        showToast(
          context,
          _isEditing ? 'Cập nhật thành công' : 'Tạo thành công',
          isSuccess: true,
        );
        Navigator.pop(context, true);
      }
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
    _codeController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa thông số kỹ thuật' : 'Thêm thông số kỹ thuật'),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danh mục',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              widget.categoryName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã thông số',
                  border: OutlineInputBorder(),
                  hintText: 'VD: RAM, CPU, STORAGE',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Mã là bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thông số',
                  border: OutlineInputBorder(),
                  hintText: 'VD: Dung lượng RAM, Bộ vi xử lý',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Tên là bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Đơn vị',
                  border: OutlineInputBorder(),
                  hintText: 'VD: GB, GHz, mAh',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _acceptValueType,
                decoration: const InputDecoration(
                  labelText: 'Loại giá trị',
                  border: OutlineInputBorder(),
                ),
                items: _valueTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _acceptValueType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Bắt buộc'),
                subtitle: const Text('Thông số này có bắt buộc nhập không?'),
                value: _isRequired,
                activeTrackColor: Colors.blueAccent.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.blueAccent;
                  }
                  return null;
                }),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() => _isRequired = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Cập nhật' : 'Tạo mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
