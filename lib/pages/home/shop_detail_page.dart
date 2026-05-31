import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';
import '../../data/models/shop.dart';
import '../../data/services/mock_data_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state_widget.dart';
import 'product_detail_page.dart';

class ShopDetailPage extends StatefulWidget {
  final Shop shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLoad();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore &&
        _error == null &&
        _products.isNotEmpty) {
      _loadMore();
    }
  }

  Future<void> _initLoad() async {
    _isLoading = true;
    _error = null;
    setState(() {});
    try {
      final products = await MockDataService.getShopProducts(page: 1);
      _products = products;
      _currentPage = 1;
      _hasMore = products.length >= MockDataService.shopPageSize;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    _error = null;
    setState(() {});
    try {
      final products = await MockDataService.getShopProducts(page: 1);
      _products = products;
      _currentPage = 1;
      _hasMore = products.length >= MockDataService.shopPageSize;
    } catch (e) {
      _error = e.toString();
    }
    setState(() {});
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    setState(() {});
    try {
      final nextPage = _currentPage + 1;
      final products = await MockDataService.getShopProducts(page: nextPage);
      _products.addAll(products);
      _currentPage = nextPage;
      _hasMore = products.length >= MockDataService.shopPageSize;
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildShopInfo()),
            if (!_isLoading || _products.isNotEmpty)
              SliverToBoxAdapter(child: _buildSectionTitle()),
            _buildProductContent(),
            _buildFooter(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _products.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget.error(message: _error!, onAction: _onRefresh),
      );
    }
    if (_products.isEmpty) {
      return SliverFillRemaining(
        child: const EmptyStateWidget.empty(message: '暂无商品'),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) => ProductCard(
          product: _products[index],
          waterfallHeight: 180 + (_products[index].id % 5) * 20,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: _products[index]),
              ),
            );
          },
        ),
        childCount: _products.length,
      ),
    );
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    if (!_hasMore && _products.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: Text(
              '暂无更多数据',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: widget.shop.cover, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfo() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, 4),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.shop.logo,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      widget.shop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.shop.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildFollowButton(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem('关注', '${widget.shop.followerCount}'),
                ),
                Container(width: 1, height: 24, color: AppColors.divider),
                Expanded(
                  child: _buildStatItem('商品', '${widget.shop.productCount}'),
                ),
                Container(width: 1, height: 24, color: AppColors.divider),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < widget.shop.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: AppColors.warning,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '关注',
          style: TextStyle(fontSize: 13, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: const Text(
        '全部商品',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
