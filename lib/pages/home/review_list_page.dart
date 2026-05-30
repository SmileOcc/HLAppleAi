import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';
import '../../widgets/image_viewer_page.dart';

class ReviewListPage extends StatefulWidget {
  final Product product;
  final List<Map<String, dynamic>> reviews;

  const ReviewListPage({
    super.key,
    required this.product,
    required this.reviews,
  });

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  bool _isScrolled = false;

  final List<String> _tabs = ['全部', '热门', '最新'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredReviews {
    final reviews = List<Map<String, dynamic>>.from(widget.reviews);
    switch (_selectedTab) {
      case 1:
        reviews.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
        );
        break;
      case 2:
        break;
      default:
        break;
    }
    return reviews;
  }

  double get _averageRating {
    if (widget.reviews.isEmpty) return 0.0;
    final total = widget.reviews.fold<double>(
      0,
      (sum, r) => sum + (r['rating'] as double),
    );
    return total / widget.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _isScrolled ? AppColors.white : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isScrolled ? AppColors.textPrimary : AppColors.textPrimary,
          ),
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > 0 && !_isScrolled) {
            setState(() => _isScrolled = true);
          } else if (notification.metrics.pixels <= 0 && _isScrolled) {
            setState(() => _isScrolled = false);
          }
          return false;
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
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
            ];
          },
          body: ListView.builder(
            itemCount: _filteredReviews.length,
            itemBuilder: (context, index) {
              final review = _filteredReviews[index];
              final isLast = index == _filteredReviews.length - 1;
              return _buildReviewItem(review, showDivider: !isLast);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    final ratingCount = widget.reviews.length;
    final ratingDistribution = [0, 0, 0, 0, 0];
    for (final review in widget.reviews) {
      final rating = review['rating'] as double;
      final index = rating.floor().clamp(0, 4);
      ratingDistribution[index]++;
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
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 6,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.warning,
                            ),
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
