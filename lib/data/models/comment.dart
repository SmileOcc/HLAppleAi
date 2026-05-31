class Comment {
  final int id;
  final String avatar;
  final String username;
  final String content;
  final String time;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.avatar,
    required this.username,
    required this.content,
    required this.time,
    this.likes = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      avatar: json['avatar'],
      username: json['username'],
      content: json['content'],
      time: json['time'],
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'avatar': avatar,
    'username': username,
    'content': content,
    'time': time,
    'likes': likes,
    'isLiked': isLiked,
  };
}
