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
  late TabController _tabController;

  List<User> _staffUsers = [];
  List<User> _customerUsers = [];
  bool _isLoadingStaff = true;
  bool _isLoadingCustomers = true;
  int _staffPage = 1;
  int _customerPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStaffs();
    _loadCustomers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStaffs() async {
    setState(() => _isLoadingStaff = true);
    try {
      final staffs = await _userService.getStaffs(_staffPage);
      setState(() {
        _staffUsers = staffs;
        _isLoadingStaff = false;
      });
    } catch (e) {
      setState(() => _isLoadingStaff = false);
      if (mounted) {
        showToast(context, 'Tải thông tin nhân viên thất bại: $e');
      }
    }
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final customers = await _userService.getCustomers(_customerPage);
      setState(() {
        _customerUsers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() => _isLoadingCustomers = false);
      if (mounted) {
        showToast(context, 'Tải thông tin khách hàng thất bại: $e');
      }
    }
  }

  Future<void> _deleteUser(User user, {required bool isStaff}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Bạn có muốn xóa người dùng "${user.email}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
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
        if (isStaff) {
          _loadStaffs();
        } else {
          _loadCustomers();
        }
        if (mounted) {
          showToast(context, 'Xóa người dùng thành công ${user.email}', isSuccess: true);
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Xoá người dùng thất bại: $e');
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
      _loadStaffs();
    }
  }

  Widget _buildStaffTab() {
    return Column(
      children: [
        Expanded(child: _buildUserTable(_staffUsers, isStaff: true, isLoading: _isLoadingStaff)),
        _buildPagination(
          currentPage: _staffPage,
          onPrevious: _staffPage > 1
              ? () {
                  _staffPage--;
                  _loadStaffs();
                }
              : null,
          onNext: _staffUsers.isNotEmpty
              ? () {
                  _staffPage++;
                  _loadStaffs();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildCustomerTab() {
    return Column(
      children: [
        Expanded(child: _buildUserTable(_customerUsers, isStaff: false, isLoading: _isLoadingCustomers)),
        _buildPagination(
          currentPage: _customerPage,
          onPrevious: _customerPage > 1
              ? () {
                  _customerPage--;
                  _loadCustomers();
                }
              : null,
          onNext: _customerUsers.isNotEmpty
              ? () {
                  _customerPage++;
                  _loadCustomers();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPagination({
    required int currentPage,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text('Trang $currentPage'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<User> users, {required bool isStaff, required bool isLoading}) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
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
                      tooltip: 'Chỉnh sửa',
                      onPressed: () => _openStaffForm(user: user),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Xóa',
                    onPressed: () => _deleteUser(user, isStaff: isStaff),
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
                _buildStaffTab(),
                _buildCustomerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
