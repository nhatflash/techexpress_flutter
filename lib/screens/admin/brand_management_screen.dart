import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/models/brand.dart';
import 'package:techexpress_flutter/models/paginated_result.dart';
import 'package:techexpress_flutter/services/brand_service.dart';
import 'package:techexpress_flutter/screens/admin/brand_form_screen.dart';

class BrandManagementScreen extends StatefulWidget {
  const BrandManagementScreen({super.key});

  @override
  State<BrandManagementScreen> createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  final _brandService = BrandService();
  final _searchController = TextEditingController();

  PaginatedResult<Brand>? _result;
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoading = true);
    try {
      final result = await _brandService.getBrands(
        searchName: _searchController.text.trim(),
        page: _currentPage,
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showToast(context, 'Tải thương hiệu thất bại: $e');
      }
    }
  }

  void _search() {
    _currentPage = 1;
    _loadBrands();
  }

  void _clearFilters() {
    _searchController.clear();
    _currentPage = 1;
    _loadBrands();
  }

  Future<void> _deleteBrand(Brand brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thương hiệu'),
        content: Text('Bạn có muốn xóa thương hiệu "${brand.name}"?'),
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
        await _brandService.deleteBrand(brand.id);
        _loadBrands();
        if (mounted) {
          showToast(context, 'Xóa thành công ${brand.name}', isSuccess: true);
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Xóa thất bại: $e');
        }
      }
    }
  }

  Future<void> _openForm({Brand? brand}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BrandFormScreen(brand: brand),
      ),
    );
    if (result == true) {
      _loadBrands();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = _result?.items ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Thương hiệu', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Thêm thương hiệu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Xóa bộ lọc'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : brands.isEmpty
                    ? const Center(child: Text('Không tìm thấy thương hiệu'))
                    : SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('Tên')),
                              DataColumn(label: Text('Hành động')),
                            ],
                            rows: brands.map((brand) {
                              return DataRow(cells: [
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    child: Row(
                                      children: [
                                        if (brand.imageUrl != null && brand.imageUrl!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Image.network(
                                                brand.imageUrl!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            brand.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
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
                                        icon: const Icon(Icons.edit, size: 18),
                                        tooltip: 'Chỉnh sửa',
                                        onPressed: () => _openForm(brand: brand),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                        tooltip: 'Xóa',
                                        onPressed: () => _deleteBrand(brand),
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
                            _loadBrands();
                          }
                        : null,
                  ),
                  Text('Trang $_currentPage trên ${_result!.totalPages}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _result!.hasNextPage
                        ? () {
                            _currentPage++;
                            _loadBrands();
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
