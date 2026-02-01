import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:techexpress_flutter/config/api_config.dart';
import 'package:techexpress_flutter/config/routes.dart';
import 'package:techexpress_flutter/constants/constant.dart';
import 'package:techexpress_flutter/errors/error_message.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final _storage = FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: { 'Content-Type': 'application/json' },
      )
    );

    // dev-only
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // interceptor for handling refresh token
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await getRefreshToken();
          if (refreshToken == null) {
            await deleteRefreshToken();
            clearToken();

            // Check if the user is on an authenticated screen
            String? currentRoute;
            Constant.navigatorKey.currentState?.popUntil((route) {
              currentRoute = route.settings.name;
              return true;
            });

            final isPublicRoute = currentRoute != null &&
                AppRoutes.publicRoutes.contains(currentRoute);

            if (!isPublicRoute) {
              Constant.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            }

            return handler.next(error);
          }
          final newAccessToken = await refresh(refreshToken);
          setToken(newAccessToken);
          final response = await _dio.fetch(error.requestOptions);
          return handler.resolve(response);
        }
      }
    ));
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  bool get hasToken => _dio.options.headers.containsKey('Authorization');

  Future<void> storeRefreshToken(String refreshToken) async {
    final data = jsonEncode({
      'token': refreshToken,
      'expiresAt': DateTime.now().add(Duration(days: 7)).toIso8601String(),
    });
    await _storage.write(key: 'refreshToken', value: data);
  }

  Future<String?> getRefreshToken() async {
    final raw = await _storage.read(key: 'refreshToken');
    if (raw == null) return null;
    
    final data = jsonDecode(raw);
    final expiresAt = DateTime.parse(data['expiresAt']);

    if (DateTime.now().isAfter(expiresAt)) {
      await deleteRefreshToken();
      return null;
    }
    return data['token'];
  }

  Future<bool> tryRestoreSession() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    try {
      await refresh(refreshToken);
      return true;
    } catch (_) {
      await deleteRefreshToken();
      clearToken();
      return false;
    }
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refreshToken');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, Object data) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }

  Future<String> refresh(String refreshToken) async {
    try {
      // Use a separate Dio instance to avoid triggering the interceptor
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ));
      (refreshDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
      final response = await refreshDio.post(ApiConfig.refresh, data: {
        'refreshToken': refreshToken,
      });
      final value = response.data['value'];
      setToken(value['accessToken']);
      return value['accessToken'];
    } on DioException catch (e) {
      throw ErrorMessage.fromDioException(e);
    }
  }
}