import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/models/spec_definition.dart';
import 'package:techexpress_flutter/services/spec_definition_service.dart';
import 'package:techexpress_flutter/screens/admin/spec_definition_form_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  final String parentName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.parentName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _specService = SpecDefinitionService();
  List<SpecDefinition> _specDefinitions = [];
  bool _isLoadingSpecs = true;

  @override
  void initState() {
    super.initState();
    _loadSpecDefinitions();
  }

  Future<void> _loadSpecDefinitions() async {
    setState(() => _isLoadingSpecs = true);
    try {
      final specs = await _specService.getSpecDefinitionsByCategory(widget.category.id);
      setState(() {
        _specDefinitions = specs;
        _isLoadingSpecs = false;
      });
    } catch (e) {
      setState(() => _isLoadingSpecs = false);
      if (mounted) {
        showToast(context, 'Tải thông số kỹ thuật thất bại: $e');
      }
    }
  }

  Future<void> _deleteSpec(SpecDefinition spec) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông số'),
        content: Text('Bạn có muốn xóa thông số "${spec.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _specService.deleteSpecDefinition(spec.id);
        _loadSpecDefinitions();
        if (mounted) {
          showToast(context, 'Xóa thành công ${spec.name}', isSuccess: true);
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Xóa thất bại: $e');
        }
      }
    }
  }

  Future<void> _openSpecForm({SpecDefinition? spec}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SpecDefinitionFormScreen(
          categoryId: widget.category.id,
          categoryName: widget.category.name,
          spec: spec,
        ),
      ),
    );
    if (result == true) {
      _loadSpecDefinitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết danh mục'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Sửa',
            onPressed: () {
              Navigator.pop(context);
              widget.onEdit();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Xóa',
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.category.imageUrl != null && widget.category.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.category.imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 24),
            _buildSpecDefinitionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên', widget.category.name),
            const Divider(height: 24),
            _buildInfoRow('Mô tả', widget.category.description.isNotEmpty ? widget.category.description : '-'),
            const Divider(height: 24),
            _buildInfoRow('Danh mục cha', widget.parentName),
            const Divider(height: 24),
            _buildInfoRow(
              'Trạng thái',
              widget.category.isDeleted ? 'Đã xóa' : 'Đang hoạt động',
              valueColor: widget.category.isDeleted ? Colors.red : Colors.green,
            ),
            const Divider(height: 24),
            _buildInfoRow('Thêm từ', _formatDate(widget.category.createdAt)),
            const Divider(height: 24),
            _buildInfoRow('Chỉnh sửa từ', _formatDate(widget.category.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecDefinitionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Thông số kỹ thuật',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openSpecForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingSpecs)
          const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ))
        else if (_specDefinitions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Chưa có thông số kỹ thuật nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _specDefinitions.length,
            itemBuilder: (context, index) => _buildSpecCard(_specDefinitions[index]),
          ),
      ],
    );
  }

  Widget _buildSpecCard(SpecDefinition spec) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    spec.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Sửa',
                    onPressed: () => _openSpecForm(spec: spec),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    tooltip: 'Xóa',
                    onPressed: () => _deleteSpec(spec),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSpecInfoRow('Mã', spec.code),
            _buildSpecInfoRow('Đơn vị', spec.unit.isNotEmpty ? spec.unit : '-'),
            _buildSpecInfoRow('Loại giá trị', spec.acceptValueType),
            _buildSpecInfoRow('Mô tả', spec.description.isNotEmpty ? spec.description : '-'),
            _buildSpecInfoRow(
              'Bắt buộc',
              spec.isRequired ? 'Có' : 'Không',
              valueColor: spec.isRequired ? Colors.orange : null,
            ),
            _buildSpecInfoRow(
              'Trạng thái',
              spec.isDeleted ? 'Đã xóa' : 'Đang hoạt động',
              valueColor: spec.isDeleted ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
