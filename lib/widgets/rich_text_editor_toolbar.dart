import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../core/constants/app_constants.dart';

class RichTextEditorToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback? onDismiss;

  const RichTextEditorToolbar({
    super.key,
    required this.controller,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Container(
              width: 1,
              height: 24,
              color: AppColors.divider,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            _buildColorPicker(context),
            Container(
              width: 1,
              height: 24,
              color: AppColors.divider,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            _buildToolButton(
              icon: Icons.undo,
              isActive: false,
              onTap: () => controller.undo(),
              tooltip: '撤销',
            ),
            _buildToolButton(
              icon: Icons.redo,
              isActive: false,
              onTap: () => controller.redo(),
              tooltip: '重做',
            ),
          ],
        ),
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

  Widget _buildColorPicker(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '文字颜色',
      offset: const Offset(0, 40),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: const Icon(
          Icons.color_lens,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'red',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('红色'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'orange',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('橙色'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'green',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('绿色'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'blue',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('蓝色'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'purple',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('紫色'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'default',
          child: Row(
            children: [
              Icon(Icons.format_color_reset, size: 20),
              SizedBox(width: 8),
              Text('默认颜色'),
            ],
          ),
        ),
      ],
      onSelected: (color) {
        if (color == 'default') {
          controller.formatSelection(const ColorAttribute(null));
        } else {
          final colorValue = _getColorValue(color);
          final hexColor =
              '#${colorValue.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
          controller.formatSelection(ColorAttribute(hexColor));
        }
      },
    );
  }

  Color _getColorValue(String color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  bool _isFormatActive(Attribute attribute) {
    final style = controller.getSelectionStyle();
    return style.containsKey(attribute.key);
  }

  bool _isBlockActive(Attribute attribute) {
    final style = controller.getSelectionStyle();
    return style.containsKey(attribute.key);
  }

  void _toggleFormat(Attribute attribute) {
    if (_isFormatActive(attribute)) {
      controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }

  void _toggleBlock(Attribute attribute) {
    controller.formatSelection(attribute);
  }
}
