import 'package:flutter/material.dart';
import 'package:techexpress_flutter/config/routes.dart';
import 'package:techexpress_flutter/models/user.dart';
import 'package:techexpress_flutter/services/api_service.dart';
import 'package:techexpress_flutter/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final api = ApiService();
      if (!api.hasToken) {
        final restored = await api.tryRestoreSession();
        if (!restored) return;
      }
      final user = await _userService.getProfile();
      if (mounted) setState(() => _user = user);
    } catch (_) {}
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Laptop',
      'icon': Icons.laptop,
      'subCategories': ['Gaming', 'Văn phòng', 'Đồ hoạ', 'Mỏng nhẹ'],
    },
    {
      'name': 'PC',
      'icon': Icons.desktop_windows,
      'subCategories': ['Gaming PC', 'Workstation', 'Mini PC'],
    },
    {
      'name': 'Linh kiện',
      'icon': Icons.memory,
      'subCategories': ['CPU', 'GPU', 'RAM', 'SSD', 'Mainboard', 'PSU', 'Case'],
    },
    {
      'name': 'Màn hình',
      'icon': Icons.monitor,
      'subCategories': ['Gaming', 'Văn phòng', 'Đồ hoạ', 'Cong'],
    },
    {
      'name': 'Phụ kiện',
      'icon': Icons.keyboard,
      'subCategories': ['Chuột', 'Bàn phím', 'Tai nghe', 'Webcam', 'Loa'],
    },
    {
      'name': 'Mạng',
      'icon': Icons.wifi,
      'subCategories': ['Router', 'Switch', 'Access Point', 'Mesh Wifi'],
    },
  ];

  bool _showCategories = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TechExpress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(_showCategories ? Icons.close : Icons.menu),
          onPressed: () {
            setState(() => _showCategories = !_showCategories);
          },
          tooltip: 'Danh mục',
        ),
        actions: [
          if (_user == null)
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Đăng nhập',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _user!.email,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: _user!.avatarImage != null
                        ? NetworkImage(_user!.avatarImage!)
                        : null,
                    child: _user!.avatarImage == null
                        ? const Icon(Icons.person, size: 18, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Center(
            child: Text(
              'Welcome',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          if (_showCategories)
            GestureDetector(
              onTap: () => setState(() => _showCategories = false),
              child: AnimatedOpacity(
                opacity: _showCategories ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(color: Colors.black54),
              ),
            ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Material(
                elevation: 4,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Danh mục sản phẩm',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    ..._categories.map((category) {
                      return ExpansionTile(
                        leading: Icon(category['icon'] as IconData, color: Colors.blueAccent),
                        title: Text(
                          category['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        children: (category['subCategories'] as List<String>).map((sub) {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(left: 72),
                            title: Text(sub),
                            onTap: () {
                              setState(() => _showCategories = false);
                              // TODO: navigate to product list filtered by sub-category
                            },
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
            crossFadeState: _showCategories
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
