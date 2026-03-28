import 'dart:async';
import 'dart:convert';

class RichTextPost {
  final String id;
  final String content;
  final String deltaJson;
  final List<String> images;
  final String? category;
  final List<String> topics;
  final String? location;
  final String? linkedProductId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDraft;

  RichTextPost({
    required this.id,
    required this.content,
    required this.deltaJson,
    this.images = const [],
    this.category,
    this.topics = const [],
    this.location,
    this.linkedProductId,
    required this.createdAt,
    required this.updatedAt,
    this.isDraft = false,
  });

  factory RichTextPost.fromJson(Map<String, dynamic> json) {
    return RichTextPost(
      id: json['id'] as String,
      content: json['content'] as String,
      deltaJson: json['deltaJson'] as String,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] as String?,
      topics: List<String>.from(json['topics'] ?? []),
      location: json['location'] as String?,
      linkedProductId: json['linkedProductId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'deltaJson': deltaJson,
      'images': images,
      'category': category,
      'topics': topics,
      'location': location,
      'linkedProductId': linkedProductId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDraft': isDraft,
    };
  }

  RichTextPost copyWith({
    String? id,
    String? content,
    String? deltaJson,
    List<String>? images,
    String? category,
    List<String>? topics,
    String? location,
    String? linkedProductId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDraft,
  }) {
    return RichTextPost(
      id: id ?? this.id,
      content: content ?? this.content,
      deltaJson: deltaJson ?? this.deltaJson,
      images: images ?? this.images,
      category: category ?? this.category,
      topics: topics ?? this.topics,
      location: location ?? this.location,
      linkedProductId: linkedProductId ?? this.linkedProductId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}

class MockRichTextService {
  static final MockRichTextService _instance = MockRichTextService._internal();
  factory MockRichTextService() => _instance;
  MockRichTextService._internal();

  final List<RichTextPost> _posts = [];
  final Map<String, RichTextPost> _drafts = {};
  int _idCounter = 1;

  static const int simulateDelay = 500;

  void _initializeMockData() {
    if (_posts.isNotEmpty) return;

    final now = DateTime.now();
    _posts.addAll([
      RichTextPost(
        id: 'post_1',
        content: '今天分享一款超好用的护肤套装！\n\n质地轻盈，吸收很快，用完皮肤滑滑的~\n\n强烈推荐给大家！',
        deltaJson: jsonEncode([
          {'insert': '今天分享一款超好用的护肤套装！\n\n'},
          {'insert': '质地轻盈，吸收很快，用完皮肤滑滑的~\n\n'},
          {
            'attributes': {'bold': true},
            'insert': '强烈推荐给大家！',
          },
          {'insert': '\n'},
        ]),
        images: [
          'https://picsum.photos/400/300?random=1',
          'https://picsum.photos/400/300?random=2',
        ],
        category: 'share',
        topics: ['#好物分享#', '#护肤心得#'],
        location: '上海市 浦东新区',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      RichTextPost(
        id: 'post_2',
        content: '关于购物的几点心得体会：\n\n1. 先列清单再购买\n2. 关注优惠信息\n3. 理性消费，量入为出',
        deltaJson: jsonEncode([
          {'insert': '关于购物的几点心得体会：\n\n'},
          {
            'attributes': {'bold': true},
            'insert': '1. 先列清单再购买\n',
          },
          {
            'attributes': {'bold': true},
            'insert': '2. 关注优惠信息\n',
          },
          {
            'attributes': {'bold': true},
            'insert': '3. 理性消费，量入为出',
          },
          {'insert': '\n'},
        ]),
        images: [],
        category: 'experience',
        topics: ['#省钱攻略#', '#购物心得#'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      RichTextPost(
        id: 'post_3',
        content: '求推荐适合学生党的平价护肤品~\n\n预算有限，但想要效果好一点的~\n\n谢谢大家！',
        deltaJson: jsonEncode([
          {'insert': '求推荐适合学生党的平价护肤品~\n\n'},
          {'insert': '预算有限，但想要效果好一点的~\n\n'},
          {
            'attributes': {'italic': true},
            'insert': '谢谢大家！',
          },
          {'insert': '\n'},
        ]),
        images: ['https://picsum.photos/400/300?random=3'],
        category: 'question',
        topics: ['#护肤求助#', '#学生党#'],
        location: '北京市 朝阳区',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  Future<List<RichTextPost>> getPosts({
    String? category,
    List<String>? topics,
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    _initializeMockData();

    var filteredPosts = _posts.where((post) {
      if (category != null && post.category != category) return false;
      if (topics != null && topics.isNotEmpty) {
        final hasTopic = topics.any((t) => post.topics.contains(t));
        if (!hasTopic) return false;
      }
      return true;
    }).toList();

    filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= filteredPosts.length) return [];

    return filteredPosts.sublist(
      startIndex,
      endIndex > filteredPosts.length ? filteredPosts.length : endIndex,
    );
  }

  Future<RichTextPost?> getPostById(String id) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    _initializeMockData();

    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<RichTextPost> createPost({
    required String content,
    required String deltaJson,
    List<String> images = const [],
    String? category,
    List<String> topics = const [],
    String? location,
    String? linkedProductId,
    bool isDraft = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    _initializeMockData();

    final now = DateTime.now();
    final newPost = RichTextPost(
      id: 'post_${_idCounter++}',
      content: content,
      deltaJson: deltaJson,
      images: images,
      category: category,
      topics: topics,
      location: location,
      linkedProductId: linkedProductId,
      createdAt: now,
      updatedAt: now,
      isDraft: isDraft,
    );

    _posts.insert(0, newPost);
    return newPost;
  }

  Future<RichTextPost> updatePost({
    required String id,
    String? content,
    String? deltaJson,
    List<String>? images,
    String? category,
    List<String>? topics,
    String? location,
    String? linkedProductId,
  }) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    _initializeMockData();

    final index = _posts.indexWhere((post) => post.id == id);
    if (index == -1) {
      throw Exception('Post not found');
    }

    final updatedPost = _posts[index].copyWith(
      content: content,
      deltaJson: deltaJson,
      images: images,
      category: category,
      topics: topics,
      location: location,
      linkedProductId: linkedProductId,
      updatedAt: DateTime.now(),
    );

    _posts[index] = updatedPost;
    return updatedPost;
  }

  Future<bool> deletePost(String id) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    _initializeMockData();

    final index = _posts.indexWhere((post) => post.id == id);
    if (index == -1) return false;

    _posts.removeAt(index);
    return true;
  }

  Future<RichTextPost> saveDraft({
    String? content,
    String? deltaJson,
    List<String> images = const [],
    String? category,
    List<String> topics = const [],
    String? location,
    String? linkedProductId,
  }) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));

    final now = DateTime.now();
    final draftId = 'draft_${now.millisecondsSinceEpoch}';

    final draft = RichTextPost(
      id: draftId,
      content: content ?? '',
      deltaJson: deltaJson ?? '[]',
      images: images,
      category: category,
      topics: topics,
      location: location,
      linkedProductId: linkedProductId,
      createdAt: now,
      updatedAt: now,
      isDraft: true,
    );

    _drafts[draftId] = draft;
    return draft;
  }

  Future<List<RichTextPost>> getDrafts() async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    return _drafts.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<bool> deleteDraft(String id) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    return _drafts.remove(id) != null;
  }

  Future<RichTextPost?> getDraftById(String id) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));
    return _drafts[id];
  }

  Future<List<String>> getTrendingTopics({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));

    final allTopics = <String, int>{};
    for (final post in _posts) {
      for (final topic in post.topics) {
        allTopics[topic] = (allTopics[topic] ?? 0) + 1;
      }
    }

    final sortedTopics = allTopics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTopics.take(limit).map((e) => e.key).toList();
  }

  Future<Map<String, int>> getCategoryStats() async {
    await Future.delayed(const Duration(milliseconds: simulateDelay));

    final stats = <String, int>{};
    for (final post in _posts) {
      final category = post.category ?? 'other';
      stats[category] = (stats[category] ?? 0) + 1;
    }
    return stats;
  }
}
