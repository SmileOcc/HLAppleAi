import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildBanner(),
              _buildQuickCategories(),
              _buildRecommendTitle(),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primary,
      title: const Text(
        AppConstants.appName,
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.message_outlined, color: AppColors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        color: AppColors.primary,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.searchHint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.banners.isEmpty) {
            return Container(
              height: 150,
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Container(
            height: 150,
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            child: PageView.builder(
              itemCount: provider.banners.length,
              itemBuilder: (context, index) {
                final banner = provider.banners[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: banner['image'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.background),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.image),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickCategories() {
    return SliverToBoxAdapter(
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.quickCategories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceAround,
              children: provider.quickCategories.map((category) {
                return _buildCategoryItem(category);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final iconMap = {
      'phone_iphone': Icons.phone_iphone,
      'computer': Icons.computer,
      'tablet_mac': Icons.tablet_mac,
      'headphones': Icons.headphones,
      'watch': Icons.watch,
      'camera_alt': Icons.camera_alt,
      'devices': Icons.devices,
      'cable': Icons.cable,
    };

    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                iconMap[category['icon']] ?? Icons.category,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category['name'] ?? '',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendTitle() {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.hotRecommend,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.recommendProducts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.paddingSmall,
              crossAxisSpacing: AppConstants.paddingSmall,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= provider.recommendProducts.length) {
                  return provider.hasMore
                      ? const Center(child: CircularProgressIndicator())
                      : null;
                }
                return ProductCard(
                  product: provider.recommendProducts[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        product: provider.recommendProducts[index],
                      ),
                    ),
                  ),
                );
              },
              childCount:
                  provider.recommendProducts.length +
                  (provider.hasMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}
