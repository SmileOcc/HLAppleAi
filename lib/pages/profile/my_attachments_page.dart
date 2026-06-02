import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_util.dart';
import '../../data/services/attachment_store.dart';
import '../../widgets/community/file_section.dart';
import '../community/attachment_detail_page.dart';

class MyAttachmentsPage extends StatefulWidget {
  const MyAttachmentsPage({super.key});

  @override
  State<MyAttachmentsPage> createState() => _MyAttachmentsPageState();
}

class _MyAttachmentsPageState extends State<MyAttachmentsPage> {
  final _store = AttachmentStore();
  final Set<FileAttachment> _selected = {};

  IconData _icon(AttachmentType type) {
    switch (type) {
      case AttachmentType.word:
        return Icons.description;
      case AttachmentType.pdf:
        return Icons.picture_as_pdf;
      case AttachmentType.excel:
        return Icons.table_chart;
      case AttachmentType.video:
        return Icons.videocam;
      case AttachmentType.ppt:
        return Icons.slideshow;
      case AttachmentType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _color(AttachmentType type) {
    switch (type) {
      case AttachmentType.word:
        return const Color(0xFF2B579A);
      case AttachmentType.pdf:
        return const Color(0xFFE74C3C);
      case AttachmentType.excel:
        return const Color(0xFF27AE60);
      case AttachmentType.video:
        return const Color(0xFFE17055);
      case AttachmentType.ppt:
        return const Color(0xFFD24726);
      case AttachmentType.other:
        return AppColors.textSecondary;
    }
  }

  String _typeLabel(AttachmentType type) {
    switch (type) {
      case AttachmentType.word:
        return 'Word 文档';
      case AttachmentType.pdf:
        return 'PDF 文档';
      case AttachmentType.excel:
        return 'Excel 表格';
      case AttachmentType.video:
        return '视频文件';
      case AttachmentType.ppt:
        return 'PPT 演示';
      case AttachmentType.other:
        return '其他文件';
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get _selecting => _selected.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final attachments = _store.attachments;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selecting ? '已选 ${_selected.length} 项' : '我的附件',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          if (_selecting)
            TextButton(
              onPressed: () {
                setState(() {
                  _store.removeWhere((a) => _selected.contains(a));
                  _selected.clear();
                });
                ToastUtil.show(context, '已删除 ${_selected.length} 项');
              },
              child: const Text(
                '删除',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
          if (_selecting)
            TextButton(
              onPressed: () {
                ToastUtil.show(context, '已下载 ${_selected.length} 个文件（模拟）');
              },
              child: const Text(
                '下载',
                style: TextStyle(color: AppColors.primary, fontSize: 15),
              ),
            ),
        ],
      ),
      body: attachments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无附件',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '去帖子详情收藏附件',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final file = attachments[index];
                final isSelected = _selected.contains(file);
                return _buildFileItem(file, isSelected);
              },
            ),
    );
  }

  Widget _buildFileItem(FileAttachment file, bool isSelected) {
    final color = _color(file.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttachmentDetailPage(attachment: file),
            ),
          );
        },
        onLongPress: () {
          setState(() {
            if (isSelected) {
              _selected.remove(file);
            } else {
              _selected.add(file);
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon(file.type), color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _typeLabel(file.type),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (file.sizeBytes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatSize(file.sizeBytes),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
