import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techexpress_flutter/config/routes.dart';
import 'package:techexpress_flutter/constants/constant.dart';
import 'package:techexpress_flutter/providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider())
    ],
    child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      navigatorKey: Constant.navigatorKey,
    );
  }
}
