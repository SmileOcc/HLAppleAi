import 'package:flutter/material.dart';
import '../data/models/comment.dart';
import '../data/services/mock_data_service.dart';

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const int pageSize = 10;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> loadComments() async {
    _isLoading = true;
    notifyListeners();

    final comments = await MockDataService.getComments(
      page: _page,
      pageSize: pageSize,
    );
    _comments = comments;
    _hasMore = comments.length >= pageSize;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _page++;
    final moreComments = await MockDataService.getComments(
      page: _page,
      pageSize: pageSize,
    );
    if (moreComments.isNotEmpty) {
      _comments.addAll(moreComments);
      _hasMore = moreComments.length >= pageSize;
    } else {
      _hasMore = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _comments.clear();
    await loadComments();
  }
}
