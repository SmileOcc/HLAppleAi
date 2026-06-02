import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/post.dart';
import '../../providers/home_provider.dart';
import '../../widgets/post_card.dart';
import '../community/post_detail_page.dart';

class PostFavoritesPage extends StatelessWidget {
  const PostFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帖子收藏')),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          final collected = provider.posts.where((p) => p.isCollected).toList();
          if (collected.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无收藏帖子',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.loadPosts(),
                    child: const Text(
                      '去社区逛逛',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: collected.length,
            itemBuilder: (context, index) {
              final post = collected[index] as Post;
              return PostCard(
                post: post,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  );
                },
                onLike: () => provider.toggleLike(post.id),
                onCollect: () => provider.toggleCollect(post.id),
              );
            },
          );
        },
      ),
    );
  }
}
