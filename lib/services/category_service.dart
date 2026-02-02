import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class CategoryService {
  final _api = ApiService();

  Future<List<Category>> getCategories() async {
    final response = await _api.get(ApiConfig.categories);
    final data = response.data;

    // Check if the response is successful
    if (data['statusCode'] != 200) {
      return [];
    }

    // Extract items from paginated response
    final value = data['value'];
    final List<dynamic> items = value['items'] ?? [];

    // Return first 20 categories (first page)
    return items.map((json) => Category.fromJson(json)).toList();
  }


}