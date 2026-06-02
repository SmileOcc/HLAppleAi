import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的评价')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildFilterBar(),
          const SizedBox(height: 16),
          ..._buildReviewList(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('全部', '12')),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(child: _buildStatItem('好评', '8')),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(child: _buildStatItem('中评', '2')),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(child: _buildStatItem('差评', '2')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['最近', '有图', '追评'];
    return Row(
      children: filters
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: f == '最近'
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: f == '最近' ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    color: f == '最近'
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  List<Widget> _buildReviewList() {
    return List.generate(3, (i) {
      final ratings = ['好评', '中评', '差评'];
      final colors = [AppColors.success, AppColors.warning, AppColors.error];
      final icons = [
        Icons.thumb_up_alt,
        Icons.remove_circle_outline,
        Icons.thumb_down_alt,
      ];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '商品${i + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '2024-05-${20 + i}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors[i].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icons[i], size: 12, color: colors[i]),
                      const SizedBox(width: 3),
                      Text(
                        ratings[i],
                        style: TextStyle(fontSize: 11, color: colors[i]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '商品质量很好，物流速度也很快，非常满意这次的购物体验。',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    });
  }
}
