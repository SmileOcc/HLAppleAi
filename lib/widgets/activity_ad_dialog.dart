import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

typedef AdCloseCallback = void Function();

class ActivityAdConfig {
  final String title;
  final String description;
  final String imageUrl;
  final String? actionText;
  final VoidCallback? onAction;

  const ActivityAdConfig({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.actionText,
    this.onAction,
  });
}

class ActivityAdDialog extends StatelessWidget {
  final ActivityAdConfig config;
  final AdCloseCallback? onClose;

  final GlobalKey _closeKey = GlobalKey();

  ActivityAdDialog({super.key, required this.config, this.onClose});

  static Future<void> show(
    BuildContext context, {
    required ActivityAdConfig config,
    AdCloseCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ActivityAdDialog(config: config, onClose: onClose),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.82;
    final dialogHeight = screenSize.height * 0.55;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: dialogHeight),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildImage(),
            if (config.title.isNotEmpty) _buildTitle(),
            if (config.title.isNotEmpty && config.description.isNotEmpty)
              const SizedBox(height: 8),
            if (config.description.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _buildDescription(),
                ),
              ),
            if (config.actionText != null) _buildActionButton(context),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        config.imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: AppColors.primary.withValues(alpha: 0.08),
          child: const Icon(Icons.campaign, size: 64, color: AppColors.primary),
        ),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 180,
            color: AppColors.background,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        config.title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      config.description,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            config.onAction?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(config.actionText ?? '查看详情'),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: GestureDetector(
        onTap: () {
          onClose?.call();
          Navigator.pop(context);
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
