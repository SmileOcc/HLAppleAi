import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/post_card.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadPosts();
    });
    _scrollController.addListener(_onScroll);
  }

  List<String> _getTabs(AppLocalizations l10n) {
    return [l10n.recommend, l10n.follow, l10n.hot];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<CommunityProvider>().setTab(_tabController.index);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CommunityProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = _getTabs(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.community),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit_note), onPressed: () {}),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) => _buildPostList()).toList(),
      ),
    );
  }

  Widget _buildPostList() {
    final l10n = AppLocalizations.of(context);
    return Consumer<CommunityProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.posts.isEmpty) {
          return Center(
            child: Text(
              l10n.noContent,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final post = provider.posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  debugPrint('Navigating to post detail: ${post.title}');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  );
                },
                onLike: () => provider.toggleLike(post.id),
                onComment: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  );
                },
                onCollect: () => provider.toggleCollect(post.id),
              );
            },
          ),
        );
      },
    );
  }
}
