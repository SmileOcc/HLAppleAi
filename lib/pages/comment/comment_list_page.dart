import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/comment_provider.dart';

class CommentListPage extends StatefulWidget {
  const CommentListPage({super.key});

  @override
  State<CommentListPage> createState() => _CommentListPageState();
}

class _CommentListPageState extends State<CommentListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().loadComments();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CommentProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '评论列表',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CommentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.comments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.comments.isEmpty) {
            return const Center(
              child: Text(
                '暂无评论',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.comments.length + 1,
              itemBuilder: (context, index) {
                if (index >= provider.comments.length) {
                  return _buildFooter(provider);
                }
                return _buildCommentItem(
                  provider.comments[index],
                  isLast: index == provider.comments.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(CommentProvider provider) {
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!provider.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '暂无更多数据',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCommentItem(dynamic comment, {bool isLast = false}) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.avatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLikeButton(comment),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (!isLast) const Divider(height: 24, color: AppColors.divider),
        ],
      ),
    );
  }

  Widget _buildLikeButton(dynamic comment) {
    return GestureDetector(
      onTap: () {
        // TODO: toggle like
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            comment.isLiked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: comment.isLiked
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            comment.likes.toString(),
            style: TextStyle(
              fontSize: 12,
              color: comment.isLiked
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
