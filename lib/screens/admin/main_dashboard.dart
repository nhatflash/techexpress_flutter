import 'package:flutter/material.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({ super.key });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Admin dashboard',
          style: TextStyle(color: Colors.red),
        )
      )
    );
  }
}