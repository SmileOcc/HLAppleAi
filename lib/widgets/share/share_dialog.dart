import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

enum SharePlatform {
  wechat,
  wechatMoment,
  weibo,
  qq,
  qzone,
  facebook,
  telegram,
  copyLink,
  community,
  more,
}

class SharePlatformConfig {
  final SharePlatform platform;
  final String name;
  final Color color;
  final IconData icon;

  const SharePlatformConfig({
    required this.platform,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class ShareDialog extends StatelessWidget {
  final String title;
  final String desc;
  final String imageUrl;
  final String link;
  final List<SharePlatform>? firstRowPlatforms;
  final List<SharePlatform>? secondRowPlatforms;
  final String? communityPostId;
  final VoidCallback? onCommunityTap;

  const ShareDialog({
    super.key,
    required this.title,
    required this.desc,
    required this.imageUrl,
    required this.link,
    this.firstRowPlatforms,
    this.secondRowPlatforms,
    this.communityPostId,
    this.onCommunityTap,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String desc,
    required String imageUrl,
    required String link,
    List<SharePlatform>? firstRowPlatforms,
    List<SharePlatform>? secondRowPlatforms,
    String? communityPostId,
    VoidCallback? onCommunityTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareDialog(
        title: title,
        desc: desc,
        imageUrl: imageUrl,
        link: link,
        firstRowPlatforms: firstRowPlatforms,
        secondRowPlatforms: secondRowPlatforms,
        communityPostId: communityPostId,
        onCommunityTap: onCommunityTap,
      ),
    );
  }

  static List<SharePlatform> defaultFirstRow = [
    SharePlatform.wechat,
    SharePlatform.wechatMoment,
    SharePlatform.weibo,
    SharePlatform.qq,
    SharePlatform.qzone,
    SharePlatform.facebook,
    SharePlatform.telegram,
  ];

  static List<SharePlatform> defaultSecondRow = [
    SharePlatform.copyLink,
    SharePlatform.community,
    SharePlatform.more,
  ];

  static final Map<SharePlatform, SharePlatformConfig> platformConfigs = {
    SharePlatform.wechat: const SharePlatformConfig(
      platform: SharePlatform.wechat,
      name: '微信',
      color: Color(0xFF07C160),
      icon: Icons.chat_bubble,
    ),
    SharePlatform.wechatMoment: const SharePlatformConfig(
      platform: SharePlatform.wechatMoment,
      name: '朋友圈',
      color: Color(0xFF07C160),
      icon: Icons.group,
    ),
    SharePlatform.weibo: const SharePlatformConfig(
      platform: SharePlatform.weibo,
      name: '微博',
      color: Color(0xFFE6162D),
      icon: Icons.alternate_email,
    ),
    SharePlatform.qq: const SharePlatformConfig(
      platform: SharePlatform.qq,
      name: 'QQ',
      color: Color(0xFF12B7F5),
      icon: Icons.person,
    ),
    SharePlatform.qzone: const SharePlatformConfig(
      platform: SharePlatform.qzone,
      name: 'QQ空间',
      color: Color(0xFFFFE04B),
      icon: Icons.cloud,
    ),
    SharePlatform.facebook: const SharePlatformConfig(
      platform: SharePlatform.facebook,
      name: 'Facebook',
      color: Color(0xFF1877F2),
      icon: Icons.facebook,
    ),
    SharePlatform.telegram: const SharePlatformConfig(
      platform: SharePlatform.telegram,
      name: 'Telegram',
      color: Color(0xFF0088CC),
      icon: Icons.send,
    ),
    SharePlatform.copyLink: const SharePlatformConfig(
      platform: SharePlatform.copyLink,
      name: '复制链接',
      color: Color(0xFF666666),
      icon: Icons.link,
    ),
    SharePlatform.community: const SharePlatformConfig(
      platform: SharePlatform.community,
      name: '社区',
      color: Color(0xFFFF6B6B),
      icon: Icons.forum,
    ),
    SharePlatform.more: const SharePlatformConfig(
      platform: SharePlatform.more,
      name: '更多',
      color: Color(0xFF888888),
      icon: Icons.more_horiz,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final firstRow = firstRowPlatforms ?? defaultFirstRow;
    final secondRow = secondRowPlatforms ?? defaultSecondRow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '分享到',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildScrollableRow(context, firstRow),
          if (secondRow.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildScrollableRow(context, secondRow, alignLeft: true),
          ],
          const SizedBox(height: 16),
          _buildCancelButton(context),
          SafeArea(child: const SizedBox(height: 8)),
        ],
      ),
    );
  }

  Widget _buildScrollableRow(
    BuildContext context,
    List<SharePlatform> platforms, {
    bool alignLeft = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = alignLeft ? 80.0 : (screenWidth - 32) / 4.5;

    return SizedBox(
      height: 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: platforms.map((platform) {
              final config = platformConfigs[platform]!;
              return SizedBox(
                width: itemWidth,
                child: _buildShareItem(context, config),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShareItem(BuildContext context, SharePlatformConfig config) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _handleShare(context, config.platform);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(config.icon, color: config.color, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            config.name,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          '取消',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  void _handleShare(BuildContext context, SharePlatform platform) {
    switch (platform) {
      case SharePlatform.wechat:
        _shareToWechat();
        break;
      case SharePlatform.wechatMoment:
        _shareToWechatMoment();
        break;
      case SharePlatform.weibo:
        _shareToWeibo();
        break;
      case SharePlatform.qq:
        _shareToQQ();
        break;
      case SharePlatform.qzone:
        _shareToQzone();
        break;
      case SharePlatform.facebook:
        _shareToFacebook();
        break;
      case SharePlatform.telegram:
        _shareToTelegram();
        break;
      case SharePlatform.copyLink:
        _copyLink(context);
        break;
      case SharePlatform.community:
        _handleCommunity(context);
        break;
      case SharePlatform.more:
        _openSystemShareSheet(context);
        break;
    }
  }

  void _shareToWechat() {
    print('Share to WeChat: $title - $link');
  }

  void _shareToWechatMoment() {
    print('Share to WeChat Moment: $title - $link');
  }

  void _shareToWeibo() {
    print('Share to Weibo: $title - $link');
  }

  void _shareToQQ() {
    print('Share to QQ: $title - $link');
  }

  void _shareToQzone() {
    print('Share to QZone: $title - $link');
  }

  void _shareToFacebook() {
    print('Share to Facebook: $title - $link');
  }

  void _shareToTelegram() {
    print('Share to Telegram: $title - $link');
  }

  void _copyLink(BuildContext context) {
    print('Copy link: $link');
  }

  void _handleCommunity(BuildContext context) {
    if (onCommunityTap != null) {
      onCommunityTap!();
    } else if (communityPostId != null) {
      print('Navigate to community post: $communityPostId');
    }
  }

  void _openSystemShareSheet(BuildContext context) {
    Clipboard.setData(ClipboardData(text: link));
    print('Open system share sheet with: $title - $link');
  }
}
