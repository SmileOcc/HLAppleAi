import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/post.dart';

class PostDetailPage extends StatefulWidget {
  final Post? post;
  final String? postId;

  const PostDetailPage({super.key, this.post, this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Post _post;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _post = widget.post ?? _createMockPost(widget.postId ?? 'default');
    _loadComments();
  }

  Post _createMockPost(String postId) {
    return Post(
      id: int.tryParse(postId) ?? 1,
      title: '官方公告',
      content: '欢迎来到社区！这里有最新的商品资讯和优惠活动。\n\n关注我们，获取更多精彩内容！',
      images: [
        'https://picsum.photos/400/300?random=101',
        'https://picsum.photos/400/300?random=102',
      ],
      author: User(
        id: 1,
        name: '官方社区',
        avatar: 'https://picsum.photos/100/100?random=100',
      ),
      likes: 520,
      comments: 88,
      createTime: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    _comments.addAll([
      {
        'id': 1,
        'user': {
          'name': '用户A',
          'avatar': 'https://picsum.photos/100/100?random=60',
        },
        'content': '写的真好，支持一下！',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
        'likes': 5,
      },
      {
        'id': 2,
        'user': {
          'name': '用户B',
          'avatar': 'https://picsum.photos/100/100?random=61',
        },
        'content': '这个产品我也买了，确实不错',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'likes': 3,
      },
      {
        'id': 3,
        'user': {
          'name': '用户C',
          'avatar': 'https://picsum.photos/100/100?random=62',
        },
        'content': '多少钱入手的？',
        'time': DateTime.now().subtract(const Duration(hours: 3)),
        'likes': 1,
      },
      {
        'id': 4,
        'user': {
          'name': '用户D',
          'avatar': 'https://picsum.photos/100/100?random=63',
        },
        'content': '看起来很不错啊',
        'time': DateTime.now().subtract(const Duration(hours: 4)),
        'likes': 8,
      },
      {
        'id': 5,
        'user': {
          'name': '用户E',
          'avatar': 'https://picsum.photos/100/100?random=64',
        },
        'content': '收藏了，等有优惠活动再买',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'likes': 2,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '帖子详情',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorInfo(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildContent(),
                  if (_post.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildImages(),
                  ],
                  const SizedBox(height: 20),
                  _buildActionBar(l10n),
                  const Divider(height: 32),
                  _buildCommentsSection(l10n),
                ],
              ),
            ),
          ),
          _buildCommentInput(l10n),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: CachedNetworkImageProvider(_post.author.avatar),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _post.author.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(_post.createTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            '关注',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _post.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      _post.content,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
    );
  }

  Widget _buildImages() {
    if (_post.images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: _post.images.first,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _post.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _post.images[index],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionBar(AppLocalizations l10n) {
    return Row(
      children: [
        _buildActionItem(
          icon: _post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          count: _post.likes,
          label: '点赞',
          isActive: _post.isLiked,
          onTap: () {
            setState(() {
              _post = Post(
                id: _post.id,
                title: _post.title,
                content: _post.content,
                images: _post.images,
                author: _post.author,
                likes: _post.isLiked ? _post.likes - 1 : _post.likes + 1,
                comments: _post.comments,
                createTime: _post.createTime,
                isLiked: !_post.isLiked,
                isCollected: _post.isCollected,
              );
            });
          },
        ),
        const SizedBox(width: 32),
        _buildActionItem(
          icon: Icons.comment_outlined,
          count: _post.comments,
          label: '评论',
          onTap: () {},
        ),
        const SizedBox(width: 32),
        _buildActionItem(
          icon: _post.isCollected ? Icons.bookmark : Icons.bookmark_border,
          count: null,
          label: '收藏',
          isActive: _post.isCollected,
          onTap: () {
            setState(() {
              _post = Post(
                id: _post.id,
                title: _post.title,
                content: _post.content,
                images: _post.images,
                author: _post.author,
                likes: _post.likes,
                comments: _post.comments,
                createTime: _post.createTime,
                isLiked: _post.isLiked,
                isCollected: !_post.isCollected,
              );
            });
          },
        ),
        const SizedBox(width: 32),
        _buildActionItem(
          icon: Icons.share_outlined,
          count: null,
          label: '分享',
          onTap: () {
            ToastUtil.show(context, '分享功能开发中');
          },
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    int? count,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            count != null ? '$count' : label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '评论 (${_comments.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return _buildCommentItem(comment);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final user = comment['user'] as Map<String, dynamic>;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: CachedNetworkImageProvider(user['avatar']),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(comment['time']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment['content'],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${comment['likes']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '说点什么...',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_commentController.text.isNotEmpty) {
                setState(() {
                  _comments.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'user': {
                      'name': '我',
                      'avatar': 'https://picsum.photos/100/100?random=99',
                    },
                    'content': _commentController.text,
                    'time': DateTime.now(),
                    'likes': 0,
                  });
                });
                _commentController.clear();
                FocusScope.of(context).unfocus();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '发送',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${time.month}-${time.day}';
  }
}
