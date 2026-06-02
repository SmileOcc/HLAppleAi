import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/services/mock_data_service.dart';
import '../core/constants/app_constants.dart';
import '../providers/locale_provider.dart';
import '../pages/home/scan_page.dart';
import '../pages/profile/order_list_page.dart';
import '../pages/profile/favorite_page.dart';
import '../pages/profile/history_page.dart';
import '../pages/profile/coupon_page.dart';
import '../pages/profile/activity_page.dart';
import '../pages/profile/task_page.dart';
import '../pages/profile/settings_page.dart';
import '../pages/profile/about_page.dart';
import '../pages/profile/after_sales_list_page.dart';
import '../pages/profile/wallet_page.dart';
import '../pages/profile/package_page.dart';
import '../pages/profile/my_reviews_page.dart';
import '../pages/profile/share_rebate_page.dart';
import '../pages/profile/help_page.dart';
import '../pages/profile/notification_settings_page.dart';
import '../pages/profile/privacy_settings_page.dart';
import '../pages/profile/creator_center_page.dart';
import '../pages/profile/live_streaming_page.dart';
import '../pages/profile/open_store_page.dart';
import '../pages/profile/mini_program_page.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _darkMode = false;
  late LocaleProvider _localeProvider;

  @override
  void initState() {
    super.initState();
    _localeProvider = context.read<LocaleProvider>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await MockDataService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleProvider>();
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  _buildStatsRow(),
                  const SizedBox(height: 4),
                  _buildSectionLabel('常用功能'),
                  _buildGrid(items: _commonItems, crossAxisCount: 4),
                  _buildSectionLabel('创作与服务'),
                  _buildGrid(items: _creatorItems, crossAxisCount: 4),
                  _buildSectionLabel('设置与账户'),
                  _buildSettingsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  List<_GridItem> get _commonItems => [
    _GridItem(
      Icons.shopping_bag_outlined,
      '我的订单',
      AppColors.primary,
      () => _navigateTo(const OrderListPage()),
    ),
    _GridItem(
      Icons.favorite_border,
      '我的收藏',
      AppColors.error,
      () => _navigateTo(const FavoritePage()),
    ),
    _GridItem(
      Icons.history,
      '浏览记录',
      AppColors.warning,
      () => _navigateTo(const HistoryPage()),
    ),
    _GridItem(
      Icons.card_giftcard_outlined,
      '优惠券',
      const Color(0xFF4ECDC4),
      () => _navigateTo(const CouponPage()),
    ),
    _GridItem(
      Icons.local_offer_outlined,
      '活动中心',
      const Color(0xFF6C5CE7),
      () => _navigateTo(const ActivityPage()),
    ),
    _GridItem(
      Icons.emoji_events_outlined,
      '任务中心',
      const Color(0xFFFDA7DF),
      () => _navigateTo(const TaskPage()),
    ),
    _GridItem(
      Icons.wallet_outlined,
      '我的钱包',
      const Color(0xFF00B894),
      () => _navigateTo(const WalletPage()),
    ),
    _GridItem(
      Icons.inventory_2_outlined,
      '我的包裹',
      const Color(0xFF74B9FF),
      () => _navigateTo(const PackagePage()),
    ),
    _GridItem(
      Icons.rate_review_outlined,
      '我的评价',
      const Color(0xFFA29BFE),
      () => _navigateTo(const MyReviewsPage()),
    ),
    _GridItem(
      Icons.refresh_outlined,
      '退换售后',
      const Color(0xFFFD79A8),
      () => _navigateTo(const AfterSalesListPage()),
    ),
    _GridItem(
      Icons.share_outlined,
      '分享返利',
      const Color(0xFFFDCB6E),
      () => _navigateTo(const ShareRebatePage()),
    ),
    _GridItem(
      Icons.help_outline,
      '使用帮助',
      AppColors.textSecondary,
      () => _navigateTo(const HelpPage()),
    ),
  ];

  List<_GridItem> get _creatorItems => [
    _GridItem(
      Icons.person_add_alt_1_outlined,
      '创作者中心',
      const Color(0xFF6C5CE7),
      () => _navigateTo(const CreatorCenterPage()),
    ),
    _GridItem(
      Icons.videocam_outlined,
      '直播带货',
      const Color(0xFFE17055),
      () => _navigateTo(const LiveStreamingPage()),
    ),
    _GridItem(
      Icons.store_outlined,
      '我要开店',
      const Color(0xFF00B894),
      () => _navigateTo(const OpenStorePage()),
    ),
    _GridItem(
      Icons.apps_outlined,
      '小程序',
      const Color(0xFF0984E3),
      () => _navigateTo(const MiniProgramPage()),
    ),
  ];

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: _user != null
                    ? CachedNetworkImageProvider(_user!['avatar'])
                    : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.primary,
                      ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.qr_code_scanner_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _user?['name'] ?? '未登录',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _user != null ? 'ID: ${_user!['id']}' : '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Lv.3',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _buildStatItem('关注', '128')),
            Container(width: 1, height: 24, color: AppColors.divider),
            Expanded(child: _buildStatItem('粉丝', '2.3k')),
            Container(width: 1, height: 24, color: AppColors.divider),
            Expanded(child: _buildStatItem('获赞', '5.6k')),
          ],
        ),
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
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGrid({
    required List<_GridItem> items,
    required int crossAxisCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.9,
        ),
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildGridItem(item);
        },
      ),
    );
  }

  Widget _buildGridItem(_GridItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    final items = [
      _ListItem(
        Icons.shield_outlined,
        '账号安全',
        null,
        () => _navigateTo(const SettingsPage()),
      ),
      _ListItem(
        Icons.notifications_outlined,
        '消息通知',
        null,
        () => _navigateTo(const NotificationSettingsPage()),
      ),
      _ListItem(
        Icons.lock_outlined,
        '隐私设置',
        null,
        () => _navigateTo(const PrivacySettingsPage()),
      ),
      _ListItem(Icons.dark_mode_outlined, '深色模式', 'switch', null),
      _ListItem(
        Icons.language_outlined,
        '多语言',
        _localeProvider.currentLanguageName,
        () => _showLanguageDialog(),
      ),
      _ListItem(
        Icons.info_outline,
        '关于我们',
        null,
        () => _navigateTo(const AboutPage()),
      ),
      _ListItem(Icons.logout, '退出登录', null, () => _showLogoutDialog()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: items.map((item) => _buildListItem(item)).toList(),
      ),
    );
  }

  Widget _buildListItem(_ListItem item) {
    if (item.trailingType == 'switch') {
      return ListTile(
        dense: true,
        leading: Icon(item.icon, color: AppColors.textPrimary, size: 22),
        title: Text(item.label, style: const TextStyle(fontSize: 14)),
        trailing: Switch(
          value: _darkMode,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _darkMode = v),
        ),
        onTap: () => setState(() => _darkMode = !_darkMode),
      );
    }

    return ListTile(
      dense: true,
      leading: Icon(item.icon, color: AppColors.textPrimary, size: 22),
      title: Text(item.label, style: const TextStyle(fontSize: 14)),
      trailing: item.trailingType != null
          ? Text(
              item.trailingType!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
      onTap: item.onTap,
    );
  }

  void _showLanguageDialog() {
    final languages = [
      {'name': '简体中文', 'locale': const Locale('zh', 'CN')},
      {'name': 'English', 'locale': const Locale('en', 'US')},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '多语言',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...List.generate(languages.length, (index) {
                final isSelected =
                    _localeProvider.locale.languageCode ==
                    (languages[index]['locale'] as Locale).languageCode;
                return ListTile(
                  title: Text(
                    languages[index]['name'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    _localeProvider.setLocale(
                      languages[index]['locale'] as Locale,
                    );
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？退出后需要重新登录才能使用完整功能。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已退出登录')));
            },
            child: const Text('确认退出', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _GridItem(this.icon, this.label, this.color, this.onTap);
}

class _ListItem {
  final IconData icon;
  final String label;
  final String? trailingType;
  final VoidCallback? onTap;
  const _ListItem(this.icon, this.label, this.trailingType, this.onTap);
}
