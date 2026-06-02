import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/product.dart';
import '../home/product_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, dynamic>> _history = [];
  final Set<int> _selected = {};
  bool _selecting = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final now = DateTime.now();
    _history.addAll(
      List.generate(12, (index) {
        return {
          'product': Product(
            id: index + 1,
            name: '浏览商品 ${index + 1}',
            price: 99.0 + index * 10,
            originalPrice: 199.0 + index * 20,
            image: 'https://picsum.photos/300/300?random=${index + 80}',
            sales: 50 + index * 10,
            rating: 4.5,
            description: '优质商品',
            categoryId: index % 8 + 1,
            stock: 100,
          ),
          'time': now.subtract(Duration(hours: index * 2)),
        };
      }),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
        if (_selected.isEmpty) _selecting = false;
      } else {
        _selected.add(index);
      }
    });
  }

  void _enterSelectionMode(int index) {
    setState(() {
      _selecting = true;
      _selected.add(index);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  void _selectAll() {
    setState(() {
      final all = <int>{for (int i = 0; i < _history.length; i++) i};
      if (_selected.length == _history.length) {
        _selected.clear();
      } else {
        _selected.addAll(all);
      }
    });
  }

  void _deleteSelected() {
    final count = _selected.length;
    final indices = _selected.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final i in indices) {
        _history.removeAt(i);
      }
      _selected.clear();
      _selecting = false;
    });
    ToastUtil.show(context, '已删除 $count 条记录');
  }

  void _deleteSingle(int index) {
    setState(() {
      _history.removeAt(index);
    });
    ToastUtil.show(context, '已删除 1 条记录');
  }

  void _showDeleteSingleDialog(int index, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定删除「$productName」的浏览记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSingle(index);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: Text(l10n.confirmClearHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _history.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting ? '已选 ${_selected.length} 项' : l10n.history),
        actions: [
          if (_selecting) ...[
            TextButton(
              onPressed: _selectAll,
              child: Text(_selected.length == _history.length ? '取消全选' : '全选'),
            ),
            TextButton(onPressed: _exitSelectionMode, child: const Text('取消')),
            if (_selected.isNotEmpty)
              IconButton(
                onPressed: _deleteSelected,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
          ] else
            TextButton(
              onPressed: _history.isNotEmpty
                  ? () => _showClearDialog(l10n)
                  : null,
              child: Text(l10n.clear),
            ),
        ],
      ),
      body: _history.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.paddingSmall,
                crossAxisSpacing: AppConstants.paddingSmall,
                childAspectRatio: 0.7,
              ),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(index);
              },
            ),
      bottomNavigationBar: _selecting && _selected.isNotEmpty
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text('删除 ${_selected.length} 项'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            l10n.noHistory,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text(l10n.goShopping),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final item = _history[index];
    final product = item['product'] as Product;
    final time = item['time'] as DateTime;
    final isSelected = _selected.contains(index);

    return GestureDetector(
      onTap: _selecting
          ? () => _toggleSelection(index)
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            ),
      onLongPress: () {
        if (!_selecting) {
          _enterSelectionMode(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusMedium),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatTime(time),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            if (!_selecting)
                              GestureDetector(
                                onTap: () => _showDeleteSingleDialog(
                                  index,
                                  product.name,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
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
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}-${time.day}';
    }
  }
}
