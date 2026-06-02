import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<_Task> _dailyTasks = [
    _Task('每日签到', '签到领积分', Icons.calendar_today, 30, 30, true),
    _Task('浏览商品', '浏览5件商品', Icons.search, 20, 20, true),
    _Task('收藏商品', '收藏3件商品', Icons.favorite_border, 15, 9, false),
    _Task('分享商品', '分享1件商品给好友', Icons.share, 10, 0, false),
  ];

  final List<_Task> _achievements = [
    _Task('首次购物', '完成第一笔订单', Icons.shopping_bag, 100, 100, true),
    _Task('发表评价', '评价5件商品', Icons.rate_review, 50, 30, false),
    _Task('邀请好友', '邀请3位好友注册', Icons.person_add, 200, 1, false),
    _Task('连续签到7天', '坚持每日签到', Icons.local_fire_department, 500, 3, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('任务中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildScoreCard(),
          const SizedBox(height: 20),
          _buildSection('每日任务', _dailyTasks),
          const SizedBox(height: 20),
          _buildSection('成就徽章', _achievements),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的积分',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                '1,250',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '积分明细',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...tasks.map(
          (task) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: task.completed
                      ? const Color(0xFF00B894).withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  task.icon,
                  color: task.completed
                      ? const Color(0xFF00B894)
                      : AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                task.desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${task.reward}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: task.completed
                          ? const Color(0xFF00B894)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(
                      value: task.progress / task.target,
                      backgroundColor: AppColors.divider,
                      color: task.completed
                          ? const Color(0xFF00B894)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Task {
  final String title;
  final String desc;
  final IconData icon;
  final int reward;
  final int progress;
  final int target;
  final bool completed;

  _Task(
    this.title,
    this.desc,
    this.icon,
    this.reward,
    this.progress,
    this.completed,
  ) : target = reward;
}
