import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  bool _isPhoneBound = true;
  bool _isEmailBound = false;
  bool _isWechatBound = true;
  bool _isAlipayBound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账户安全')),
      body: ListView(
        children: [
          _buildSecurityLevel(),
          const SizedBox(height: 20),
          _buildSectionHeader('账户绑定'),
          _buildBindItem(
            icon: Icons.phone_android,
            title: '手机绑定',
            subtitle: _isPhoneBound ? '138****8888' : '未绑定',
            isBound: _isPhoneBound,
            onTap: () => _showBindDialog('手机号'),
          ),
          _buildBindItem(
            icon: Icons.email_outlined,
            title: '邮箱绑定',
            subtitle: _isEmailBound ? 'user@example.com' : '未绑定',
            isBound: _isEmailBound,
            onTap: () => _showBindDialog('邮箱'),
          ),
          _buildBindItem(
            icon: Icons.chat,
            title: '微信绑定',
            subtitle: _isWechatBound ? '已绑定' : '未绑定',
            isBound: _isWechatBound,
            onTap: () => _showUnbindDialog('微信'),
          ),
          _buildBindItem(
            icon: Icons.payment,
            title: '支付宝绑定',
            subtitle: _isAlipayBound ? '已绑定' : '未绑定',
            isBound: _isAlipayBound,
            onTap: () => _showUnbindDialog('支付宝'),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('安全设置'),
          _buildSecurityItem(
            icon: Icons.lock_outline,
            title: '修改登录密码',
            onTap: () => _showChangePasswordDialog(),
          ),
          _buildSecurityItem(
            icon: Icons.password,
            title: '支付密码',
            subtitle: '未设置',
            onTap: () => _showSetPayPasswordDialog(),
          ),
          _buildSecurityItem(
            icon: Icons.fingerprint,
            title: '指纹解锁',
            onTap: () {},
          ),
          _buildSecurityItem(icon: Icons.face, title: '面容解锁', onTap: () {}),
          const SizedBox(height: 20),
          _buildSectionHeader('登录记录'),
          _buildLoginRecord(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSecurityLevel() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user, size: 48, color: AppColors.white),
          const SizedBox(height: 12),
          const Text(
            '账户安全等级：高',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSecurityBadge(true),
              _buildSecurityBadge(true),
              _buildSecurityBadge(true),
              _buildSecurityBadge(true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildBindItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isBound,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isBound ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(
            isBound ? '解绑' : '绑定',
            style: TextStyle(
              color: isBound ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLoginRecord() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          _buildRecordItem(
            device: 'iPhone 16',
            location: '深圳市',
            time: '今天 14:30',
            isCurrent: true,
          ),
          const Divider(),
          _buildRecordItem(
            device: 'MacBook Pro',
            location: '深圳市',
            time: '昨天 09:15',
            isCurrent: false,
          ),
          const Divider(),
          _buildRecordItem(
            device: 'iPhone 15',
            location: '北京市',
            time: '3天前',
            isCurrent: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem({
    required String device,
    required String location,
    required String time,
    required bool isCurrent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '当前',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$location · $time',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBindDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('绑定$type'),
        content: Text('是否跳转到绑定$type页面？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$type绑定功能开发中')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showUnbindDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('解绑$type'),
        content: Text('确定要解绑$type吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$type已解绑')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: const Text('是否跳转到修改密码页面？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('修改密码功能开发中')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSetPayPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置支付密码'),
        content: const Text('是否跳转到设置支付密码页面？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置支付密码功能开发中')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
