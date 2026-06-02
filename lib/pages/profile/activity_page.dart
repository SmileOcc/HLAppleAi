import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(Icons.redeem, '限时秒杀', '每天10点准时开抢', '火热进行中', AppColors.primary),
      _Activity(
        Icons.weekend,
        '新人专享',
        '首单立减50元',
        '限新用户',
        const Color(0xFF4ECDC4),
      ),
      _Activity(
        Icons.local_fire_department,
        '热销爆款',
        '全场低至5折',
        '限量抢购',
        const Color(0xFFE17055),
      ),
      _Activity(
        Icons.group_add,
        '邀请有礼',
        '邀请好友得现金',
        '最高¥200',
        const Color(0xFF6C5CE7),
      ),
      _Activity(
        Icons.card_giftcard,
        '每日签到',
        '签到领积分',
        '连续签到有礼',
        AppColors.warning,
      ),
      _Activity(
        Icons.monetization_on,
        '积分商城',
        '积分兑换好物',
        '超值兑换',
        const Color(0xFF00B894),
      ),
      _Activity(
        Icons.flash_on,
        '品牌闪购',
        '大牌限时折扣',
        '即将开始',
        const Color(0xFF0984E3),
      ),
      _Activity(
        Icons.groups,
        '拼团优惠',
        '多人拼团更便宜',
        '热门拼团',
        const Color(0xFFFD79A8),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('活动中心')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final a = activities[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(a.icon, color: a.color, size: 24),
              ),
              title: Text(
                a.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  a.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  a.tag,
                  style: TextStyle(
                    fontSize: 11,
                    color: a.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Activity {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color color;
  const _Activity(this.icon, this.title, this.subtitle, this.tag, this.color);
}
