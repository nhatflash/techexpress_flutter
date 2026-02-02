import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class CategoryService {
  final _api = ApiService();

  Future<List<Category>> getCategories() async {
    final response = await _api.get(ApiConfig.categories);
    final data = response.data;
    if (data['statusCode'] != 200) {
      return [];
    }
    final value = data['value'];
    final List<dynamic> items = value['items'] ?? [];

    return items.map((json) => Category.fromJson(json)).toList();
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

}