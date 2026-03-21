import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/product_card.dart';
import '../home/product_detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.category),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: Row(
              children: [
                _buildCategoryList(provider),
                Expanded(child: _buildProductList(provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(CategoryProvider provider) {
    return Container(
      width: 85,
      color: AppColors.background,
      child: ListView.builder(
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory?.id == category.id;

          return GestureDetector(
            onTap: () => provider.selectCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : AppColors.background,
                border: Border(
                  left: BorderSide(
                    width: 3,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category.icon),
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 11,
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

  Widget _buildProductList(CategoryProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.selectedCategory?.children.isNotEmpty ?? false)
            _buildSubCategories(provider),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.paddingSmall,
                crossAxisSpacing: AppConstants.paddingSmall,
                childAspectRatio: 0.58,
              ),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: provider.products[index],
                  isGrid: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPage(product: provider.products[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategories(CategoryProvider provider) {
    final l10n = AppLocalizations.of(context);
    final children = provider.selectedCategory?.children ?? [];
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingSmall,
            ),
            child: Text(
              l10n.subCategory,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: children.map((child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(),
        ],
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
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
