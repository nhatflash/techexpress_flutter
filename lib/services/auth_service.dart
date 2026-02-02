import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/models/token.dart';
import 'package:techexpress_flutter/services/api_service.dart';

class AuthService {

  final _api = ApiService();

  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    await _api.post(ApiConfig.register, data: {
      'email': email,
      'password': password,
      'firstName': ?firstName,
      'lastName': ?lastName,
      'phone': ?phone,
    });
  }

  Future<Token> login(String email, String password) async {
    final existRefreshToken = await _api.getRefreshToken();
    if (existRefreshToken != null) {
      await _api.deleteRefreshToken();
    }
    final response = await _api.post(ApiConfig.login, data: {
      'email': email,
      'password': password
    });
    final value = response.data['value'];
    _api.setToken(value['accessToken']);
    await _api.storeRefreshToken(value['refreshToken']);
    return Token.fromJson(value);
  }
}