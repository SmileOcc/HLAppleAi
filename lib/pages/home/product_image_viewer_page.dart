import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/toast_util.dart';

class ProductImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ProductImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ProductImageViewerPage> createState() => _ProductImageViewerPageState();
}

class _ProductImageViewerPageState extends State<ProductImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _downloadImage(String imageUrl) async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (!mounted) return;
      if (permission != PermissionState.authorized) {
        ToastUtil.showError(context, '需要相册权限');
        return;
      }

      ToastUtil.show(context, '正在下载...');

      final response = await http.get(Uri.parse(imageUrl));
      if (!mounted) return;
      if (response.statusCode != 200) {
        ToastUtil.showError(context, '下载失败');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(response.bodyBytes);

      await PhotoManager.editor.saveImageWithPath(
        file.path,
        title: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await file.delete();

      if (!mounted) return;
      ToastUtil.showSuccess(context, '已保存到相册');
    } catch (e) {
      if (!mounted) return;
      ToastUtil.showError(context, '保存失败：${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _showDownloadDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存图片'),
        content: const Text('是否将此图片保存到相册？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadImage(imageUrl);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1}/${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _ImageItem(
                imageUrl: widget.imageUrls[index],
                onLongPress: () => _showDownloadDialog(widget.imageUrls[index]),
                onSaveTap: () => _downloadImage(widget.imageUrls[index]),
              );
            },
          ),
          if (_isDownloading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ImageItem extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onLongPress;
  final VoidCallback onSaveTap;

  const _ImageItem({
    required this.imageUrl,
    required this.onLongPress,
    required this.onSaveTap,
  });

  @override
  State<_ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<_ImageItem> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isShowingSaveButton = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isShowingSaveButton = !_isShowingSaveButton;
              });
            },
            onLongPress: widget.onLongPress,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
        if (_isShowingSaveButton)
          Positioned(
            right: 24,
            bottom: 24,
            child: GestureDetector(
              onTap: widget.onSaveTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}
