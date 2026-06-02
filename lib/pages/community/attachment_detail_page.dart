import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_util.dart';
import '../../data/services/attachment_store.dart';
import '../../widgets/community/file_section.dart';
import 'document_preview_page.dart';

class AttachmentDetailPage extends StatelessWidget {
  final FileAttachment attachment;

  const AttachmentDetailPage({super.key, required this.attachment});

  IconData _icon() {
    switch (attachment.type) {
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

  Color _color() {
    switch (attachment.type) {
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

  String _typeLabel() {
    switch (attachment.type) {
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
    if (bytes == null) return '未知大小';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get _isUrl =>
      attachment.path.startsWith('http://') ||
      attachment.path.startsWith('https://');

  bool get _canPreview =>
      _isUrl &&
      (attachment.type == AttachmentType.pdf ||
          attachment.type == AttachmentType.word ||
          attachment.type == AttachmentType.excel ||
          attachment.type == AttachmentType.ppt);

  void _viewContent(BuildContext context) {
    if (_canPreview) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DocumentPreviewPage(url: attachment.path, title: attachment.name),
        ),
      );
      return;
    }
    if (_isUrl) {
      _showDownloadDialog(context);
    } else {
      _showUnsupportedDialog(context);
    }
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('此文件类型不支持在线预览，请下载后使用本地应用打开。'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: attachment.path));
              Navigator.pop(ctx);
              ToastUtil.show(context, '下载地址已复制到剪贴板');
            },
            child: const Text('复制下载地址'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showUnsupportedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('此文件不支持直接预览，请在手机上查看。'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: attachment.path));
              Navigator.pop(ctx);
              ToastUtil.show(context, '文件路径已复制到剪贴板');
            },
            child: const Text('复制路径'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '附件详情',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(_icon(), color: color, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          attachment.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _typeLabel(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (attachment.sizeBytes != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatSize(attachment.sizeBytes),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (_canPreview) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _viewContent(context),
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text('在线预览'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '文件信息',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _infoRow('文件名', attachment.name),
                        _infoRow('文件类型', _typeLabel()),
                        _infoRow('文件大小', _formatSize(attachment.sizeBytes)),
                        _infoRow('存储路径', attachment.path),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AttachmentStore().add(attachment);
                      ToastUtil.show(context, '已收藏到我的附件');
                    },
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    label: const Text('收藏到我的附件'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewContent(context),
                    icon: Icon(
                      _canPreview ? Icons.visibility : Icons.download,
                      size: 18,
                    ),
                    label: Text(_canPreview ? '预览' : '查看文件'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
