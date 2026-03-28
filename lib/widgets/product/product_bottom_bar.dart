import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ProductBottomBar extends StatelessWidget {
  final double totalPrice;
  final int quantity;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final bool isFromCommunity;

  const ProductBottomBar({
    super.key,
    required this.totalPrice,
    this.quantity = 1,
    this.onAddToCart,
    this.onBuyNow,
    this.isFromCommunity = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '合计',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '¥${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!isFromCommunity) ...[
            _buildButton(
              text: '加入购物车',
              icon: Icons.shopping_cart_outlined,
              onTap: onAddToCart,
              isPrimary: false,
            ),
            const SizedBox(width: 12),
          ],
          _buildButton(
            text: isFromCommunity ? '去购买' : '立即购买',
            icon: Icons.bolt,
            onTap: onBuyNow,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                )
              : null,
          color: isPrimary ? null : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: isPrimary ? null : Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
