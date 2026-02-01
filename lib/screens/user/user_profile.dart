import 'package:flutter/material.dart';
import 'package:techexpress_flutter/models/user.dart';
import 'package:techexpress_flutter/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _userService = UserService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getProfile();
      if (mounted) setState(() => _user = user);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Không thể tải thông tin'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user!.avatarImage != null
                            ? NetworkImage(_user!.avatarImage!)
                            : null,
                        child: _user!.avatarImage == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        [_user!.firstName, _user!.lastName]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(' '),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _user!.email,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard([
                        _infoRow(Icons.email_outlined, 'Email', _user!.email),
                        _infoRow(Icons.phone_outlined, 'Số điện thoại', _user!.phone),
                        _infoRow(Icons.person_outline, 'Giới tính', _user!.gender),
                        _infoRow(Icons.badge_outlined, 'CCCD/CMND', _user!.identity),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _infoRow(Icons.location_on_outlined, 'Địa chỉ', _user!.address),
                        _infoRow(Icons.map_outlined, 'Phường/Xã', _user!.ward),
                        _infoRow(Icons.location_city_outlined, 'Tỉnh/Thành phố', _user!.province),
                        _infoRow(Icons.markunread_mailbox_outlined, 'Mã bưu chính', _user!.postalCode),
                      ]),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        value ?? 'Chưa cập nhật',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
