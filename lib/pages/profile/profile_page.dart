import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../providers/locale_provider.dart';
import 'order_list_page.dart';
import 'after_sales_list_page.dart';
import 'favorite_page.dart';
import 'post_favorites_page.dart';
import 'my_attachments_page.dart';
import 'address_page.dart';
import 'coupon_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'notification_settings_page.dart';
import 'about_page.dart';
import '../auth/login_register_page.dart';

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
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
      flexibleSpace: _buildFlexibleSpace(provider, l10n),
    );
  }

  Widget _buildFlexibleSpace(ProfileProvider provider, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

        double ratio = 1.0;
        if (settings != null) {
          final total = settings.maxExtent - settings.minExtent;
          ratio = total > 0
              ? ((settings.currentExtent - settings.minExtent) / total).clamp(
                  0.0,
                  1.0,
                )
              : 1.0;
        }

        final topInset = MediaQuery.of(context).padding.top;
        final rowHeight = provider.isLoggedIn ? 80.0 : 60.0;
        final originX = rowHeight / 2;

        final collapsedCenterY = topInset + kToolbarHeight / 2;
        final expandedCenterY = topInset + (200.0 - topInset) / 2;
        final centerY =
            collapsedCenterY + (expandedCenterY - collapsedCenterY) * ratio;
        final top = centerY - rowHeight / 2;
        final scale = 0.4 + ratio * 0.6;
        final contentOpacity = ratio.clamp(0.0, 1.0);
        final left = 16.0 + (24.0 - 16.0) * ratio;

        final infoOpacity = ((contentOpacity - 0.3) / 0.7).clamp(0.0, 1.0);

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: Transform(
                  transform: Matrix4.identity()..scale(scale),
                  origin: Offset(originX, rowHeight / 2),
                  child: SizedBox(
                    height: rowHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        provider.isLoggedIn
                            ? _buildAvatarWidget(provider, rowHeight / 2)
                            : const CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                              ),
                        const SizedBox(width: 16),
                        provider.isLoggedIn
                            ? _buildUserInfo(provider, l10n, infoOpacity)
                            : _buildLoginButton(l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget(ProfileProvider provider, double radius) {
    final userInfo = provider.userInfo;
    return CircleAvatar(
      radius: radius,
      backgroundImage:
          userInfo != null &&
              userInfo['avatar'] != null &&
              (userInfo['avatar'] as String).isNotEmpty
          ? CachedNetworkImageProvider(userInfo['avatar'] as String)
          : null,
      child:
          userInfo == null ||
              userInfo['avatar'] == null ||
              (userInfo['avatar'] as String).isEmpty
          ? Icon(Icons.person, size: radius, color: AppColors.white)
          : null,
    );
  }

  Widget _buildUserInfo(
    ProfileProvider provider,
    AppLocalizations l10n,
    double infoOpacity,
  ) {
    final userInfo = provider.userInfo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userInfo?['name'] ?? l10n.user,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: infoOpacity.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Opacity(
                opacity: infoOpacity.clamp(0.0, 1.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lv.${userInfo?['level'] ?? 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '积分: ${userInfo?['points'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginRegisterPage(fromOnboarding: false),
          ),
        );
      },
      icon: const Icon(Icons.login, size: 18),
      label: Text('${l10n.login}/${l10n.register}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
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
              color: Colors.black.withValues(alpha: 0.05),
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
                  tabIndex: 1,
                ),
                _buildOrderItem(
                  icon: Icons.local_shipping,
                  label: l10n.paid,
                  count: 0,
                  tabIndex: 2,
                ),
                _buildOrderItem(
                  icon: Icons.inventory_2,
                  label: l10n.shipped,
                  count: provider.shippedOrderCount,
                  tabIndex: 3,
                ),
                _buildOrderItem(
                  icon: Icons.check_circle_outline,
                  label: l10n.completed,
                  count: provider.completedOrderCount,
                  tabIndex: 4,
                ),
                _buildAfterSaleItem(
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
    required int tabIndex,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderListPage(initialTab: tabIndex),
          ),
        );
      },
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

  Widget _buildAfterSaleItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AfterSalesListPage()),
        );
      },
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
        'icon': Icons.bookmark_outline,
        'title': '帖子收藏',
        'page': const PostFavoritesPage(),
      },
      {
        'icon': Icons.attach_file,
        'title': '我的附件',
        'page': const MyAttachmentsPage(),
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
