import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/product.dart';
import '../../data/services/mock_product_service.dart';
import '../../data/services/mock_rich_text_service.dart';
import '../../widgets/community/community.dart';
import '../../widgets/custom_image_picker.dart';
import '../../widgets/rich_text_editor.dart';

class CreatePostPage extends StatefulWidget {
  final int maxImages;

  const CreatePostPage({super.key, this.maxImages = 9});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late QuillController _quillController;
  final List<String> _selectedImages = [];
  String? _selectedCategory;
  Product? _selectedProduct;
  final List<Product> _products = [];
  bool _isLoadingProducts = true;
  final List<String> _selectedTopics = [];
  static const int _maxTopics = 5;
  String? _selectedLocation;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPublishing = false;

  int get _maxImages => widget.maxImages;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
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
    _quillController.dispose();
    super.dispose();
  }

  String _getPlainText() {
    return _quillController.document.toPlainText();
  }

  String _getDeltaJson() {
    return jsonEncode(_quillController.document.toDelta().toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySection(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            ProductSection(
              selectedProduct: _selectedProduct,
              products: _products,
              isLoading: _isLoadingProducts,
              onSelect: _showProductPicker,
              onClear: () => setState(() => _selectedProduct = null),
            ),
            _buildContentSection(),
            ImageSection(
              selectedImages: _selectedImages,
              maxImages: _maxImages,
              onImagesChanged: (images) {
                setState(() {
                  _selectedImages.clear();
                  _selectedImages.addAll(images);
                });
              },
              onAddImage: _showImageSourceDialog,
            ),
            TopicSection(
              selectedTopics: _selectedTopics,
              maxTopics: _maxTopics,
              onTopicsChanged: (topics) {
                setState(() {
                  _selectedTopics.clear();
                  _selectedTopics.addAll(topics);
                });
              },
            ),
            LocationSection(
              selectedLocation: _selectedLocation,
              onLocationChanged: (location) {
                setState(() => _selectedLocation = location);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimary),
        onPressed: _showDiscardDialog,
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
        _buildPublishButton(),
      ],
    );
  }

  Widget _buildPublishButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: _isPublishing
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : GestureDetector(
              onTap: _publishPost,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
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
          Row(
            children: [
              const Text(
                '分享内容',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _insertProductCard,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '插入商品卡片',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichTextEditor(
            controller: _quillController,
            maxLength: 2000,
            hintText: '说点什么...',
            minHeight: 150,
            maxHeight: 250,
          ),
        ],
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
      builder: (context) => _ImageSourceSheet(
        remainingSlots: _maxImages - _selectedImages.length,
        onCamera: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _openCustomImagePicker();
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= _maxImages) return;

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImages.add(image.path));
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

  void _showProductPicker() {
    ProductPicker.show(
      context: context,
      products: _products,
      isLoading: _isLoadingProducts,
      selectedProduct: _selectedProduct,
      onProductSelected: (product) {
        setState(() => _selectedProduct = product);
      },
    );
  }

  void _showPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostPreviewPage(
          content: _getPlainText(),
          deltaJson: _getDeltaJson(),
          images: List.from(_selectedImages),
          category: _selectedCategory,
          product: _selectedProduct,
          topics: List.from(_selectedTopics),
          location: _selectedLocation,
        ),
      ),
    );
  }

  void _insertProductCard() {
    if (_selectedProduct == null) {
      ToastUtil.show(context, '请先关联商品');
      _showProductPicker();
      return;
    }

    final index = _quillController.selection.baseOffset;
    final productCard =
        '\n【商品】${_selectedProduct!.name} - ¥${_selectedProduct!.price.toStringAsFixed(2)}\n';

    _quillController.document.insert(index, productCard);
    _quillController.updateSelection(
      TextSelection.collapsed(offset: index + productCard.length),
      ChangeSource.local,
    );

    ToastUtil.show(context, '已插入商品卡片');
  }

  void _showDiscardDialog() {
    if (_getPlainText().isEmpty &&
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

  Future<void> _publishPost() async {
    if (_getPlainText().trim().isEmpty) {
      ToastUtil.show(context, '请输入内容');
      return;
    }

    if (_selectedCategory == null) {
      ToastUtil.show(context, '请选择话题分类');
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final service = MockRichTextService();
      await service.createPost(
        content: _getPlainText(),
        deltaJson: _getDeltaJson(),
        images: _selectedImages,
        category: _selectedCategory,
        topics: _selectedTopics,
        location: _selectedLocation,
        linkedProductId: _selectedProduct?.id.toString(),
      );

      if (mounted) {
        ToastUtil.show(context, '发布成功');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.show(context, '发布失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final int remainingSlots;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ImageSourceSheet({
    required this.remainingSlots,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              '已选择 0/$remainingSlots 张',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
            title: const Text('拍照'),
            onTap: onCamera,
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.primary),
            title: Text('从相册选择 (剩余 $remainingSlots 张)'),
            onTap: onGallery,
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
    );
  }
}
