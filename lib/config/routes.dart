import 'package:flutter/material.dart';
import 'package:techexpress_flutter/screens/auth/login_screen.dart';
import 'package:techexpress_flutter/screens/auth/register_screen.dart';
import 'package:techexpress_flutter/screens/home/home_screen.dart';
import 'package:techexpress_flutter/screens/user/user_profile.dart';

class AppRoutes {
  static const login = '/signIn';
  static const register = '/signUp';
  static const home = '/';
  static const profile = '/profile';

  static const publicRoutes = {home, login, register};

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const UserProfileScreen(),
  };
}