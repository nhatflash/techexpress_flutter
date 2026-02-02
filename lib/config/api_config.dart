import 'dart:io';

class ApiConfig {
  // Platform-specific base URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host machine
      return "https://10.0.2.2:7194/api";
    } else {
      // iOS Simulator and other platforms use localhost
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