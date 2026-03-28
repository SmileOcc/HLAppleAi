import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../core/constants/app_constants.dart';
import 'rich_text_editor_toolbar.dart';

class RichTextEditor extends StatefulWidget {
  final QuillController? controller;
  final String? initialContent;
  final int? maxLength;
  final String hintText;
  final double minHeight;
  final double maxHeight;
  final Function(String)? onContentChanged;
  final bool showToolbar;

  const RichTextEditor({
    super.key,
    this.controller,
    this.initialContent,
    this.maxLength,
    this.hintText = '说点什么...',
    this.minHeight = 150,
    this.maxHeight = 300,
    this.onContentChanged,
    this.showToolbar = true,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isInternalController = true;
      _controller = QuillController.basic();

      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        _loadInitialContent();
      }
    }

    _controller.addListener(_onContentChanged);
  }

  void _loadInitialContent() {
    try {
      final doc = Document.fromJson(_parseJson(widget.initialContent!));
      _controller.document = doc;
      _controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
    } catch (e) {
      final doc = Document()..insert(0, widget.initialContent!);
      _controller.document = doc;
      _controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
    }
  }

  List<dynamic> _parseJson(String jsonStr) {
    try {
      if (jsonStr.startsWith('[')) {
        return List<dynamic>.from(jsonStr.split(',').map((e) => e.trim()));
      }
      return [
        {'insert': '$jsonStr\n'},
      ];
    } catch (e) {
      return [
        {'insert': '$jsonStr\n'},
      ];
    }
  }

  void _onContentChanged() {
    final plainText = _controller.document.toPlainText();
    if (widget.onContentChanged != null) {
      widget.onContentChanged!(plainText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onContentChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String getPlainText() {
    return _controller.document.toPlainText();
  }

  String getDeltaJson() {
    return _controller.document.toDelta().toJson().toString();
  }

  Document getDocument() {
    return _controller.document;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showToolbar)
            RichTextEditorToolbar(controller: _controller),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                minHeight: widget.minHeight,
                maxHeight: widget.maxHeight,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: QuillEditor.basic(
                  controller: _controller,
                  focusNode: _focusNode,
                  config: QuillEditorConfig(
                    placeholder: widget.hintText,
                    padding: const EdgeInsets.all(12),
                    scrollable: false,
                    autoFocus: false,
                    expands: false,
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        HorizontalSpacing.zero,
                        const VerticalSpacing(8, 8),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                      placeHolder: DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        HorizontalSpacing.zero,
                        const VerticalSpacing(8, 8),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.maxLength != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              alignment: Alignment.centerRight,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  final length = _controller.document.toPlainText().length;
                  final isOverLimit = length > widget.maxLength!;
                  return Text(
                    '$length/${widget.maxLength}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverLimit ? Colors.red : AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
