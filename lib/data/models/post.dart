class User {
  final int id;
  final String name;
  final String avatar;
  final bool isFollowed;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    this.isFollowed = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      isFollowed: json['isFollowed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar, 'isFollowed': isFollowed};
  }
}

class Post {
  final int id;
  final String title;
  final String content;
  final List<String> images;
  final User author;
  final int likes;
  final int comments;
  final DateTime createTime;
  final bool isLiked;
  final bool isCollected;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    required this.author,
    required this.likes,
    required this.comments,
    required this.createTime,
    this.isLiked = false,
    this.isCollected = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      author: User.fromJson(json['author'] ?? {}),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : DateTime.now(),
      isLiked: json['isLiked'] ?? false,
      isCollected: json['isCollected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'images': images,
      'author': author.toJson(),
      'likes': likes,
      'comments': comments,
      'createTime': createTime.toIso8601String(),
      'isLiked': isLiked,
      'isCollected': isCollected,
    };
  }
}
