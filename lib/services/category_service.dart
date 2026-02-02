import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/models/paginated_result.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class CategoryService {
  final _api = ApiService();

  Future<PaginatedResult<Category>> getCategories({
    String? searchName,
    String? parentId,
    bool? isDeleted,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'Page': page,
    };
    if (searchName != null && searchName.isNotEmpty) {
      queryParams['SearchName'] = searchName;
    }
    if (parentId != null) {
      queryParams['ParentId'] = parentId;
    }
    if (isDeleted != null) {
      queryParams['Status'] = isDeleted;
    }

    final response = await _api.get(ApiConfig.categories, queryParams: queryParams);
    final data = response.data;
    if (data['statusCode'] != 200) {
      return PaginatedResult(
        items: [],
        pageNumber: 1,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }
    return PaginatedResult.fromJson(data['value'], Category.fromJson);
  }

  Future<List<Category>> getCategoriesForUi() async {
    final response = await _api.get(ApiConfig.uiCategories);
    final data = response.data;
    if (data['statusCode'] != 200) {
      return [];
    }
    final List<dynamic> values = data['value'];
    return values.map((json) => Category.fromJson(json)).toList();
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    await _api.post(ApiConfig.categories, data: data);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _api.put('${ApiConfig.categories}/$id', data: data);
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete('${ApiConfig.categories}/$id');
  }
}
