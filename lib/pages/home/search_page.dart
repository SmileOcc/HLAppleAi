import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/product.dart';
import '../../data/services/mock_product_service.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _hotWords = [
    'iPhone 15',
    'MacBook Pro',
    'AirPods',
    'iPad Air',
    'Apple Watch',
    'MagSafe',
  ];
  List<String> _searchHistory = [];
  List<Product> _searchResults = [];
  List<Product> _recommendProducts = [];
  bool _isSearching = false;
  bool _isLoading = true;

  bool _hasText = false;
  List<String> _matchSuggestions = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadRecommendProducts();
    _searchController.addListener(() {
      final hasText = _searchController.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
      _updateMatchSuggestions(_searchController.text);
      setState(() => _isEditing = true);
    });
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _matchSuggestions = [];
          _isEditing = false;
        });
      }
    });
  }

  void _updateMatchSuggestions(String query) {
    if (query.trim().isEmpty) {
      setState(() => _matchSuggestions = []);
      return;
    }
    final lowerQuery = query.toLowerCase();
    final suggestions = <String>{};
    for (final word in _searchHistory) {
      if (word.toLowerCase().contains(lowerQuery)) {
        suggestions.add(word);
      }
    }
    for (final word in _hotWords) {
      if (word.toLowerCase().contains(lowerQuery)) {
        suggestions.add(word);
      }
    }
    setState(() => _matchSuggestions = suggestions.take(8).toList());
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSearch(suggestion);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    if (mounted) {
      setState(() => _searchHistory = history);
    }
  }

  Future<void> _saveSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 9) {
      _searchHistory = _searchHistory.sublist(0, 9);
    }
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() => _searchHistory = []);
  }

  Future<void> _loadRecommendProducts() async {
    final service = MockProductService();
    final products = await service.getHotProducts();
    if (mounted) {
      setState(() {
        _recommendProducts = products.take(10).toList();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    _saveSearchHistory(query);
    setState(() {
      _isSearching = true;
      _isEditing = false;
    });
    final lowerQuery = query.toLowerCase();
    _searchResults = _generateMockSearchResults(query, lowerQuery);
    setState(() => _isSearching = false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _isEditing = false;
    });
  }

  List<Product> _generateMockSearchResults(String query, String lowerQuery) {
    final List<String> mockNames = [
      '$query 标准版',
      '$query 升级版',
      '$query Pro Max',
      '$query 青春版',
      '$query 限量版',
      '$query 经典款',
      '$query 2024新款',
      '$query 尊享版',
      '$query 基础款',
      '$query 旗舰版',
      '$query 迷你版',
      '$query 加强版',
      '$query 专业版',
      '$query 轻薄版',
      '$query 定制版',
    ];

    return List.generate(mockNames.length, (index) {
      return Product(
        id: 1000 + index,
        name: mockNames[index],
        price: (99 + index * 50.0).toDouble(),
        originalPrice: (199 + index * 80.0).toDouble(),
        image: 'https://picsum.photos/seed/$query$index/200/200',
        sales: 1000 - index * 50,
        rating: 4.5 + (index % 5) * 0.1,
        description: '这是关于$query的$mockNames[index]商品描述，性能卓越，品质保证。',
        categoryId: index % 5 + 1,
        stock: 100 - index * 5,
        colors: const ['深空灰', '银色', '金色'],
        sizes: const ['64GB', '128GB', '256GB'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: _buildSearchField(l10n),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _searchFocusNode.unfocus();
              setState(() => _matchSuggestions = []);
            },
            child: _searchResults.isNotEmpty || _isSearching
                ? _buildSearchResults()
                : _buildDefaultContent(),
          ),
          if (_isEditing && _matchSuggestions.isNotEmpty) _buildMatchOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _onSearch,
            ),
          ),
          if (_hasText)
            IconButton(
              icon: const Icon(
                Icons.clear,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: _clearSearch,
              padding: const EdgeInsets.only(right: 8),
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildMatchOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.white,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: _matchSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _matchSuggestions[index];
            return ListTile(
              leading: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              title: _buildHighlightText(suggestion, _searchController.text),
              onTap: () => _onSuggestionTap(suggestion),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHighlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 14));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(text, style: const TextStyle(fontSize: 14));
    }

    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, startIndex),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(endIndex),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          _buildSearchHistorySection(),
          const SizedBox(height: 24),
        ],
        _buildHotWordsSection(),
        const SizedBox(height: 24),
        _buildRecommendSection(),
      ],
    );
  }

  Widget _buildSearchHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: _clearSearchHistory,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _searchHistory.map((word) {
            return GestureDetector(
              onTap: () {
                _searchController.text = word;
                _onSearch(word);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHotWordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.whatshot, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            const Text(
              '热门搜索',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _hotWords.map((word) {
            return GestureDetector(
              onTap: () {
                _searchController.text = word;
                _onSearch(word);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendSection() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.recommend, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              '推荐商品',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recommendProducts.map((product) => _buildRecommendItem(product)),
      ],
    );
  }

  Widget _buildRecommendItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              '未找到相关商品',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _clearSearch, child: const Text('重新搜索')),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¥${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}
