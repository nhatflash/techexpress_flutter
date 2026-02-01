import 'package:dio/dio.dart';
import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/errors/error_message.dart';
import 'package:techexpress_flutter/models/user.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class UserService {
  final _api = ApiService();

  
  Future<User> getProfile() async {
    try {
      final response = await _api.get(ApiConfig.profile);
      return User.fromJson(response.data['value']);
    } on DioException catch (e) {
      throw ErrorMessage.fromDioException(e);
    }
  }
}