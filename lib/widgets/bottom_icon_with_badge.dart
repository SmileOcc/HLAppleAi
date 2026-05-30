import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class BottomIconWithBadge extends StatelessWidget {
  final Widget icon;
  final String label;
  final int? badgeCount;
  final VoidCallback onTap;

  const BottomIconWithBadge({
    super.key,
    required this.icon,
    required this.label,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  badgeCount! > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
