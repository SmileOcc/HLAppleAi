import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ProductSpecSelector extends StatelessWidget {
  final List<String> colors;
  final List<String> sizes;
  final String? selectedColor;
  final String? selectedSize;
  final int quantity;
  final int maxQuantity;
  final ValueChanged<String>? onColorChanged;
  final ValueChanged<String>? onSizeChanged;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onSelectColor;
  final VoidCallback? onSelectSize;

  const ProductSpecSelector({
    super.key,
    required this.colors,
    required this.sizes,
    this.selectedColor,
    this.selectedSize,
    this.quantity = 1,
    this.maxQuantity = 99,
    this.onColorChanged,
    this.onSizeChanged,
    this.onQuantityChanged,
    this.onSelectColor,
    this.onSelectSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      child: Column(
        children: [
          if (colors.isNotEmpty) _buildColorSection(),
          if (colors.isNotEmpty && sizes.isNotEmpty)
            Divider(height: 1, color: AppColors.divider),
          if (sizes.isNotEmpty) _buildSizeSection(),
          Divider(height: 1, color: AppColors.divider),
          _buildQuantitySection(context),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return InkWell(
      onTap: onSelectColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              '颜色',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => onColorChanged?.call(color),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        color,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return InkWell(
      onTap: onSelectSize,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              '尺码',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sizes.map((size) {
                  final isSelected = selectedSize == size;
                  return GestureDetector(
                    onTap: () => onSizeChanged?.call(size),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '数量',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const Spacer(),
          _buildQuantityControls(context),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: quantity > 1
                ? () => onQuantityChanged?.call(quantity - 1)
                : null,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: quantity < maxQuantity
                ? () => onQuantityChanged?.call(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        color: onTap != null ? AppColors.white : AppColors.background,
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
