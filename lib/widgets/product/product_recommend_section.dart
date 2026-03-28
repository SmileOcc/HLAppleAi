import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';

class ProductRecommendSection extends StatelessWidget {
  final List<Product> recommendProducts;
  final List<Product> hotProducts;
  final bool isLoading;
  final int currentTabIndex;
  final ValueChanged<int>? onTabChanged;

  const ProductRecommendSection({
    super.key,
    required this.recommendProducts,
    required this.hotProducts,
    this.isLoading = false,
    this.currentTabIndex = 0,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      child: Column(
        children: [
          _buildTabs(),
          Divider(height: 1, color: AppColors.divider),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab(0, '推荐', currentTabIndex == 0),
          const SizedBox(width: 24),
          _buildTab(1, '热卖', currentTabIndex == 1),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, bool isActive) {
    return GestureDetector(
      onTap: () => onTabChanged?.call(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final products = currentTabIndex == 0 ? recommendProducts : hotProducts;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text('暂无数据', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length > 6 ? 6 : products.length,
        itemBuilder: (context, index) {
          return _ProductRecommendItem(product: products[index]);
        },
      ),
    );
  }
}

class _ProductRecommendItem extends StatelessWidget {
  final Product product;

  const _ProductRecommendItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail', arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '¥${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${product.sales}人付款',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
