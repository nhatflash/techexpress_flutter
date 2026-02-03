import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/brand.dart';
import 'package:techexpress_flutter/models/paginated_result.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class BrandService {
  final _api = ApiService();

  Future<PaginatedResult<Brand>> getBrands({
    String? searchName,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'Page': page,
    };
    if (searchName != null && searchName.isNotEmpty) {
      queryParams['SearchName'] = searchName;
    }

    final response = await _api.get(ApiConfig.brands, queryParams: queryParams);
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
    return PaginatedResult.fromJson(data['value'], Brand.fromJson);
  }

  Future<void> createBrand(Map<String, dynamic> data) async {
    await _api.post(ApiConfig.brands, data: data);
  }

  Future<void> updateBrand(String id, Map<String, dynamic> data) async {
    await _api.put('${ApiConfig.brands}/$id', data: data);
  }

  Future<void> deleteBrand(String id) async {
    await _api.delete('${ApiConfig.brands}/$id');
  }
}
