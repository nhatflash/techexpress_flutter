import 'package:flutter/material.dart';
import 'package:techexpress_flutter/components/toast_widget.dart';
import 'package:techexpress_flutter/models/user.dart';
import 'package:techexpress_flutter/services/user_service.dart';
import 'package:techexpress_flutter/screens/admin/user_form_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  final _userService = UserService();
  List<User> _users = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showToast(context, 'Tải thông tin người dùng thất bại $e');
      }
    }
  }

  List<User> get _staffUsers => _users.where((u) => u.salary != null).toList();
  List<User> get _customerUsers => _users.where((u) => u.salary == null).toList();

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Bạn có muốn xóa người dùng "${user.email}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _userService.deleteUser(user.id);
        _loadUsers();
        if (mounted) {
          showToast(context, 'Xóa người dùng thành công ${user.email}', isSuccess: true);
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Xoá người dùng thất bại $e');
        }
      }
    }
  }

  Future<void> _openStaffForm({User? user}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(user: user),
      ),
    );
    if (result == true) {
      _loadUsers();
    }
  }

  Widget _buildUserTable(List<User> users, {required bool isStaff}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) return const Center(child: Text('Không tìm thấy người dùng'));

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Email')),
            const DataColumn(label: Text('Tên')),
            const DataColumn(label: Text('Số điện thoại')),
            if (isStaff) const DataColumn(label: Text('Tiền lương')),
            const DataColumn(label: Text('Hành động')),
          ],
          rows: users.map((user) {
            return DataRow(cells: [
              DataCell(Text(user.email)),
              DataCell(Text('${user.firstName ?? ''} ${user.lastName ?? ''}'.trim())),
              DataCell(Text(user.phone ?? '-')),
              if (isStaff) DataCell(Text(user.salary?.toStringAsFixed(0) ?? '-')),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isStaff)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _openStaffForm(user: user),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deleteUser(user),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Người dùng', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openStaffForm(),
                icon: const Icon(Icons.add),
                label: const Text('Thêm nhân viên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: 'Nhân viên'),
              Tab(text: 'Khách hàng'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserTable(_staffUsers, isStaff: true),
                _buildUserTable(_customerUsers, isStaff: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
