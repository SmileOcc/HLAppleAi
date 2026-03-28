import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/mock_rich_text_service.dart';

class RichTextEditorTestPage extends StatefulWidget {
  const RichTextEditorTestPage({super.key});

  @override
  State<RichTextEditorTestPage> createState() => _RichTextEditorTestPageState();
}

class _RichTextEditorTestPageState extends State<RichTextEditorTestPage> {
  final GlobalKey<_RichTextEditorDemoState> _editorKey = GlobalKey();
  final MockRichTextService _service = MockRichTextService();

  bool _isLoading = false;
  List<RichTextPost> _posts = [];
  String? _selectedPostId;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _service.getPosts();
      setState(() {
        _posts = posts;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPost() async {
    final editorState = _editorKey.currentState;
    if (editorState == null) return;

    final content = editorState.getPlainText();
    final deltaJson = editorState.getDeltaJson();

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入内容')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.createPost(
        content: content,
        deltaJson: deltaJson,
        category: 'share',
        topics: ['#测试话题#'],
      );
      await _loadPosts();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('发布成功')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPostForEdit(String postId) async {
    final post = await _service.getPostById(postId);
    if (post == null) return;

    setState(() => _selectedPostId = postId);

    final editorState = _editorKey.currentState;
    if (editorState != null) {
      editorState.loadContent(post.deltaJson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('富文本编辑器测试'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPosts),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '编辑器演示',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichTextEditorDemo(key: _editorKey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '发布帖子',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            final editorState = _editorKey.currentState;
                            if (editorState != null) {
                              final deltaJson = editorState.getDeltaJson();
                              _showDeltaJsonDialog(deltaJson);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          child: const Text('查看 Delta JSON'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Mock 接口返回数据',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _posts.isEmpty
                        ? const Center(child: Text('暂无数据，点击刷新按钮加载'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return _PostCard(
                                post: post,
                                onTap: () => _loadPostForEdit(post.id),
                                isSelected: post.id == _selectedPostId,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeltaJsonDialog(String deltaJson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delta JSON'),
        content: SingleChildScrollView(
          child: SelectableText(
            deltaJson,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('JSON 已复制到剪贴板')));
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }
}

class RichTextEditorDemo extends StatefulWidget {
  const RichTextEditorDemo({super.key});

  @override
  State<RichTextEditorDemo> createState() => _RichTextEditorDemoState();
}

class _RichTextEditorDemoState extends State<RichTextEditorDemo> {
  late QuillController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void loadContent(String deltaJson) {
    try {
      final jsonList = jsonDecode(deltaJson) as List;
      final doc = Document.fromJson(jsonList);
      _controller.document = doc;
    } catch (e) {
      final doc = Document()..insert(0, deltaJson);
      _controller.document = doc;
    }
  }

  String getPlainText() {
    return _controller.document.toPlainText();
  }

  String getDeltaJson() {
    return jsonEncode(_controller.document.toDelta().toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolButton(
                    icon: Icons.format_bold,
                    isActive: _isFormatActive(Attribute.bold),
                    onTap: () => _toggleFormat(Attribute.bold),
                    tooltip: '加粗',
                  ),
                  _buildToolButton(
                    icon: Icons.format_italic,
                    isActive: _isFormatActive(Attribute.italic),
                    onTap: () => _toggleFormat(Attribute.italic),
                    tooltip: '斜体',
                  ),
                  _buildToolButton(
                    icon: Icons.format_underline,
                    isActive: _isFormatActive(Attribute.underline),
                    onTap: () => _toggleFormat(Attribute.underline),
                    tooltip: '下划线',
                  ),
                  _buildToolButton(
                    icon: Icons.format_strikethrough,
                    isActive: _isFormatActive(Attribute.strikeThrough),
                    onTap: () => _toggleFormat(Attribute.strikeThrough),
                    tooltip: '删除线',
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  _buildToolButton(
                    icon: Icons.format_list_bulleted,
                    isActive: _isBlockActive(Attribute.ul),
                    onTap: () => _toggleBlock(Attribute.ul),
                    tooltip: '无序列表',
                  ),
                  _buildToolButton(
                    icon: Icons.format_list_numbered,
                    isActive: _isBlockActive(Attribute.ol),
                    onTap: () => _toggleBlock(Attribute.ol),
                    tooltip: '有序列表',
                  ),
                  _buildToolButton(
                    icon: Icons.format_quote,
                    isActive: _isBlockActive(Attribute.blockQuote),
                    onTap: () => _toggleBlock(Attribute.blockQuote),
                    tooltip: '引用',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _focusNode,
                config: const QuillEditorConfig(
                  placeholder: '说点什么...',
                  padding: EdgeInsets.zero,
                  scrollable: true,
                  autoFocus: false,
                  expands: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  bool _isFormatActive(Attribute attribute) {
    final style = _controller.getSelectionStyle();
    return style.containsKey(attribute.key);
  }

  bool _isBlockActive(Attribute attribute) {
    final style = _controller.getSelectionStyle();
    return style.containsKey(attribute.key);
  }

  void _toggleFormat(Attribute attribute) {
    if (_isFormatActive(attribute)) {
      _controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      _controller.formatSelection(attribute);
    }
  }

  void _toggleBlock(Attribute attribute) {
    _controller.formatSelection(attribute);
  }
}

class _PostCard extends StatelessWidget {
  final RichTextPost post;
  final VoidCallback onTap;
  final bool isSelected;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.category ?? '未知',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              if (post.topics.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: post.topics.take(2).map((topic) {
                    return Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'ID: ${post.id}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
