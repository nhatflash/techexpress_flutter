import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/config/routes.dart';
import 'package:techexpress_flutter/errors/error_message.dart';
import 'package:techexpress_flutter/models/category.dart';
import 'package:techexpress_flutter/models/user.dart';
import 'package:techexpress_flutter/services/api_service.dart';
import 'package:techexpress_flutter/services/category_service.dart';
import 'package:techexpress_flutter/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService();
  final _categoryService = CategoryService();
  List<Category> _categories = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async{
    await _loadProfile();
    await _loadCategories();
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
    } on ErrorMessage catch (_) {
      if (!mounted) return;
      showToast(context, 'Máy chủ hiện không khả dụng.');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) setState(() => _categories = categories);
    } on ErrorMessage catch (e) {
      // Don't show error for 401 (categories require auth, which is expected)
      if (e.statusCode != 401) {
        if (mounted) showToast(context, 'Không thể tải danh mục.');
      }
      // For 401, silently fail - categories will be empty for unauthenticated users
    }
  }

  // Get only parent categories (where parentCategoryId is null)
  List<Category> get _parentCategories {
    return _categories.where((cat) => cat.parentCategoryId == null).toList();
  }

  // Get subcategories for a specific parent category
  List<Category> _getSubCategories(String parentId) {
    return _categories.where((cat) => cat.parentCategoryId == parentId).toList();
  }

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
                    _user!.firstName ?? _user!.email,
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
                    if (_categories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có danh mục nào',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._parentCategories.map((parentCategory) {
                        final subCategories = _getSubCategories(parentCategory.id);
                        return ExpansionTile(
                          leading: parentCategory.imageUrl != null
                              ? Image.network(
                                  parentCategory.imageUrl!,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.blueAccent),
                                )
                              : const Icon(Icons.category, color: Colors.blueAccent),
                          title: Text(
                            parentCategory.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          children: subCategories.map((subCategory) {
                            return ListTile(
                              contentPadding: const EdgeInsets.only(left: 72),
                              leading: subCategory.imageUrl != null
                                  ? Image.network(
                                      subCategory.imageUrl!,
                                      width: 20,
                                      height: 20,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_right, size: 20),
                                    )
                                  : const Icon(Icons.arrow_right, size: 20),
                              title: Text(subCategory.name),
                              onTap: () {
                                setState(() => _showCategories = false);
                                // TODO: navigate to product list filtered by sub-category
                                // Use: subCategory.id
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
