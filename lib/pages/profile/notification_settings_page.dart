import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrateEnabled = true;
  bool _orderUpdate = true;
  bool _promotions = false;
  bool _systemNotice = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息通知')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('通知设置'),
          _buildSwitchItem(
            Icons.notifications_active_outlined,
            '推送通知',
            _pushEnabled,
            (v) => setState(() => _pushEnabled = v),
          ),
          _buildSwitchItem(
            Icons.volume_up_outlined,
            '声音',
            _soundEnabled,
            (v) => setState(() => _soundEnabled = v),
          ),
          _buildSwitchItem(
            Icons.vibration_outlined,
            '振动',
            _vibrateEnabled,
            (v) => setState(() => _vibrateEnabled = v),
          ),
          const SizedBox(height: 20),
          _buildSection('消息类型'),
          _buildSwitchItem(
            Icons.receipt_long_outlined,
            '订单更新通知',
            _orderUpdate,
            (v) => setState(() => _orderUpdate = v),
          ),
          _buildSwitchItem(
            Icons.local_offer_outlined,
            '促销活动通知',
            _promotions,
            (v) => setState(() => _promotions = v),
          ),
          _buildSwitchItem(
            Icons.info_outline,
            '系统公告',
            _systemNotice,
            (v) => setState(() => _systemNotice = v),
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
}
