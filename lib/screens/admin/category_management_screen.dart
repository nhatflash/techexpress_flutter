import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/models/paginated_result.dart';
import 'package:techexpress_flutter/services/category_service.dart';
import 'package:techexpress_flutter/screens/admin/category_form_screen.dart';
import 'package:techexpress_flutter/screens/admin/category_detail_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _categoryService = CategoryService();
  final _searchController = TextEditingController();

  PaginatedResult<Category>? _result;
  List<Category> _parentCategories = [];
  bool _isLoading = true;
  int _currentPage = 1;
  String? _selectedParentId;
  bool? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadParentCategories();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParentCategories() async {
    try {
      final result = await _categoryService.getParentCategories();
      setState(() {
        _parentCategories = result;
      });
    } catch (_) {}
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final result = await _categoryService.getCategories(
        searchName: _searchController.text.trim(),
        parentId: _selectedParentId,
        isDeleted: _statusFilter,
        page: _currentPage,
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showToast(context, 'Tải danh mục thất bại: $e');
      }
    }
  }

  void _search() {
    _currentPage = 1;
    _loadCategories();
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedParentId = null;
    _statusFilter = null;
    _currentPage = 1;
    _loadCategories();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn có muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
        await _categoryService.deleteCategory(category.id);
        _loadCategories();
        if (mounted) {
          showToast(context, 'Xoá thành công ${category.name}', isSuccess: true);
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Xoá thất bại $e');
        }
      }
    }
  }

  Future<void> _openForm({Category? category}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(category: category),
      ),
    );
    if (result == true) {
      _loadCategories();
    }
  }

  String _getParentName(String? parentId) {
    if (parentId == null) return '-';
    final parent = _parentCategories.where((c) => c.id == parentId).firstOrNull;
    return parent?.name ?? '-';
  }

  void _openDetails(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          category: category,
          parentName: _getParentName(category.parentCategoryId),
          onEdit: () => _openForm(category: category),
          onDelete: () => _deleteCategory(category),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _result?.items ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text('Danh mục', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Thêm danh mục'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm tên',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedParentId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục cha',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    ..._parentCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedParentId = value);
                    _search();
                  },
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<bool?>(
                  initialValue: _statusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tất cả')),
                    DropdownMenuItem(value: false, child: Text('Đã xóa')),
                    DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value);
                    _search();
                  },
                ),
              ),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Xóa bộ lọc'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : categories.isEmpty
                    ? const Center(child: Text('Không tìm thấy danh mục'))
                    : SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 23,
                            columns: const [
                              DataColumn(label: Text('Tên')),
                              DataColumn(label: Text('Hành động')),
                            ],
                            rows: categories.map((category) {
                              return DataRow(cells: [
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    child: Text(
                                      category.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.visibility, size: 18, color: Colors.blueAccent),
                                        tooltip: 'Xem chi tiết',
                                        onPressed: () => _openDetails(category),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.edit, size: 18),
                                        tooltip: 'Chỉnh sửa',
                                        onPressed: () => _openForm(category: category),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                        tooltip: 'Xóa',
                                        onPressed: () => _deleteCategory(category),
                                      ),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),

          // Pagination
          if (_result != null && _result!.totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _result!.hasPreviousPage
                        ? () {
                            _currentPage--;
                            _loadCategories();
                          }
                        : null,
                  ),
                  Text('Trang $_currentPage trên ${_result!.totalPages}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _result!.hasNextPage
                        ? () {
                            _currentPage++;
                            _loadCategories();
                          }
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text('Tổng ${_result!.totalCount}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
