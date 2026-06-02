import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class MiniProgramPage extends StatelessWidget {
  const MiniProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('小程序')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildRecentlyUsed(),
          const SizedBox(height: 20),
          _buildCategories(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          SizedBox(width: 8),
          Text(
            '搜索小程序',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyUsed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近使用',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMiniApp(
              Icons.shopping_cart_outlined,
              '购物助手',
              AppColors.primary,
            ),
            _buildMiniApp(
              Icons.restaurant_outlined,
              '美食外卖',
              const Color(0xFFE17055),
            ),
            _buildMiniApp(
              Icons.flight_outlined,
              '旅行预订',
              const Color(0xFF6C5CE7),
            ),
            _buildMiniApp(Icons.movie_outlined, '电影票', const Color(0xFF00B894)),
            _buildMiniApp(Icons.more_horiz, '更多', AppColors.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniApp(IconData icon, String label, Color color) {
    return GestureDetector(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': '购物', 'icon': Icons.shopping_bag_outlined, 'count': '12个'},
      {'name': '生活', 'icon': Icons.home_outlined, 'count': '8个'},
      {'name': '出行', 'icon': Icons.directions_car_outlined, 'count': '6个'},
      {'name': '餐饮', 'icon': Icons.restaurant_outlined, 'count': '10个'},
      {'name': '娱乐', 'icon': Icons.music_note_outlined, 'count': '7个'},
      {'name': '教育', 'icon': Icons.school_outlined, 'count': '5个'},
      {'name': '金融', 'icon': Icons.account_balance_outlined, 'count': '4个'},
      {'name': '工具', 'icon': Icons.build_outlined, 'count': '9个'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    cat['count'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
