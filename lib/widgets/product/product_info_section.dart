import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductInfoSection({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPrice()),
              _buildFavoriteButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildProductName(),
          const SizedBox(height: 8),
          _buildDescription(),
          const SizedBox(height: 12),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              '¥',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              product.price.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 28,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (product.originalPrice > product.price) ...[
          const SizedBox(height: 4),
          Text(
            '¥${product.originalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavoriteToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      product.description,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem(Icons.shopping_bag_outlined, '${product.sales}人付款'),
        const SizedBox(width: 24),
        _buildStatItem(
          Icons.star_outline,
          '${product.rating.toStringAsFixed(1)}分',
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          product.stock > 0
              ? Icons.check_circle_outline
              : Icons.remove_circle_outline,
          product.stock > 0 ? '有货' : '缺货',
          color: product.stock > 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
