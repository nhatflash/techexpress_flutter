import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/spec_definition.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class SpecDefinitionService {
  final _api = ApiService();

  Future<List<SpecDefinition>> getSpecDefinitionsByCategory(String categoryId) async {
    final queryParams = <String, dynamic>{
      'CategoryId': categoryId,
    };
    final response = await _api.get('${ApiConfig.categorySpecs}/$categoryId', queryParams: queryParams);
    final data = response.data;
    if (data['statusCode'] != 200) return [];
    final List<dynamic> items = data['value']['items'];
    return items.map((json) => SpecDefinition.fromJson(json)).toList();
  }

  Future<void> createSpecDefinition(Map<String, dynamic> data) async {
    await _api.post(ApiConfig.specDefinitions, data: data);
  }

  Future<void> updateSpecDefinition(String id, Map<String, dynamic> data) async {
    await _api.put('${ApiConfig.specDefinitions}/$id', data: data);
  }

  Future<void> deleteSpecDefinition(String id) async {
    await _api.delete('${ApiConfig.specDefinitions}/$id');
  }
}
