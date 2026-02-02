import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "https://localhost:7194/api";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "https://10.0.2.2:7194/api";
    } else {
      return "https://localhost:7194/api";
    }
  }

  static const String login = "/Auth/login";
  static const String register = "/Auth/register";
  static const String refresh = "/Auth/refresh";
  static const String profile = "/User/me";
  static const String categories = '/Category';

  static const publicApis = {
    login,
    register,
    refresh,
    categories
  };
}