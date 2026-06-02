import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/product.dart';
import 'file_section.dart';

class PostPreviewPage extends StatelessWidget {
  final String content;
  final List<String> images;
  final List<FileAttachment> files;
  final String? category;
  final Product? product;
  final List<String> topics;
  final String? location;

  const PostPreviewPage({
    super.key,
    required this.content,
    required this.images,
    this.files = const [],
    this.category,
    this.product,
    this.topics = const [],
    this.location,
  });

  String _getCategoryName() {
    final categories = [
      {'id': 'share', 'name': '晒物'},
      {'id': 'experience', 'name': '心得'},
      {'id': 'question', 'name': '问答'},
      {'id': 'discussion', 'name': '讨论'},
      {'id': 'activity', 'name': '活动'},
    ];
    final cat = categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => {'name': '分享'},
    );
    return cat['name'] ?? '分享';
  }

  IconData _fileIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.word:
        return Icons.description;
      case AttachmentType.pdf:
        return Icons.picture_as_pdf;
      case AttachmentType.excel:
        return Icons.table_chart;
      case AttachmentType.video:
        return Icons.videocam;
      case AttachmentType.ppt:
        return Icons.slideshow;
      case AttachmentType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _fileColor(AttachmentType type) {
    switch (type) {
      case AttachmentType.word:
        return const Color(0xFF2B579A);
      case AttachmentType.pdf:
        return const Color(0xFFE74C3C);
      case AttachmentType.excel:
        return const Color(0xFF27AE60);
      case AttachmentType.video:
        return const Color(0xFFE17055);
      case AttachmentType.ppt:
        return const Color(0xFFD24726);
      case AttachmentType.other:
        return AppColors.textSecondary;
    }
  }

  String _fileTypeLabel(AttachmentType type) {
    switch (type) {
      case AttachmentType.word:
        return 'Word 文档';
      case AttachmentType.pdf:
        return 'PDF 文档';
      case AttachmentType.excel:
        return 'Excel 表格';
      case AttachmentType.video:
        return '视频文件';
      case AttachmentType.ppt:
        return 'PPT 演示';
      case AttachmentType.other:
        return '其他文件';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '帖子预览',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
            if (images.isNotEmpty) _buildImageGrid(),
            if (files.isNotEmpty) _buildFilesSection(),
            if (product != null) _buildProductCard(),
            _buildTopicsAndLocation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '当前用户',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '刚刚发布',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getCategoryName(),
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (content.isEmpty) return const SizedBox.shrink();
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imagePath = images[index];
          final isNetworkImage = imagePath.startsWith('http');
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isNetworkImage
                ? CachedNetworkImage(imageUrl: imagePath, fit: BoxFit.cover)
                : Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFilesSection() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '附件',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...files.map(_buildFileItem),
        ],
      ),
    );
  }

  Widget _buildFileItem(FileAttachment file) {
    final color = _fileColor(file.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_fileIcon(file.type), color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _fileTypeLabel(file.type),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product!.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${product!.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsAndLocation() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          if (topics.isNotEmpty)
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (topics.isNotEmpty && location != null) const SizedBox(width: 8),
          if (location != null)
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 2),
                Text(
                  location!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
