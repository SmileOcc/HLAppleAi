import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_preferences.dart';
import 'feature_debugger/debug_settings.dart';
import 'feature_debugger/debug_page.dart';
import 'pages/cart/cart_page.dart';
import 'pages/category/category_page.dart';
import 'pages/community/community_page.dart';
import 'pages/home/home_page.dart';
import 'widgets/activity_ad_dialog.dart';
import 'widgets/app_upgrade_dialog.dart';
import 'widgets/settings_drawer.dart';
import 'pages/profile/profile_page.dart';
import 'providers/cart_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/home_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';

class HLAppleAiApp extends StatelessWidget {
  const HLAppleAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainPage(),
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _upgradeShown = false;
  final List<int> _tapTimestamps = [];
  final List<Widget> _pages = const [
    HomePage(),
    CategoryPage(),
    CommunityPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([_checkActivityAd(), _checkAppUpgrade()]);
    });
  }

  bool _isVersionGreater(String debugVersion, String currentVersion) {
    final cleanDebug = debugVersion.replaceFirst(
      RegExp(r'^v', caseSensitive: false),
      '',
    );
    final cleanCurrent = currentVersion.replaceFirst(
      RegExp(r'^v', caseSensitive: false),
      '',
    );
    final debugParts = cleanDebug.split('.');
    final currentParts = cleanCurrent.split('.');
    final maxLen = debugParts.length > currentParts.length
        ? debugParts.length
        : currentParts.length;
    for (var i = 0; i < maxLen; i++) {
      final d = i < debugParts.length ? int.tryParse(debugParts[i]) ?? 0 : 0;
      final c = i < currentParts.length
          ? int.tryParse(currentParts[i]) ?? 0
          : 0;
      if (d > c) return true;
      if (d < c) return false;
    }
    return false;
  }

  Future<void> _checkAppUpgrade() async {
    if (kReleaseMode) return;
    final debug = await DebugSettings.getInstance();
    if (!debug.upgradeEnabled) return;
    if (!_isVersionGreater(debug.upgradeVersion, AppConstants.appVersion)) {
      return;
    }
    if (!mounted) return;
    _upgradeShown = true;
    AppUpgradeDialog.show(
      context,
      config: AppUpgradeConfig(
        title: debug.upgradeTitle,
        version: debug.upgradeVersion,
        description: debug.upgradeDescription,
        downloadUrl: debug.upgradeDownloadUrl,
        forceUpdate: debug.upgradeForceUpdate,
      ),
      onUpdate: () {},
      onCancel: () {},
    );
  }

  Future<void> _checkActivityAd() async {
    if (!kReleaseMode) {
      final debug = await DebugSettings.getInstance();
      if (debug.adStartupEnabled) {
        if (debug.adSource == AdSource.config) {
          await Future.delayed(Duration(seconds: debug.adDelaySeconds));
          if (!mounted || _upgradeShown) return;
          ActivityAdDialog.show(
            context,
            config: ActivityAdConfig(
              title: debug.adTitle.isNotEmpty ? debug.adTitle : '限时特惠活动',
              description: debug.adContent,
              imageUrl: debug.adImageUrl,
              actionText: '立即查看',
            ),
          );
        } else {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted || _upgradeShown) return;
          ActivityAdDialog.show(
            context,
            config: const ActivityAdConfig(
              title: '限时特惠活动',
              description:
                  '全场商品低至5折！精选好货限时抢购，赶紧来选购吧！\n\n'
                  '活动时间：即日起至本月底\n优惠券每日限量发放，先到先得！',
              imageUrl: 'https://picsum.photos/600/300?random=999',
              actionText: '立即查看',
            ),
          );
        }
        return;
      }
    }
    final prefs = await NotificationPreferences.getInstance();
    if (!prefs.activityEnabled || !mounted) return;
    if (_upgradeShown) return;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || _upgradeShown) return;
    ActivityAdDialog.show(
      context,
      config: const ActivityAdConfig(
        title: '限时特惠活动',
        description:
            '全场商品低至5折！精选好货限时抢购，赶紧来选购吧！\n\n'
            '活动时间：即日起至本月底\n优惠券每日限量发放，先到先得！',
        imageUrl: 'https://picsum.photos/600/300?random=999',
        actionText: '立即查看',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const SettingsDrawer(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (!kReleaseMode) {
            final now = DateTime.now().millisecondsSinceEpoch;
            _tapTimestamps.add(now);
            _tapTimestamps.removeWhere((t) => now - t > 3000);
            if (_tapTimestamps.length >= 5) {
              _tapTimestamps.clear();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebugPage()),
              );
              return;
            }
          }
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.category : Icons.category_outlined,
            ),
            label: l10n.category,
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 2 ? Icons.forum : Icons.forum_outlined),
            label: l10n.community,
          ),
          BottomNavigationBarItem(icon: _buildCartIcon(), label: l10n.cart),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 4 ? Icons.person : Icons.person_outline,
            ),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon() {
    return Consumer<CartProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            Icon(
              _currentIndex == 3
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
            ),
            if (provider.totalCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    provider.totalCount > 99
                        ? '99+'
                        : provider.totalCount.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
