import 'package:flutter/material.dart';
import 'package:techexpress_flutter/models/category.dart';

class CategoryDetailScreen extends StatelessWidget {
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
              onEdit();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Xóa',
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    category.imageUrl!,
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
            _buildInfoRow('Tên', category.name),
            const Divider(height: 24),
            _buildInfoRow('Mô tả', category.description.isNotEmpty ? category.description : '-'),
            const Divider(height: 24),
            _buildInfoRow('Danh mục cha', parentName),
            const Divider(height: 24),
            _buildInfoRow(
              'Trạng thái',
              category.isDeleted ? 'Đã xóa' : 'Đang hoạt động',
              valueColor: category.isDeleted ? Colors.red : Colors.green,
            ),
            const Divider(height: 24),
            _buildInfoRow('Thêm từ', _formatDate(category.createdAt)),
            const Divider(height: 24),
            _buildInfoRow('Chỉnh sửa từ', _formatDate(category.updatedAt)),
          ],
        ),
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
