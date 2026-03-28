import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/product.dart';
import '../../data/services/mock_product_service.dart';
import '../../widgets/custom_image_picker.dart';

class CreatePostPage extends StatefulWidget {
  final int maxImages;

  const CreatePostPage({super.key, this.maxImages = 9});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _selectedImages = [];
  String? _selectedCategory;
  Product? _selectedProduct;
  final List<Product> _products = [];
  bool _isLoadingProducts = true;
  final List<String> _selectedTopics = [];
  static const int _maxTopics = 5;
  String? _selectedLocation;
  final ImagePicker _imagePicker = ImagePicker();

  int get _maxImages => widget.maxImages;
  int get _remainingSlots => _maxImages - _selectedImages.length;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'share', 'name': '晒物', 'icon': Icons.photo_camera},
    {'id': 'experience', 'name': '心得', 'icon': Icons.edit_note},
    {'id': 'question', 'name': '问答', 'icon': Icons.help_outline},
    {'id': 'discussion', 'name': '讨论', 'icon': Icons.forum},
    {'id': 'activity', 'name': '活动', 'icon': Icons.celebration},
  ];

  final List<Map<String, dynamic>> _topics = [
    {'id': '1', 'name': '#好物分享#', 'count': '2.3万'},
    {'id': '2', 'name': '#今日穿搭#', 'count': '1.8万'},
    {'id': '3', 'name': '#开箱测评#', 'count': '1.5万'},
    {'id': '4', 'name': '#省钱攻略#', 'count': '1.2万'},
    {'id': '5', 'name': '#购物心得#', 'count': '9800'},
    {'id': '6', 'name': '#新品上市#', 'count': '8600'},
    {'id': '7', 'name': '#限时优惠#', 'count': '7200'},
    {'id': '8', 'name': '#种草推荐#', 'count': '6500'},
  ];

  final List<Map<String, dynamic>> _locations = [
    {'id': '1', 'name': '北京市', 'district': '朝阳区'},
    {'id': '2', 'name': '上海市', 'district': '浦东新区'},
    {'id': '3', 'name': '广州市', 'district': '天河区'},
    {'id': '4', 'name': '深圳市', 'district': '南山区'},
    {'id': '5', 'name': '杭州市', 'district': '西湖区'},
    {'id': '6', 'name': '成都市', 'district': '锦江区'},
    {'id': '7', 'name': '南京市', 'district': '鼓楼区'},
    {'id': '8', 'name': '武汉市', 'district': '江汉区'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final service = MockProductService();
    final products = await service.getRecommendProducts();
    if (mounted) {
      setState(() {
        _products.addAll(products);
        _isLoadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
          onPressed: () => _showDiscardDialog(),
        ),
        title: const Text(
          '发帖',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showPreview,
            child: const Text(
              '预览',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '发布',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(),
            _buildProductSection(),
            _buildContentSection(),
            _buildImageSection(),
            _buildTopicSection(),
            _buildLocationSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择话题分类',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['id'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'],
                        size: 18,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '关联商品',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_selectedProduct != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProduct = null;
                    });
                  },
                  child: const Text(
                    '清除',
                    style: TextStyle(fontSize: 14, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedProduct != null) _buildSelectedProductCard(),
          if (_selectedProduct == null) _buildProductSelector(),
        ],
      ),
    );
  }

  Widget _buildSelectedProductCard() {
    return GestureDetector(
      onTap: _showProductPicker,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _selectedProduct!.image,
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
                    _selectedProduct!.name,
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
                    '¥${_selectedProduct!.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return GestureDetector(
      onTap: _showProductPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_link, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 8),
            Text(
              '添加关联商品',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分享内容',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 8,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: '说点什么...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
                if (_selectedImages.length < 9) _buildAddImageButton(),
                ..._selectedImages.asMap().entries.map((entry) {
                  return _buildImageItem(entry.key, entry.value);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedImages.length}/9',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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

  void _showImageSourceDialog() {
    if (_selectedImages.length >= _maxImages) {
      ToastUtil.show(context, '已达到最大选择数量 ($_maxImages 张)');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '已选择 ${_selectedImages.length}/$_maxImages 张',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickSingleImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: Text('从相册选择 (剩余 ${_remainingSlots} 张)'),
              onTap: () {
                Navigator.pop(context);
                _openCustomImagePicker();
              },
            ),
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleImage(ImageSource source) async {
    if (_selectedImages.length >= _maxImages) {
      ToastUtil.show(context, '已达到最大选择数量 ($_maxImages 张)');
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _openCustomImagePicker() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomImagePicker(
          maxImages: _maxImages,
          selectedImages: _selectedImages,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(result);
      });
    }
  }

  void _openImagePreview(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImagePreviewPage(
          images: List.from(_selectedImages),
          initialIndex: initialIndex,
          onDelete: (index) {
            setState(() {
              _selectedImages.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  void _showPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PostPreviewPage(
          content: _contentController.text,
          images: List.from(_selectedImages),
          category: _selectedCategory,
          product: _selectedProduct,
          topics: List.from(_selectedTopics),
          location: _selectedLocation,
        ),
      ),
    );
  }

  Widget _buildImageItem(int index, String imagePath) {
    final bool isNetworkImage = imagePath.startsWith('http');

    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _openImagePreview(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImagePlaceholder();
                      },
                    )
                  : Image.file(
                      File(imagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
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

  Widget _buildImagePlaceholder() {
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

  Widget _buildTopicSection() {
    return GestureDetector(
      onTap: _showTopicPicker,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tag, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  _selectedTopics.isEmpty ? '添加话题' : '已选话题',
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedTopics.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_selectedTopics.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTopics.clear();
                      });
                    },
                    child: const Text(
                      '清除',
                      style: TextStyle(fontSize: 14, color: AppColors.primary),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            if (_selectedTopics.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTopics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTopics.remove(topic);
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return GestureDetector(
      onTap: _showLocationPicker,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: _selectedLocation != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedLocation ?? '显示位置',
                style: TextStyle(
                  fontSize: 15,
                  color: _selectedLocation != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (_selectedLocation != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLocation = null;
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showTopicPicker() {
    final tempSelectedTopics = List<String>.from(_selectedTopics);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '选择话题 (${tempSelectedTopics.length}/$_maxTopics)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _topics.length,
                    itemBuilder: (context, index) {
                      final topic = _topics[index];
                      final isSelected = tempSelectedTopics.contains(
                        topic['name'],
                      );
                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          topic['name'],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          '${topic['count']} 参与',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              tempSelectedTopics.remove(topic['name']);
                            } else {
                              if (tempSelectedTopics.length < _maxTopics) {
                                tempSelectedTopics.add(topic['name']);
                              } else {
                                ToastUtil.show(
                                  context,
                                  '最多只能选择 $_maxTopics 个话题',
                                );
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Container(
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTopics.clear();
                          _selectedTopics.addAll(tempSelectedTopics);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择位置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  final fullLocation =
                      '${location['name']} ${location['district']}';
                  final isSelected = _selectedLocation == fullLocation;
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      location['name'],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      location['district'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLocation = fullLocation;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择关联商品',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return _buildProductGridItem(product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGridItem(Product product) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProduct = product;
        });
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
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
      ),
    );
  }

  void _showDiscardDialog() {
    if (_contentController.text.isEmpty &&
        _selectedImages.isEmpty &&
        _selectedProduct == null) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要放弃编辑吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ImagePreviewPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final Function(int) onDelete;

  const _ImagePreviewPage({
    required this.images,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  State<_ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

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

  void _deleteCurrentImage() {
    if (widget.images.length == 1) {
      widget.onDelete(0);
      Navigator.pop(context);
    } else {
      final deletedIndex = _currentIndex;
      setState(() {
        widget.images.removeAt(deletedIndex);
        if (_currentIndex >= widget.images.length) {
          _currentIndex = widget.images.length - 1;
        }
      });
      widget.onDelete(deletedIndex);
      if (widget.images.isEmpty) {
        Navigator.pop(context);
      }
    }
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
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _deleteCurrentImage,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '删除',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imagePath = widget.images[index];
          return _PreviewImageItem(imagePath: imagePath);
        },
      ),
    );
  }
}

class _PreviewImageItem extends StatelessWidget {
  final String imagePath;

  const _PreviewImageItem({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imagePath.startsWith('http');

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: isNetworkImage
            ? CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
      ),
    );
  }
}

class _PostPreviewPage extends StatelessWidget {
  final String content;
  final List<String> images;
  final String? category;
  final Product? product;
  final List<String> topics;
  final String? location;

  const _PostPreviewPage({
    required this.content,
    required this.images,
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
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryName(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildImageGrid(),
                  ],
                  if (product != null) ...[
                    const SizedBox(height: 12),
                    _buildProductCard(),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (topics.isNotEmpty) ...[
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
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
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
                        const SizedBox(width: 8),
                      ],
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
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionItem(Icons.thumb_up_outlined, '点赞'),
                  _buildActionItem(Icons.chat_bubble_outline, '评论'),
                  _buildActionItem(Icons.bookmark_border, '收藏'),
                  _buildActionItem(Icons.share_outlined, '分享'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '评论',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Center(
              child: Text(
                '暂无评论',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final imageCount = images.length;
    if (imageCount == 1) {
      return _buildSingleImage(images[0]);
    } else if (imageCount == 2) {
      return Row(
        children: images
            .map((img) => Expanded(child: _buildThumbnail(img)))
            .toList(),
      );
    } else if (imageCount == 4) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
        children: images.map((img) => _buildThumbnail(img)).toList(),
      );
    } else {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
        children: images.take(9).map((img) => _buildThumbnail(img)).toList(),
      );
    }
  }

  Widget _buildSingleImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: _buildImageWidget(imagePath),
      ),
    );
  }

  Widget _buildThumbnail(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(aspectRatio: 1, child: _buildImageWidget(imagePath)),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    final bool isNetworkImage = imagePath.startsWith('http');
    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.divider,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.divider,
          child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.divider,
          child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
        ),
      );
    }
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
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

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
