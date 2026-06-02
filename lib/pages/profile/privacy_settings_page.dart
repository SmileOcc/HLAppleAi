import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'privacy_policy_page.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _allowFindByPhone = true;
  bool _allowRecommend = false;
  bool _showOnlineStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('隐私权限'),
          _buildSwitchItem(
            Icons.person_search_outlined,
            '通过手机号找到我',
            _allowFindByPhone,
            (v) => setState(() => _allowFindByPhone = v),
          ),
          _buildSwitchItem(
            Icons.recommend_outlined,
            '个性化推荐',
            _allowRecommend,
            (v) => setState(() => _allowRecommend = v),
          ),
          _buildSwitchItem(
            Icons.circle_outlined,
            '展示在线状态',
            _showOnlineStatus,
            (v) => setState(() => _showOnlineStatus = v),
          ),
          const SizedBox(height: 20),
          _buildSection('更多设置'),
          _buildNavItem(
            Icons.privacy_tip_outlined,
            '隐私政策',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          _buildNavItem(Icons.block_outlined, '黑名单管理', () {}),
          _buildNavItem(Icons.download_outlined, '个人信息下载', () {}),
          _buildNavItem(
            Icons.delete_forever_outlined,
            '注销账户',
            () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注销账户'),
        content: const Text('注销后，您的所有数据将被清除且无法恢复，确认要注销账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('注销申请已提交，将在7天后生效')));
            },
            child: const Text('确认注销', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
