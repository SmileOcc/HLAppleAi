import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_util.dart';

class CustomImagePicker extends StatefulWidget {
  final int maxImages;
  final List<String> selectedImages;

  const CustomImagePicker({
    super.key,
    this.maxImages = 9,
    this.selectedImages = const [],
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  final List<AssetEntity> _allPhotos = [];
  final List<AssetEntity> _selectedAssets = [];
  final Set<String> _selectedAssetIds = {};
  final Set<String> _preSelectedPaths = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasPermission = false;
  int _currentPage = 0;
  bool _hasMore = true;
  final Map<String, Uint8List?> _thumbnailCache = {};
  final Map<String, Uint8List?> _fullImageCache = {};

  @override
  void initState() {
    super.initState();
    _preSelectedPaths.addAll(widget.selectedImages);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();
    setState(() {
      _hasPermission = permission.isAuth;
    });

    if (_hasPermission) {
      _loadPhotos();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPhotos() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      if (_currentPage == 0) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    if (albums.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final allAlbum = albums.firstWhere(
      (album) => album.isAll,
      orElse: () => albums.first,
    );

    final photos = await allAlbum.getAssetListPaged(
      page: _currentPage,
      size: 50,
    );

    if (photos.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final preselectedIds = <String>[];
    final preselectedAssets = <AssetEntity>[];

    for (final photo in photos) {
      if (_preSelectedPaths.isNotEmpty) {
        final file = await photo.file;
        if (file != null && _preSelectedPaths.contains(file.path)) {
          preselectedIds.add(photo.id);
          preselectedAssets.add(photo);
          _preSelectedPaths.remove(file.path);
        }
      }
    }

    setState(() {
      _allPhotos.addAll(photos);
      _selectedAssetIds.addAll(preselectedIds);
      _selectedAssets.addAll(preselectedAssets);
      _currentPage++;
      _isLoading = false;
      _isLoadingMore = false;
    });

    _preloadThumbnails(photos);
  }

  void _preloadThumbnails(List<AssetEntity> assets) {
    for (final asset in assets) {
      if (!_thumbnailCache.containsKey(asset.id)) {
        asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)).then((data) {
          if (mounted) {
            _thumbnailCache[asset.id] = data;
            setState(() {});
          }
        });
      }
    }
  }

  int get _remainingSlots => widget.maxImages - _selectedAssets.length;

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedAssetIds.contains(asset.id)) {
        _selectedAssetIds.remove(asset.id);
        _selectedAssets.removeWhere((a) => a.id == asset.id);
      } else {
        if (_selectedAssets.length >= widget.maxImages) {
          ToastUtil.show(context, '已达到最大选择数量 (${widget.maxImages} 张)');
          return;
        }
        _selectedAssetIds.add(asset.id);
        _selectedAssets.add(asset);
      }
    });
  }

  void _openPreview(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImagePreviewPage(
          allPhotos: _allPhotos,
          selectedAssets: List.from(_selectedAssets),
          selectedAssetIds: Set.from(_selectedAssetIds),
          initialIndex: initialIndex,
          maxImages: widget.maxImages,
          thumbnailCache: _thumbnailCache,
          fullImageCache: _fullImageCache,
          onSelectionChanged: (assets, ids) {
            setState(() {
              _selectedAssets.clear();
              _selectedAssets.addAll(assets);
              _selectedAssetIds.clear();
              _selectedAssetIds.addAll(ids);
            });
          },
        ),
      ),
    );
  }

  Future<void> _confirmSelection() async {
    final paths = <String>[];
    for (final asset in _selectedAssets) {
      final file = await asset.file;
      if (file != null) {
        paths.add(file.path);
      }
    }
    if (mounted) {
      Navigator.pop(context, paths);
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
        title: Text(
          '选择图片 (${_selectedAssets.length}/${widget.maxImages})',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedAssets.isEmpty ? null : _confirmSelection,
            child: Text(
              '完成',
              style: TextStyle(
                fontSize: 16,
                color: _selectedAssets.isEmpty
                    ? AppColors.textSecondary
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _hasPermission ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allPhotos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              '需要相册访问权限',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              '请在设置中开启相册访问权限',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('授予权限'),
            ),
          ],
        ),
      );
    }

    if (_allPhotos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              '相册为空',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            _loadPhotos();
          }
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _allPhotos.length + (_hasMore && _isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _allPhotos.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildPhotoItem(_allPhotos[index], index);
        },
      ),
    );
  }

  Widget _buildPhotoItem(AssetEntity asset, int index) {
    final isSelected = _selectedAssetIds.contains(asset.id);
    final selectedIndex = isSelected
        ? _selectedAssets.indexWhere((a) => a.id == asset.id) + 1
        : null;

    final cachedThumbnail = _thumbnailCache[asset.id];

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => _openPreview(index),
          child: cachedThumbnail != null
              ? Image.memory(cachedThumbnail, fit: BoxFit.cover)
              : FutureBuilder<Uint8List?>(
                  future: _thumbnailCache.containsKey(asset.id)
                      ? Future.value(_thumbnailCache[asset.id])
                      : asset
                            .thumbnailDataWithSize(
                              const ThumbnailSize(300, 300),
                            )
                            .then((data) {
                              _thumbnailCache[asset.id] = data;
                              return data;
                            }),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    }
                    return Container(
                      color: AppColors.divider,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (isSelected) Container(color: Colors.black.withValues(alpha: 0.3)),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => _toggleSelection(asset),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected && selectedIndex != null
                  ? Center(
                      child: Text(
                        '$selectedIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (!isSelected && _selectedAssets.length >= widget.maxImages)
          Container(color: Colors.black.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已选择 ${_selectedAssets.length} 张，还能选 $_remainingSlots 张',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (_selectedAssets.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedAssetIds.clear();
                    _selectedAssets.clear();
                  });
                },
                child: const Text(
                  '清空',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreviewPage extends StatefulWidget {
  final List<AssetEntity> allPhotos;
  final List<AssetEntity> selectedAssets;
  final Set<String> selectedAssetIds;
  final int initialIndex;
  final int maxImages;
  final Map<String, Uint8List?> thumbnailCache;
  final Map<String, Uint8List?> fullImageCache;
  final Function(List<AssetEntity>, Set<String>) onSelectionChanged;

  const _ImagePreviewPage({
    required this.allPhotos,
    required this.selectedAssets,
    required this.selectedAssetIds,
    required this.initialIndex,
    required this.maxImages,
    required this.thumbnailCache,
    required this.fullImageCache,
    required this.onSelectionChanged,
  });

  @override
  State<_ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;
  late List<AssetEntity> _selectedAssets;
  late Set<String> _selectedAssetIds;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _selectedAssets = List.from(widget.selectedAssets);
    _selectedAssetIds = Set.from(widget.selectedAssetIds);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedAssetIds.contains(asset.id)) {
        _selectedAssetIds.remove(asset.id);
        _selectedAssets.removeWhere((a) => a.id == asset.id);
      } else {
        if (_selectedAssets.length >= widget.maxImages) {
          ToastUtil.show(context, '已达到最大选择数量 (${widget.maxImages} 张)');
          return;
        }
        _selectedAssetIds.add(asset.id);
        _selectedAssets.add(asset);
      }
    });
    widget.onSelectionChanged(_selectedAssets, _selectedAssetIds);
  }

  Future<Uint8List?> _loadFullImage(AssetEntity asset) async {
    if (widget.fullImageCache.containsKey(asset.id)) {
      return widget.fullImageCache[asset.id];
    }
    final data = await asset.thumbnailDataWithSize(
      const ThumbnailSize(1080, 1920),
      quality: 95,
    );
    widget.fullImageCache[asset.id] = data;
    return data;
  }

  AssetEntity get _currentAsset => widget.allPhotos[_currentIndex];

  @override
  Widget build(BuildContext context) {
    final isSelected = _selectedAssetIds.contains(_currentAsset.id);
    final selectedIndex = isSelected
        ? _selectedAssets.indexWhere((a) => a.id == _currentAsset.id) + 1
        : null;

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
          '${_currentIndex + 1}/${widget.allPhotos.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _toggleSelection(_currentAsset),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.3),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected && selectedIndex != null
                  ? Center(
                      child: Text(
                        '$selectedIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allPhotos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final asset = widget.allPhotos[index];
                return _PreviewImageItem(
                  asset: asset,
                  fullImageCache: widget.fullImageCache,
                  onLoadFullImage: () => _loadFullImage(asset),
                );
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      color: Colors.black.withValues(alpha: 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '已选 ${_selectedAssets.length}/${widget.maxImages}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedAssetIds.clear();
                _selectedAssets.clear();
              });
              widget.onSelectionChanged(_selectedAssets, _selectedAssetIds);
            },
            child: const Text(
              '清空',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewImageItem extends StatefulWidget {
  final AssetEntity asset;
  final Map<String, Uint8List?> fullImageCache;
  final Future<Uint8List?> Function() onLoadFullImage;

  const _PreviewImageItem({
    required this.asset,
    required this.fullImageCache,
    required this.onLoadFullImage,
  });

  @override
  State<_PreviewImageItem> createState() => _PreviewImageItemState();
}

class _PreviewImageItemState extends State<_PreviewImageItem> {
  Uint8List? _imageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(_PreviewImageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.fullImageCache.containsKey(widget.asset.id)) {
      if (mounted) {
        setState(() {
          _imageData = widget.fullImageCache[widget.asset.id];
          _isLoading = false;
        });
      }
      return;
    }

    final data = await widget.onLoadFullImage();
    if (mounted) {
      setState(() {
        _imageData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_imageData == null) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(child: Image.memory(_imageData!, fit: BoxFit.contain)),
    );
  }
}
