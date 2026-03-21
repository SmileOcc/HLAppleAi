import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../providers/locale_provider.dart';
import 'order_list_page.dart';
import 'favorite_page.dart';
import 'address_page.dart';
import 'coupon_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听语言切换
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.isLoggedIn) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: CustomScrollView(
              slivers: [
                _buildHeader(provider, l10n),
                _buildOrderSection(provider, l10n),
                _buildMenuSection(l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProfileProvider provider, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: provider.isLoggedIn
                  ? _buildLoggedInHeader(provider, l10n)
                  : _buildLoginHeader(l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedInHeader(ProfileProvider provider, AppLocalizations l10n) {
    final userInfo = provider.userInfo;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: userInfo != null
              ? CachedNetworkImageProvider(userInfo['avatar'] ?? '')
              : const NetworkImage('https://picsum.photos/200/200'),
          child: userInfo == null
              ? const Icon(Icons.person, size: 40, color: AppColors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          userInfo?['name'] ?? l10n.user,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lv.${userInfo?['level'] ?? 1}',
                style: const TextStyle(fontSize: 12, color: AppColors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '积分: ${userInfo?['points'] ?? 0}',
              style: const TextStyle(fontSize: 12, color: AppColors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginHeader(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.white,
          child: Icon(Icons.person, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
              ),
              child: Text(l10n.login),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.3),
                foregroundColor: AppColors.white,
              ),
              child: Text(l10n.register),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSection(ProfileProvider provider, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.myOrders,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderListPage()),
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.viewAll,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOrderItem(
                  icon: Icons.payment,
                  label: l10n.pending,
                  count: provider.pendingOrderCount,
                ),
                _buildOrderItem(
                  icon: Icons.local_shipping,
                  label: l10n.paid,
                  count: 0,
                ),
                _buildOrderItem(
                  icon: Icons.inventory_2,
                  label: l10n.shipped,
                  count: provider.shippedOrderCount,
                ),
                _buildOrderItem(
                  icon: Icons.check_circle_outline,
                  label: l10n.completed,
                  count: provider.completedOrderCount,
                ),
                _buildOrderItem(
                  icon: Icons.replay,
                  label: l10n.afterSale,
                  count: 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, size: 28, color: AppColors.textPrimary),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AppLocalizations l10n) {
    final menus = [
      {
        'icon': Icons.favorite_outline,
        'title': l10n.myFavorites,
        'page': const FavoritePage(),
      },
      {
        'icon': Icons.location_on_outlined,
        'title': l10n.addressManage,
        'page': const AddressPage(),
      },
      {
        'icon': Icons.credit_card_outlined,
        'title': l10n.coupons,
        'page': const CouponPage(),
      },
      {
        'icon': Icons.history,
        'title': l10n.history,
        'page': const HistoryPage(),
      },
      {
        'icon': Icons.settings_outlined,
        'title': l10n.settings,
        'page': const SettingsPage(),
      },
      {
        'icon': Icons.info_outline,
        'title': l10n.aboutUs,
        'page': const AboutPage(),
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final menu = menus[index];
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall / 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: ListTile(
            leading: Icon(menu['icon'] as IconData, color: AppColors.primary),
            title: Text(
              menu['title'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => menu['page'] as Widget),
            ),
          ),
        );
      }, childCount: menus.length),
    );
  }
}
