import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'activity_ad_debug_page.dart';
import 'app_upgrade_debug_page.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '调试面板',
          style: TextStyle(color: AppColors.white, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A2E),
            child: const Text(
              'DEBUG MODE',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          _buildEntry(
            context,
            icon: Icons.campaign,
            title: '活动广告调试',
            subtitle: '配置启动广告延迟、图片、文案',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActivityAdDebugPage()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _buildEntry(
            context,
            icon: Icons.system_update_rounded,
            title: 'APP升级弹窗调试',
            subtitle: '配置升级弹窗标题、版本、更新内容',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppUpgradeDebugPage()),
            ),
          ),
          const Divider(height: 1, indent: 56),
        ],
      ),
    );
  }

  Widget _buildEntry(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A1A2E)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
