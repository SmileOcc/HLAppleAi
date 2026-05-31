import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/services/mock_data_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../home/product_detail_page.dart';
import '../home/search_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ScrollController _rightScrollController = ScrollController();
  final Map<int, GlobalKey> _sectionKeys = {};
  int _currentRightIndex = 0;
  bool _isLeftScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      _rightScrollController.addListener(_onRightScroll);
    });
  }

  @override
  void dispose() {
    _rightScrollController.dispose();
    super.dispose();
  }

  void _onRightScroll() {
    if (_isLeftScrolling) return;

    final provider = context.read<CategoryProvider>();
    final selectedCategory = provider.selectedCategory;
    if (selectedCategory == null) return;

    final children = selectedCategory.children;
    for (int i = children.length - 1; i >= 0; i--) {
      final key = _sectionKeys[children[i].id];
      if (key?.currentContext != null) {
        final box = key!.currentContext!.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);
        if (offset.dy <=
            MediaQuery.of(context).padding.top + kToolbarHeight + 100) {
          if (_currentRightIndex != i) {
            setState(() => _currentRightIndex = i);
          }
          break;
        }
      }
    }
  }

  void _onLeftCategoryTap(int index) {
    final provider = context.read<CategoryProvider>();
    if (provider.selectedCategory?.id == provider.categories[index].id) return;

    setState(() {
      _isLeftScrolling = true;
      _currentRightIndex = 0;
    });

    provider.selectCategory(provider.categories[index]);

    Future.delayed(const Duration(milliseconds: 100), () {
      _rightScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _isLeftScrolling = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              _buildLeftCategoryList(provider),
              Expanded(child: _buildRightContent(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftCategoryList(CategoryProvider provider) {
    return Container(
      width: 90,
      color: AppColors.background,
      child: ListView.builder(
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory?.id == category.id;

          return GestureDetector(
            onTap: () => _onLeftCategoryTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : AppColors.background,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category.icon),
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightContent(CategoryProvider provider) {
    final selectedCategory = provider.selectedCategory;
    if (selectedCategory == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final children = selectedCategory.children;
    _sectionKeys.clear();
    for (final child in children) {
      _sectionKeys[child.id] = GlobalKey();
    }

    return Container(
      color: AppColors.white,
      child: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: CustomScrollView(
          controller: _rightScrollController,
          slivers: [
            ...children.asMap().entries.map((entry) {
              final index = entry.key;
              final subCategory = entry.value;
              return _buildRightSection(
                provider,
                subCategory,
                _sectionKeys[subCategory.id]!,
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSection(
    CategoryProvider provider,
    Category subCategory,
    GlobalKey key,
  ) {
    final l10n = AppLocalizations.of(context);
    final subChildren = subCategory.children;

    return SliverToBoxAdapter(
      key: key,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  subCategory.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: subChildren.map((sub) {
                return _buildSubCategoryItem(provider, sub);
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryItem(CategoryProvider provider, Category sub) {
    return GestureDetector(
      onTap: () => _onSubCategoryTap(provider, sub),
      child: Container(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: AppColors.background,
                child: Icon(
                  _getCategoryIcon(sub.icon),
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub.name,
              style: const TextStyle(
                fontSize: 12,
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

  void _onSubCategoryTap(CategoryProvider provider, Category sub) {
    provider.selectSubCategory(sub.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubCategoryProductsPage(subCategory: sub),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'phone_iphone': Icons.phone_iphone,
      'computer': Icons.computer,
      'tablet_mac': Icons.tablet_mac,
      'headphones': Icons.headphones,
      'watch': Icons.watch,
      'camera_alt': Icons.camera_alt,
      'devices': Icons.devices,
      'cable': Icons.cable,
      'smartphone': Icons.smartphone,
      'phone_android': Icons.phone_android,
      'laptop': Icons.laptop,
      'desktop_windows': Icons.desktop_windows,
      'memory': Icons.memory,
      'headset': Icons.headset,
      'speaker': Icons.speaker,
      'music_note': Icons.music_note,
      'smartwatch': Icons.watch,
      'fitness_center': Icons.fitness_center,
      'vr_viewer': Icons.view_in_ar,
      'photo_camera': Icons.photo_camera,
      'videocam': Icons.videocam,
      'sports_esports': Icons.sports_esports,
      'gamepad': Icons.gamepad,
      'keyboard': Icons.keyboard,
      'home': Icons.home,
      'lock': Icons.lock,
      'lightbulb': Icons.lightbulb,
      'power': Icons.power,
      'battery_full': Icons.battery_full,
      'signal_cellular_alt': Icons.signal_cellular_alt,
      'crop_square': Icons.crop_square,
      'battery_charging_full': Icons.battery_charging_full,
      'bluetooth_audio': Icons.bluetooth_audio,
      'graphic_eq': Icons.graphic_eq,
      'mic': Icons.mic,
      'watch_later': Icons.watch_later,
      'desktop_mac': Icons.desktop_mac,
      'storage': Icons.storage,
      'developer_board': Icons.developer_board,
      'straighten': Icons.straighten,
      'sd_storage': Icons.sd_storage,
      'bag': Icons.shopping_bag,
      'camera_enhance': Icons.camera_enhance,
      'view_in_ar': Icons.view_in_ar,
      'doorbell': Icons.doorbell,
      'light_mode': Icons.light_mode,
      'usb': Icons.usb,
      'hub': Icons.hub,
      'print': Icons.print,
      'scanner': Icons.scanner,
      'tv': Icons.tv,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}

class _SubCategoryProductsPage extends StatefulWidget {
  final Category subCategory;

  const _SubCategoryProductsPage({required this.subCategory});

  @override
  State<_SubCategoryProductsPage> createState() =>
      _SubCategoryProductsPageState();
}

class _SubCategoryProductsPageState extends State<_SubCategoryProductsPage> {
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
      final products = await MockDataService.getCategoryProducts(
        categoryId: widget.subCategory.id,
        page: 1,
      );
      _products = products;
      _currentPage = 1;
      _hasMore = products.length >= MockDataService.categoryPageSize;
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
      final products = await MockDataService.getCategoryProducts(
        categoryId: widget.subCategory.id,
        page: 1,
      );
      _products = products;
      _currentPage = 1;
      _hasMore = products.length >= MockDataService.categoryPageSize;
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
      final products = await MockDataService.getCategoryProducts(
        categoryId: widget.subCategory.id,
        page: nextPage,
      );
      _products.addAll(products);
      _currentPage = nextPage;
      _hasMore = products.length >= MockDataService.categoryPageSize;
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subCategory.name)),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildContent(),
            _buildFooter(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
}
