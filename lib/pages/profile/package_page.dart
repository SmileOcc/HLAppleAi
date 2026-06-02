import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class PackagePage extends StatelessWidget {
  const PackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的包裹')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTabBar(),
          const SizedBox(height: 16),
          ..._buildPackageList(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['全部', '待签收', '运输中', '已签收'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: tabs
            .map(
              (t) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: t == '全部' ? AppColors.white : null,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: t == '全部'
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<Widget> _buildPackageList() {
    return [
      _buildPackageCard(
        'SF1234567890',
        '顺丰快递',
        '运输中',
        '预计明天 18:00 前送达',
        Icons.local_shipping,
      ),
      _buildPackageCard('YT9876543210', '圆通快递', '待签收', '已到达末端网点', Icons.inbox),
      _buildPackageCard(
        'ST4567890123',
        '申通快递',
        '已签收',
        '已签收 2024-05-30',
        Icons.check_circle,
      ),
      _buildPackageCard(
        'ZT7890123456',
        '中通快递',
        '运输中',
        '已到达中转站',
        Icons.local_shipping,
      ),
    ];
  }

  Widget _buildPackageCard(
    String trackingNo,
    String company,
    String status,
    String desc,
    IconData icon,
  ) {
    final statusColors = {
      '运输中': const Color(0xFF0984E3),
      '待签收': AppColors.warning,
      '已签收': AppColors.success,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (statusColors[status] ?? AppColors.primary).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: statusColors[status] ?? AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      company,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (statusColors[status] ?? AppColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColors[status] ?? AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '运单号: $trackingNo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
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
}
