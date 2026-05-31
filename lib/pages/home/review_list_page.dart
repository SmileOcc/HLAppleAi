import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';
import '../../data/services/mock_data_service.dart';
import '../../widgets/image_viewer_page.dart';

class ReviewListPage extends StatefulWidget {
  final Product product;

  const ReviewListPage({super.key, required this.product});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final List<String> _tabs = ['全部', '热门', '最新'];

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allReviews = [];
  List<Map<String, dynamic>> _sortedAll = [];
  final Set<int> _expandedIds = {};

  int _page = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() => _selectedTab = _tabController.index);
      _page = 1;
      _applySort();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadReviews() async {
    _isLoading = true;
    setState(() {});

    _allReviews = await MockDataService.getProductReviews();
    _page = 1;
    _applySort();

    _isLoading = false;
    setState(() {});
  }

  void _applySort() {
    _sortedAll = List.from(_allReviews);
    switch (_selectedTab) {
      case 1:
        _sortedAll.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
        );
        break;
      case 2:
        _sortedAll.sort(
          (a, b) => (b['time'] as String).compareTo(a['time'] as String),
        );
        break;
    }
  }

  List<Map<String, dynamic>> get _displayedReviews {
    final end = (_page * _pageSize).clamp(0, _sortedAll.length);
    return _sortedAll.sublist(0, end);
  }

  bool get _hasMore => (_page * _pageSize) < _sortedAll.length;

  Future<void> _onRefresh() async {
    await _loadReviews();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 300));
    _page++;

    _isLoadingMore = false;
    setState(() {});
  }

  double get _averageRating {
    if (_allReviews.isEmpty) return 0.0;
    final total = _allReviews.fold<double>(
      0,
      (sum, r) => sum + (r['rating'] as double),
    );
    return total / _allReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '商品评价',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildRatingSummary()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabHeaderDelegate(
                      child: Container(
                        color: AppColors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          indicatorColor: AppColors.textPrimary,
                          indicatorWeight: 2,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: AppColors.divider,
                          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= _displayedReviews.length) {
                        return _buildFooter();
                      }
                      return _buildReviewItem(
                        _displayedReviews[index],
                        index: index,
                        showDivider: index < _displayedReviews.length - 1,
                      );
                    }, childCount: _displayedReviews.length + 1),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMore && _allReviews.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '暂无更多数据',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRatingSummary() {
    final ratingCount = _allReviews.length;
    final ratingDistribution = [0, 0, 0, 0, 0];
    for (final review in _allReviews) {
      final rating = review['rating'] as double;
      final idx = rating.floor().clamp(0, 4);
      ratingDistribution[idx]++;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$ratingCount 条评价',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final starIndex = 4 - index;
                final count = ratingDistribution[starIndex];
                final percentage = ratingCount > 0 ? count / ratingCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${starIndex + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            children: [
                              Container(height: 8, color: AppColors.divider),
                              FractionallySizedBox(
                                widthFactor: percentage.clamp(0.0, 1.0),
                                child: Container(
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFB347),
                                        Color(0xFFFF6B6B),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    Map<String, dynamic> review, {
    required int index,
    bool showDivider = true,
  }) {
    return Container(
      color: AppColors.white,
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
                children: List.generate(5, (i) {
                  return Icon(
                    i < review['rating'].floor()
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
          _buildExpandableContent(review['content'] as String, index),
          if (review['images'] != null &&
              (review['images'] as List).isNotEmpty) ...[
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

  Widget _buildExpandableContent(String text, int index) {
    final isExpanded = _expandedIds.contains(index);
    return LayoutBuilder(
      builder: (context, constraints) {
        final needsExpand = _textExceedsLines(text, 3, constraints.maxWidth);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              text,
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            if (!isExpanded && needsExpand)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _expandedIds.add(index));
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 4),
                    color: AppColors.white,
                    child: const Text(
                      '展开',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            if (isExpanded)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _expandedIds.remove(index));
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 4),
                    color: AppColors.white,
                    child: const Text(
                      '收起',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _textExceedsLines(String text, int maxLines, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 13, height: 1.5),
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
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
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_TabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
