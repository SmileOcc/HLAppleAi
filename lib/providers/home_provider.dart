import 'package:flutter/material.dart';
import '../data/services/mock_data_service.dart';
import '../data/models/product.dart';
import '../data/models/category.dart';
import '../data/models/post.dart';

class HomeProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _quickCategories = [];
  List<Product> _recommendProducts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  List<Map<String, dynamic>> get banners => _banners;
  List<Map<String, dynamic>> get quickCategories => _quickCategories;
  List<Product> get recommendProducts => _recommendProducts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        MockDataService.getBanners(),
        MockDataService.getQuickCategories(),
        MockDataService.getRecommendProducts(),
      ]);

      _banners = results[0] as List<Map<String, dynamic>>;
      _quickCategories = results[1] as List<Map<String, dynamic>>;
      _recommendProducts = results[2] as List<Product>;
      _page = 1;
      _hasMore = true;
    } catch (e) {
      debugPrint('HomeProvider loadData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final moreProducts = await MockDataService.getRecommendProducts();
      if (moreProducts.isNotEmpty) {
        _recommendProducts.addAll(moreProducts);
        _page++;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('HomeProvider loadMore error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _recommendProducts.clear();
    await loadData();
  }
}

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Product> _products = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await MockDataService.getCategories();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
        await loadProducts();
      }
    } catch (e) {
      debugPrint('CategoryProvider loadCategories error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_selectedCategory == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _products = await MockDataService.getProductsByCategory(
        _selectedCategory!.id,
      );
    } catch (e) {
      debugPrint('CategoryProvider loadProducts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}

class CommunityProvider extends ChangeNotifier {
  List<dynamic> _posts = [];
  int _currentTab = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  List<dynamic> get posts => _posts;
  int get currentTab => _currentTab;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  void setTab(int index) {
    _currentTab = index;
    _posts.clear();
    _page = 1;
    _hasMore = true;
    notifyListeners();
    loadPosts();
  }

  Future<void> loadPosts() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final types = ['recommend', 'follow', 'hot'];
      final posts = await MockDataService.getPosts(type: types[_currentTab]);
      _posts = posts;
    } catch (e) {
      debugPrint('CommunityProvider loadPosts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final types = ['recommend', 'follow', 'hot'];
      final morePosts = await MockDataService.getPosts(
        type: types[_currentTab],
      );
      if (morePosts.isNotEmpty) {
        _posts.addAll(morePosts);
        _page++;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('CommunityProvider loadMore error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _posts.clear();
    _page = 1;
    _hasMore = true;
    await loadPosts();
  }

  void toggleLike(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final isLiked = !post.isLiked;
      final likes = isLiked ? post.likes + 1 : post.likes - 1;
      _posts[index] = Post(
        id: post.id,
        title: post.title,
        content: post.content,
        images: post.images,
        author: post.author,
        likes: likes,
        comments: post.comments,
        createTime: post.createTime,
        isLiked: isLiked,
        isCollected: post.isCollected,
      );
      notifyListeners();
    }
  }

  void toggleCollect(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = Post(
        id: post.id,
        title: post.title,
        content: post.content,
        images: post.images,
        author: post.author,
        likes: post.likes,
        comments: post.comments,
        createTime: post.createTime,
        isLiked: post.isLiked,
        isCollected: !post.isCollected,
      );
      notifyListeners();
    }
  }
}
