import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/user.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class UserService {
  final _api = ApiService();

  Future<User> getProfile() async {
    final response = await _api.get(ApiConfig.profile);
    return User.fromJson(response.data['value']);
  }

  Future<List<User>> getUsers() async {
    final response = await _api.get(ApiConfig.users);
    final data = response.data;
    if (data['statusCode'] != 200) return [];
    final List<dynamic> items = data['value']['items'] ?? [];
    return items.map((json) => User.fromJson(json)).toList();
  }

  Future<User> getUserById(String id) async {
    final response = await _api.get('${ApiConfig.users}/$id');
    return User.fromJson(response.data['value']);
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await _api.post(ApiConfig.users, data: data);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _api.put('${ApiConfig.users}/$id', data: data);
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('${ApiConfig.users}/$id');
  }
}
