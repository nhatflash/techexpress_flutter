import 'package:flutter/material.dart';
import 'package:techexpress_flutter/screens/admin/dashboard_home.dart';
import 'package:techexpress_flutter/screens/admin/category_management_screen.dart';
import 'package:techexpress_flutter/screens/admin/brand_management_screen.dart';
import 'package:techexpress_flutter/screens/admin/user_management_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(),
    CategoryManagementScreen(),
    BrandManagementScreen(),
    UserManagementScreen(),
  ];

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.category_outlined),
      selectedIcon: Icon(Icons.category),
      label: Text('Danh mục'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.branding_watermark_outlined),
      selectedIcon: Icon(Icons.branding_watermark),
      label: Text('Thương hiệu'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: Text('Người dùng'),
    ),
  ];

  static const _titles = ['Dashboard', 'Danh mục', 'Thương hiệu', 'Người dùng'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.05),
            selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
            selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            indicatorColor: Colors.blueAccent.withValues(alpha: 0.15),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.admin_panel_settings, size: 32, color: Colors.blueAccent),
            ),
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
