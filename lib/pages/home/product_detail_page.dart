import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/product.dart';
import '../../data/services/mock_product_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/bottom_icon_with_badge.dart';
import '../../widgets/image_viewer_page.dart';
import '../../widgets/product_attribute_sheet.dart';
import '../../widgets/share/share_dialog.dart';
import '../cart/cart_page.dart';
import '../checkout/checkout_page.dart';
import 'review_list_page.dart';
import '../community/post_detail_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  String? _selectedColor;
  String? _selectedSize;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;
  bool _showDescExpandButton = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  List<Product> _recommendProducts = [];
  bool _isLoading = true;

  final List<Map<String, String>> _guarantees = [
    {'icon': 'verified', 'text': '正品保证'},
    {'icon': 'assignment_return', 'text': '七天无理由'},
    {'icon': 'local_shipping', 'text': '包邮'},
    {'icon': 'shield', 'text': '品质保障'},
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      'user': '张三',
      'avatar': 'https://picsum.photos/100/100?random=1',
      'rating': 5.0,
      'content': '非常好用，质量很棒，物流也很快！',
      'images': [
        'https://picsum.photos/200/200?random=10',
        'https://picsum.photos/200/200?random=11',
        'https://picsum.photos/200/200?random=12',
        'https://picsum.photos/200/200?random=13',
        'https://picsum.photos/200/200?random=14',
        'https://picsum.photos/200/200?random=15',
        'https://picsum.photos/200/200?random=16',
        'https://picsum.photos/200/200?random=17',
        'https://picsum.photos/200/200?random=18',
      ],
      'time': '2024-01-15',
    },
    {
      'user': '李四',
      'avatar': 'https://picsum.photos/100/100?random=2',
      'rating': 4.5,
      'content': '性价比很高，推荐购买！',
      'images': ['https://picsum.photos/200/200?random=20'],
      'time': '2024-01-14',
    },
    {
      'user': '王五',
      'avatar': 'https://picsum.photos/100/100?random=3',
      'rating': 4.0,
      'content': '整体不错，就是包装有点简陋。',
      'images': [],
      'time': '2024-01-13',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelections();
      _loadProducts();
      _checkDescriptionLength();
    });
    _scrollController.addListener(_onScroll);
  }

  void _checkDescriptionLength() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.product.description,
        style: const TextStyle(fontSize: 14, height: 1.6),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    );
    final maxWidth = MediaQuery.of(context).size.width - 32;
    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.didExceedMaxLines) {
      setState(() => _showDescExpandButton = true);
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200) {
      if (!_showAppBarTitle) {
        setState(() => _showAppBarTitle = true);
      }
    } else {
      if (_showAppBarTitle) {
        setState(() => _showAppBarTitle = false);
      }
    }
  }

  void _initializeSelections() {
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
  }

  Future<void> _loadProducts() async {
    final service = MockProductService();
    final products = await service.getRecommendProducts();
    if (mounted) {
      setState(() {
        _recommendProducts = products.take(10).toList();
        _isLoading = false;
      });
    }
  }

  void _showShareDialog() {
    ShareDialog.show(
      context,
      title: widget.product.name,
      desc: widget.product.description,
      imageUrl: widget.product.image,
      link: 'https://hlapple.com/product/${widget.product.id}',
      firstRowPlatforms: [
        SharePlatform.wechat,
        SharePlatform.wechatMoment,
        SharePlatform.weibo,
        SharePlatform.qq,
      ],
      secondRowPlatforms: [SharePlatform.copyLink],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final discount =
        ((widget.product.originalPrice - widget.product.price) /
                widget.product.originalPrice *
                100)
            .toStringAsFixed(0);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildImageSlider(),
                SliverToBoxAdapter(child: _buildPriceSection(discount)),
                SliverToBoxAdapter(child: _buildDescriptionSection()),
                SliverToBoxAdapter(child: _buildTitleSection()),
                SliverToBoxAdapter(child: _buildSpecSection()),
                SliverToBoxAdapter(child: _buildGuaranteeSection()),
                SliverToBoxAdapter(child: _buildReviewSection()),
                SliverToBoxAdapter(child: _buildDetailSection()),
                SliverToBoxAdapter(child: _buildRecommendSection(l10n)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          _buildBottomBar(l10n),
        ],
      ),
      appBar: AppBar(
        backgroundColor: _showAppBarTitle
            ? AppColors.white
            : Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          _buildAppBarIconWithBadge(Icons.chat_bubble_outline, 3, () {}),
          _buildAppBarIconWithBadge(Icons.share, 0, _showShareDialog),
        ],
        title: _showAppBarTitle
            ? Text(
                widget.product.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _buildImageSlider() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: false,
      backgroundColor: AppColors.white,
      toolbarHeight: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: 5,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageViewerPage(
                          imageUrls: _getImageUrls(),
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: widget.product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/5',
                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(String discount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              Text(
                widget.product.price.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '省${discount}%',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '¥${widget.product.originalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                '包邮',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: AppColors.white,
      child: _isDescriptionExpanded
          ? Stack(
              children: [
                Text(
                  widget.product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isDescriptionExpanded = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      color: AppColors.white,
                      child: const Text(
                        '收起',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Text(
                  widget.product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                if (_showDescExpandButton)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isDescriptionExpanded = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        color: AppColors.white,
                        child: const Text(
                          '展开',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag('新品', AppColors.primary),
              const SizedBox(width: 8),
              _buildTag('正品', AppColors.success),
              const SizedBox(width: 8),
              _buildTag('热销', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpecSection() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => _showAttributeSheet(),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        color: AppColors.white,
        child: Row(
          children: [
            const Text(
              '已选',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_selectedColor ?? '请选择颜色'}，${_selectedSize ?? '请选择规格'}，x$_quantity',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _guarantees.map((item) {
          return Column(
            children: [
              Icon(
                _getGuaranteeIcon(item['icon']!),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item['text']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getGuaranteeIcon(String name) {
    switch (name) {
      case 'verified':
        return Icons.verified;
      case 'assignment_return':
        return Icons.assignment_return;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildReviewSection() {
    final displayReviews = _reviews.take(3).toList();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '用户评价',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewListPage(
                          product: widget.product,
                          reviews: _reviews,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '查看全部 >',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...displayReviews.asMap().entries.map((entry) {
            final isLast = entry.key == displayReviews.length - 1;
            return _buildReviewItem(entry.value, showDivider: !isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    Map<String, dynamic> review, {
    bool showDivider = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(review['avatar']),
              ),
              const SizedBox(width: 8),
              Text(
                review['user'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating'].floor()
                        ? Icons.star
                        : Icons.star_border,
                    size: 14,
                    color: AppColors.warning,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['content'],
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (review['images'].isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildReviewImageGrid(review['images'] as List<String>),
          ],
          const SizedBox(height: 4),
          Text(
            review['time'],
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          if (showDivider) const Divider(height: 24, color: AppColors.divider),
        ],
      ),
    );
  }

  Widget _buildReviewImageGrid(List<String> images) {
    final displayImages = images.take(9).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 4.0;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: displayImages.map((url) {
            return SizedBox(
              width: itemWidth,
              height: itemWidth,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewerPage(
                        imageUrls: displayImages,
                        initialIndex: displayImages.indexOf(url),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDetailSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '商品详情',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...List.generate(3, (index) {
            return CachedNetworkImage(
              imageUrl: 'https://picsum.photos/800/600?random=${index + 20}',
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: AppColors.background,
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendSection(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.hotRecommend,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: _recommendProducts.length,
              itemBuilder: (context, index) {
                return _buildRecommendCard(_recommendProducts[index]);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRecommendCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: CachedNetworkImage(
                imageUrl: product.image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  Text(
                    '¥${product.originalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
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

  Widget _buildAppBarIconWithBadge(
    IconData icon,
    int badgeCount,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: AppColors.white),
            onPressed: onTap,
          ),
          if (badgeCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
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

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            return Row(
              children: [
                BottomIconWithBadge(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  label: '购物车',
                  badgeCount: cartProvider.totalCount,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                const SizedBox(width: 16),
                BottomIconWithBadge(
                  icon: Icon(
                    Icons.store_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  label: '店铺',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                BottomIconWithBadge(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.error
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                  label: '收藏',
                  onTap: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ToastUtil.show(
                      context,
                      _isFavorite
                          ? l10n.addedToFavorites
                          : l10n.removedFromFavorites,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAttributeSheet(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          l10n.addToCart,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAttributeSheet(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          l10n.buyNow,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAttributeSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductAttributeSheet(
        product: widget.product,
        initialColor: _selectedColor,
        initialSize: _selectedSize,
        initialQuantity: _quantity,
        onClose: () => Navigator.pop(context),
        onAddToCart:
            ({
              required selectedColor,
              required selectedSize,
              required quantity,
            }) {
              if (widget.product.colors.isNotEmpty && selectedColor == null) {
                ToastUtil.showError(context, l10n.selectColor);
                return;
              }
              if (widget.product.sizes.isNotEmpty && selectedSize == null) {
                ToastUtil.showError(context, l10n.selectSize);
                return;
              }

              context.read<CartProvider>().addToCart(
                widget.product,
                selectedColor: selectedColor,
                selectedSize: selectedSize,
                quantity: quantity,
              );
              Navigator.pop(context);
              ToastUtil.showSuccess(context, l10n.addedToCart);
            },
        onBuyNow:
            ({
              required selectedColor,
              required selectedSize,
              required quantity,
            }) {
              if (widget.product.colors.isNotEmpty && selectedColor == null) {
                ToastUtil.showError(context, l10n.selectColor);
                return;
              }
              if (widget.product.sizes.isNotEmpty && selectedSize == null) {
                ToastUtil.showError(context, l10n.selectSize);
                return;
              }

              context.read<CartProvider>().addToCart(
                widget.product,
                selectedColor: selectedColor,
                selectedSize: selectedSize,
                quantity: quantity,
              );
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutPage()),
              );
            },
      ),
    );
  }

  List<String> _getImageUrls() {
    return List.generate(5, (_) => widget.product.image);
  }
}
