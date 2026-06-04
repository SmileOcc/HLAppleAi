import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_register_page.dart';
import '../main/main_page.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const _pageData = [
    _GuidePageData(
      icon: Icons.shopping_bag,
      title: '欢迎来到HLAppleAi',
      description: '海量商品，一手掌握\n品质生活从这里开始',
      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    ),
    _GuidePageData(
      icon: Icons.search,
      title: '浏览海量商品',
      description: '发现你心仪的好物\n智能推荐，精准匹配',
      colors: [Color(0xFF4ECDC4), Color(0xFF2ECC71)],
    ),
    _GuidePageData(
      icon: Icons.shopping_cart,
      title: '轻松购物下单',
      description: '一键加入购物车\n快捷支付，安全无忧',
      colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
    ),
    _GuidePageData(
      icon: Icons.forum,
      title: '社区互动分享',
      description: '与千万用户分享购物体验\n真实评价，放心选购',
      colors: [Color(0xFFFDCB6E), Color(0xFFE17055)],
    ),
    _GuidePageData(
      icon: Icons.rocket_launch,
      title: '准备就绪',
      description: '开启你的购物之旅\n立即登录，畅享优惠',
      colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
      isLast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  void _goToLoginRegister() {
    _markSeen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginRegisterPage(fromOnboarding: true),
      ),
    );
  }

  void _goToHome() {
    _markSeen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pageData.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) => _buildGuidePage(_pageData[index]),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _currentPage < _pageData.length - 1
                ? _buildNavBar()
                : _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidePage(_GuidePageData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.colors,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 72, color: Colors.white),
            ),
            const SizedBox(height: 48),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pageData.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _goToHome,
          child: Text(
            '跳过',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _goToLoginRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('登录', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 24),
            OutlinedButton(
              onPressed: _goToLoginRegister,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('注册', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _goToHome,
          child: Text(
            '暂不登录，先逛逛',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuidePageData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> colors;
  final bool isLast;

  const _GuidePageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.colors,
    this.isLast = false,
  });
}
