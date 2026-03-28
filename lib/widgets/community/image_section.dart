import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'image_preview_page.dart';

class ImageSection extends StatelessWidget {
  final List<String> selectedImages;
  final int maxImages;
  final ValueChanged<List<String>> onImagesChanged;
  final VoidCallback onAddImage;

  const ImageSection({
    super.key,
    required this.selectedImages,
    required this.maxImages,
    required this.onImagesChanged,
    required this.onAddImage,
  });

  void openPreview(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewPage(
          images: selectedImages,
          initialIndex: initialIndex,
          onDelete: (index) {
            final newImages = List<String>.from(selectedImages)
              ..removeAt(index);
            onImagesChanged(newImages);
          },
        ),
      ),
    );
  }

  void removeImage(int index) {
    final newImages = List<String>.from(selectedImages)..removeAt(index);
    onImagesChanged(newImages);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加图片',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (selectedImages.length < maxImages) _buildAddButton(context),
                ...selectedImages.asMap().entries.map((entry) {
                  return _buildImageItem(context, entry.key, entry.value);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedImages.length}/$maxImages',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddImage,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: AppColors.textSecondary,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              '添加图片',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, int index, String imagePath) {
    final bool isNetworkImage = imagePath.startsWith('http');

    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => openPreview(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : Image.file(
                      File(imagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.background,
      child: const Icon(
        Icons.broken_image,
        color: AppColors.textSecondary,
        size: 40,
      ),
    );
  }
}
