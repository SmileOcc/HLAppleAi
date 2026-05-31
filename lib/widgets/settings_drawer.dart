import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/services/mock_data_service.dart';
import '../core/constants/app_constants.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await MockDataService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMenuList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: _user != null
                ? CachedNetworkImageProvider(_user!['avatar'])
                : null,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            _user?['name'] ?? '未登录',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user != null ? 'ID: ${_user!['id']}' : '',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    final items = [
      _MenuItem(Icons.shopping_bag_outlined, '我的订单'),
      _MenuItem(Icons.favorite_border, '我的收藏'),
      _MenuItem(Icons.history, '浏览记录'),
      _MenuItem(Icons.card_giftcard_outlined, '优惠券'),
      _MenuItem(Icons.headset_mic_outlined, '客服中心'),
      _MenuItem(Icons.settings_outlined, '设置'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 56, endIndent: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(item.icon, color: AppColors.textPrimary),
          title: Text(item.label, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}
