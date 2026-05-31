import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum EmptyStateType { empty, error }

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.empty,
    this.message = '',
    this.actionLabel,
    this.onAction,
  });

  const EmptyStateWidget.empty({
    super.key,
    this.message = '暂无商品',
    this.actionLabel,
    this.onAction,
    this.type = EmptyStateType.empty,
  });

  const EmptyStateWidget.error({
    super.key,
    this.message = '网络异常，请稍后重试',
    this.actionLabel = '重新加载',
    required this.onAction,
    this.type = EmptyStateType.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == EmptyStateType.empty
                  ? Icons.inventory_2_outlined
                  : Icons.wifi_off_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
