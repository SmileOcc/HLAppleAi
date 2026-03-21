import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      // 底部导航
      'home': '首页',
      'category': '分类',
      'community': '社区',
      'cart': '购物车',
      'profile': '我的',

      // 通用
      'confirm': '确认',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'submit': '提交',
      'search': '搜索',
      'loading': '加载中...',
      'noData': '暂无数据',
      'error': '请求失败',
      'success': '操作成功',

      // 设置页面
      'dark_mode': '深色模式',
      'notifications': '消息通知',
      'location_services': '位置服务',
      'general_settings': '通用设置',
      'privacy_settings': '隐私设置',
      'language': '语言',
      'check_update': '检查更新',
      'current_version': '当前版本',
      'latest_version': '已是最新版本',

      // 商品详情
      'product_detail': '商品详情',
      'add_to_cart': '加入购物车',
      'buy_now': '立即购买',
      'select_color': '选择颜色',
      'select_size': '选择规格',
      'quantity': '数量',
      'sales': '销量',
      'stock': '库存',
      'added_to_cart': '已加入购物车',
      'added_to_favorites': '已收藏',
      'removed_from_favorites': '已取消收藏',

      // 首页
      'search_hint': '搜索商品、品牌',
      'hot_recommend': '热门推荐',

      // 分类
      'sub_category': '子分类',

      // 购物车
      'select_all': '全选',
      'total': '合计',
      'checkout': '去结算',
      'clear': '清空',
      'empty_cart': '购物车为空',
      'go_shopping': '去逛逛',
      'clear_cart': '清空购物车',
      'confirm_clear': '确定要清空购物车吗？',
      'confirm_clear_cache': '确定要清除所有缓存数据吗？',
      'selected_items': '已选{count}件商品',
      'total_price': '合计: ¥{price}',

      // 订单
      'my_orders': '我的订单',
      'all_orders': '全部',
      'pending': '待付款',
      'paid': '待发货',
      'shipped': '待收货',
      'completed': '已完成',
      'cancelled': '已取消',
      'order_no': '订单号',
      'order_time': '订单时间',
      'pay_now': '去支付',
      'cancel_order': '取消订单',
      'confirm_receive': '确认收货',
      'view_detail': '查看详情',
      'view_all': '查看全部',
      'no_orders': '暂无订单',

      // 我的
      'my_favorites': '我的收藏',
      'address_manage': '地址管理',
      'coupons': '优惠券',
      'history': '历史足迹',
      'settings': '设置',
      'about_us': '关于我们',
      'login': '登录',
      'register': '注册',
      'logout': '退出登录',
      'confirm_logout': '确定要退出登录吗？',
      'cache_cleared': '缓存已清除',
      'clear_cache': '清除缓存',
      'cached_size': '已缓存 {size}MB',

      // 我的页面
      'user': '用户',
      'after_sale': '退款/售后',
      'favorite': '我的收藏',
      'address': '地址管理',
      'coupon': '优惠券',
      'browse_history': '历史足迹',

      // 社区
      'recommend': '推荐',
      'follow': '关注',
      'hot': '热门',
      'post_detail': '帖子详情',
      'all_comments': '全部评论',
      'write_comment': '说点什么...',
      'send': '发送',
      'no_content': '暂无内容',

      // 优惠券
      'available': '可用',
      'used': '已使用',
      'expired': '已过期',
      'no_coupons': '暂无可用优惠券',
      'use': '使用',
      'min_amount': '满{amount}可用',
      'valid_until': '有效期至',

      // 地址
      'add_address': '添加收货地址',
      'edit_address': '编辑收货地址',
      'receiver': '收货人',
      'phone': '手机号',
      'detail_address': '详细地址',
      'default': '默认',
      'no_address': '暂无收货地址',
      'address_added': '地址添加成功',
      'address_updated': '地址更新成功',
      'address_deleted': '地址已删除',
      'confirm_delete': '确定要删除该地址吗？',

      // 足迹
      'clear_history': '清空记录',
      'confirm_clear_history': '确定要清空所有浏览记录吗？',
      'history_cleared': '已清空浏览记录',
      'browse_time': '浏览时间',

      // 关于
      'app_description':
          'HLAppleAi 是一款专注于为您提供优质数码产品购物体验的电商应用。我们致力于为您精选全球优质商品，让购物变得更加简单便捷。',
      'email': '邮箱',
      'phone_number': '电话',
      'website': '官网',
      'version': '版本',
      'icp_record': '粤ICP备xxxxxxxx号',
      'quality_life': '品质生活 从这里开始',

      // 账户安全
      'account_security': '账户安全',
      'account_binding': '账户绑定',
      'phone_binding': '手机绑定',
      'email_binding': '邮箱绑定',
      'wechat_binding': '微信绑定',
      'alipay_binding': '支付宝绑定',
      'security_settings': '安全设置',
      'change_password': '修改登录密码',
      'payment_password': '支付密码',
      'fingerprint_unlock': '指纹解锁',
      'face_unlock': '面容解锁',
      'login_history': '登录记录',
      'security_level': '账户安全等级',
      'high': '高',
      'medium': '中',
      'low': '低',
      'unbound': '未绑定',
      'bound': '已绑定',
      'unbind': '解绑',
      'bind': '绑定',
      'cancel_bind': '确定要解绑吗？',
      'binding_feature': '绑定功能开发中',
      'change_password_feature': '修改密码功能开发中',
      'set_payment_password': '设置支付密码',
      'payment_password_feature': '设置支付密码功能开发中',

      // 协议
      'user_agreement': '用户协议',
      'privacy_policy': '隐私政策',

      // 历史
      'no_history': '暂无浏览记录',
    },
    'en': {
      // Bottom Navigation
      'home': 'Home',
      'category': 'Category',
      'community': 'Community',
      'cart': 'Cart',
      'profile': 'Profile',

      // Common
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'submit': 'Submit',
      'search': 'Search',
      'loading': 'Loading...',
      'noData': 'No Data',
      'error': 'Request Failed',
      'success': 'Success',

      // Settings page
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'location_services': 'Location Services',
      'general_settings': 'General Settings',
      'privacy_settings': 'Privacy Settings',
      'language': 'Language',
      'check_update': 'Check Update',
      'current_version': 'Current Version',
      'latest_version': 'Already Latest',

      // Product Detail
      'product_detail': 'Product Detail',
      'add_to_cart': 'Add to Cart',
      'buy_now': 'Buy Now',
      'select_color': 'Select Color',
      'select_size': 'Select Size',
      'quantity': 'Quantity',
      'sales': 'Sales',
      'stock': 'Stock',
      'added_to_cart': 'Added to Cart',
      'added_to_favorites': 'Added to Favorites',
      'removed_from_favorites': 'Removed from Favorites',

      // Home
      'search_hint': 'Search products, brands',
      'hot_recommend': 'Hot Recommend',

      // Category
      'sub_category': 'Sub Category',

      // Cart
      'select_all': 'Select All',
      'total': 'Total',
      'checkout': 'Checkout',
      'clear': 'Clear',
      'empty_cart': 'Cart is empty',
      'go_shopping': 'Go Shopping',
      'clear_cart': 'Clear Cart',
      'confirm_clear': 'Are you sure to clear the cart?',
      'confirm_clear_cache': 'Are you sure to clear all cache data?',
      'selected_items': '{count} items selected',
      'total_price': 'Total: ¥{price}',

      // Orders
      'my_orders': 'My Orders',
      'all_orders': 'All',
      'pending': 'Pending Payment',
      'paid': 'To Ship',
      'shipped': 'To Receive',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'order_no': 'Order No.',
      'order_time': 'Order Time',
      'pay_now': 'Pay Now',
      'cancel_order': 'Cancel Order',
      'confirm_receive': 'Confirm Receive',
      'view_detail': 'View Detail',
      'view_all': 'View All',
      'no_orders': 'No Orders',

      // Profile
      'my_favorites': 'My Favorites',
      'address_manage': 'Address',
      'coupons': 'Coupons',
      'history': 'History',
      'settings': 'Settings',
      'about_us': 'About Us',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'confirm_logout': 'Are you sure to logout?',
      'cache_cleared': 'Cache Cleared',
      'clear_cache': 'Clear Cache',
      'cached_size': 'Cached {size}MB',

      // Profile page
      'user': 'User',
      'after_sale': 'Refund/After-sale',
      'favorite': 'My Favorites',
      'address': 'Address',
      'coupon': 'Coupons',
      'browse_history': 'Browse History',

      // Community
      'recommend': 'Recommend',
      'follow': 'Follow',
      'hot': 'Hot',
      'post_detail': 'Post Detail',
      'all_comments': 'Comments',
      'write_comment': 'Write something...',
      'send': 'Send',
      'no_content': 'No Content',

      // Coupons
      'available': 'Available',
      'used': 'Used',
      'expired': 'Expired',
      'no_coupons': 'No Coupons',
      'use': 'Use',
      'min_amount': 'Min {amount}',
      'valid_until': 'Valid until',

      // Address
      'add_address': 'Add Address',
      'edit_address': 'Edit Address',
      'receiver': 'Receiver',
      'phone': 'Phone',
      'detail_address': 'Address',
      'default': 'Default',
      'no_address': 'No Address',
      'address_added': 'Address Added',
      'address_updated': 'Address Updated',
      'address_deleted': 'Address Deleted',
      'confirm_delete': 'Are you sure to delete?',

      // History
      'clear_history': 'Clear History',
      'confirm_clear_history': 'Clear all history?',
      'history_cleared': 'History Cleared',
      'browse_time': 'View Time',

      // About
      'app_description':
          'HLAppleAi is an e-commerce app dedicated to providing you with a quality digital product shopping experience. We are committed to selecting the best global products for you, making shopping simpler and more convenient.',
      'email': 'Email',
      'phone_number': 'Phone',
      'website': 'Website',
      'version': 'Version',
      'icp_record': '粤ICP备xxxxxxxx号',
      'quality_life': 'Quality Life Starts Here',

      // Account Security
      'account_security': 'Account Security',
      'account_binding': 'Account Binding',
      'phone_binding': 'Phone Binding',
      'email_binding': 'Email Binding',
      'wechat_binding': 'WeChat Binding',
      'alipay_binding': 'Alipay Binding',
      'security_settings': 'Security Settings',
      'change_password': 'Change Password',
      'payment_password': 'Payment Password',
      'fingerprint_unlock': 'Fingerprint Unlock',
      'face_unlock': 'Face Unlock',
      'login_history': 'Login History',
      'security_level': 'Security Level',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'unbound': 'Unbound',
      'bound': 'Bound',
      'unbind': 'Unbind',
      'bind': 'Bind',
      'cancel_bind': 'Are you sure to unbind?',
      'binding_feature': 'Binding feature coming soon',
      'change_password_feature': 'Change password feature coming soon',
      'set_payment_password': 'Set Payment Password',
      'payment_password_feature': 'Set payment password feature coming soon',

      // Agreement
      'user_agreement': 'User Agreement',
      'privacy_policy': 'Privacy Policy',

      // History
      'no_history': 'No Browse History',
    },
  };

  String get(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['zh']![key] ??
        key;
  }

  String getWithParams(String key, Map<String, dynamic> params) {
    String result = get(key);
    params.forEach((paramKey, value) {
      result = result.replaceAll('{$paramKey}', value.toString());
    });
    return result;
  }

  // 简化的属性访问
  String get home => get('home');
  String get category => get('category');
  String get community => get('community');
  String get cart => get('cart');
  String get profile => get('profile');

  String get confirm => get('confirm');
  String get cancel => get('cancel');
  String get save => get('save');
  String get delete => get('delete');
  String get edit => get('edit');
  String get submit => get('submit');
  String get search => get('search');
  String get loading => get('loading');
  String get noData => get('noData');

  String get searchHint => get('search_hint');
  String get hotRecommend => get('hot_recommend');
  String get subCategory => get('sub_category');

  String get selectAll => get('select_all');
  String get total => get('total');
  String get checkout => get('checkout');
  String get clear => get('clear');
  String get emptyCart => get('empty_cart');
  String get goShopping => get('go_shopping');
  String get clearCart => get('clear_cart');
  String get confirmClear => get('confirm_clear');
  String get confirmClearCache => get('confirm_clear_cache');
  String selectedItems(int count) =>
      getWithParams('selected_items', {'count': count});
  String totalPrice(double price) =>
      getWithParams('total_price', {'price': price.toStringAsFixed(2)});

  String get myOrders => get('my_orders');
  String get allOrders => get('all_orders');
  String get pending => get('pending');
  String get paid => get('paid');
  String get shipped => get('shipped');
  String get completed => get('completed');
  String get cancelled => get('cancelled');
  String get viewDetail => get('view_detail');
  String get noOrders => get('no_orders');

  String get myFavorites => get('my_favorites');
  String get addressManage => get('address_manage');
  String get coupons => get('coupons');
  String get history => get('history');
  String get settings => get('settings');
  String get aboutUs => get('about_us');
  String get login => get('login');
  String get logout => get('logout');

  String get darkMode => get('dark_mode');
  String get notifications => get('notifications');
  String get language => get('language');
  String get clearCache => get('clear_cache');
  String get checkUpdate => get('check_update');
  String get currentVersion => get('current_version');
  String get latestVersion => get('latest_version');
  String get generalSettings => get('general_settings');
  String get privacySettings => get('privacy_settings');
  String get privacyPolicy => get('privacy_policy');
  String get userAgreement => get('user_agreement');
  String get accountSecurity => get('account_security');
  String get confirmLogout => get('confirm_logout');
  String get cacheCleared => get('cache_cleared');
  String get addToCart => get('add_to_cart');
  String get buyNow => get('buy_now');
  String get selectColor => get('select_color');
  String get selectSize => get('select_size');
  String get quantity => get('quantity');
  String get sales => get('sales');
  String get stock => get('stock');
  String get addedToCart => get('added_to_cart');
  String get addedToFavorites => get('added_to_favorites');
  String get removedFromFavorites => get('removed_from_favorites');
  String cachedSize(double size) =>
      getWithParams('cached_size', {'size': size});

  // Profile page
  String get user => get('user');
  String get register => get('register');
  String get viewAll => get('view_all');
  String get afterSale => get('after_sale');
  String get favorite => get('favorite');
  String get address => get('address');
  String get coupon => get('coupon');
  String get browseHistory => get('browse_history');
  String get locationServices => get('location_services');

  String get recommend => get('recommend');
  String get follow => get('follow');
  String get hot => get('hot');

  String get available => get('available');
  String get used => get('used');
  String get expired => get('expired');
  String get noContent => get('no_content');

  String get addAddress => get('add_address');
  String get noAddress => get('no_address');

  String get version => get('version');
  String get icpRecord => get('icp_record');
  String get qualityLife => get('quality_life');

  String get accountBinding => get('account_binding');
  String get phoneBinding => get('phone_binding');
  String get emailBinding => get('email_binding');
  String get wechatBinding => get('wechat_binding');
  String get alipayBinding => get('alipay_binding');
  String get securitySettings => get('security_settings');
  String get changePassword => get('change_password');
  String get paymentPassword => get('payment_password');
  String get fingerprintUnlock => get('fingerprint_unlock');
  String get faceUnlock => get('face_unlock');
  String get loginHistory => get('login_history');
  String get securityLevel => get('security_level');
  String get high => get('high');
  String get medium => get('medium');
  String get low => get('low');
  String get unbound => get('unbound');
  String get bound => get('bound');
  String get unbind => get('unbind');
  String get bind => get('bind');
  String get cancelBind => get('cancel_bind');
  String get bindingFeature => get('binding_feature');
  String get changePasswordFeature => get('change_password_feature');
  String get setPaymentPassword => get('set_payment_password');
  String get paymentPasswordFeature => get('payment_password_feature');

  String get clearHistory => get('clear_history');
  String get confirmClearHistory => get('confirm_clear_history');
  String get historyCleared => get('history_cleared');
  String get noHistory => get('no_history');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
