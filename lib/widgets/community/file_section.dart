import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_constants.dart';

enum AttachmentType { word, pdf, excel, video, ppt, other }

class FileAttachment {
  final String name;
  final String path;
  final AttachmentType type;
  final int? sizeBytes;

  FileAttachment({
    required this.name,
    required this.path,
    required this.type,
    this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'type': type.index,
    'sizeBytes': sizeBytes,
  };

  factory FileAttachment.fromJson(Map<String, dynamic> json) => FileAttachment(
    name: json['name'] as String,
    path: json['path'] as String,
    type: AttachmentType.values[json['type'] as int],
    sizeBytes: json['sizeBytes'] as int?,
  );
}

class FileSection extends StatelessWidget {
  final List<FileAttachment> files;
  final ValueChanged<List<FileAttachment>> onFilesChanged;

  const FileSection({
    super.key,
    required this.files,
    required this.onFilesChanged,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _FilePickerSheet(
        onFilesPicked: (newFiles) {
          onFilesChanged([...files, ...newFiles]);
        },
      ),
    );
  }

  void _removeFile(int index) {
    final newFiles = List<FileAttachment>.from(files)..removeAt(index);
    onFilesChanged(newFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加附件',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (files.isEmpty)
            _buildEmptyAddButton(context)
          else
            Column(
              children: [
                ...files.asMap().entries.map(
                  (e) => _buildFileItem(e.key, e.value),
                ),
                const SizedBox(height: 8),
                _buildAddButton(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Column(
            children: [
              Icon(Icons.attach_file, color: AppColors.textSecondary, size: 36),
              SizedBox(height: 8),
              Text(
                '支持 doc、pdf、xls、mp4 等格式',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPicker(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.textSecondary, size: 18),
              SizedBox(width: 4),
              Text(
                '添加更多附件',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(int index, FileAttachment file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildFileIcon(file.type),
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
                Text(
                  _fileTypeLabel(file.type),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeFile(index),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(AttachmentType type) {
    IconData icon;
    Color color;
    switch (type) {
      case AttachmentType.word:
        icon = Icons.description;
        color = const Color(0xFF2B579A);
      case AttachmentType.pdf:
        icon = Icons.picture_as_pdf;
        color = const Color(0xFFE74C3C);
      case AttachmentType.excel:
        icon = Icons.table_chart;
        color = const Color(0xFF27AE60);
      case AttachmentType.video:
        icon = Icons.videocam;
        color = const Color(0xFFE17055);
      case AttachmentType.ppt:
        icon = Icons.slideshow;
        color = const Color(0xFFD24726);
      case AttachmentType.other:
        icon = Icons.insert_drive_file;
        color = AppColors.textSecondary;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _fileTypeLabel(AttachmentType type) {
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
}

class _FilePickerSheet extends StatefulWidget {
  final ValueChanged<List<FileAttachment>> onFilesPicked;
  const _FilePickerSheet({required this.onFilesPicked});

  @override
  State<_FilePickerSheet> createState() => _FilePickerSheetState();
}

class _FilePickerSheetState extends State<_FilePickerSheet> {
  final _nameController = TextEditingController();
  String? _detectedTypeLabel;
  AttachmentType? _detectedType;
  bool _isPicking = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFromDevice() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'doc',
          'docx',
          'pdf',
          'xls',
          'xlsx',
          'mp4',
          'mov',
          'avi',
          'mkv',
          'ppt',
          'pptx',
        ],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files.map((f) {
          final type = f.extension != null
              ? _inferType(f.extension!)
              : AttachmentType.other;
          return FileAttachment(name: f.name, path: f.path ?? '', type: type);
        }).toList();
        widget.onFilesPicked(newFiles);
        navigator.pop();
      }
    } catch (e) {
      debugPrint('FilePicker error: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('文件选择器不可用，请手动输入文件名')),
      );
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _onNameChanged(String value) {
    final dotIndex = value.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < value.length - 1) {
      final ext = value.substring(dotIndex + 1);
      final type = _inferType(ext);
      setState(() {
        _detectedType = type;
        _detectedTypeLabel = _typeLabel(type);
      });
    } else {
      setState(() {
        _detectedType = null;
        _detectedTypeLabel = null;
      });
    }
  }

  void _confirm() {
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('请输入文件名')));
      return;
    }
    if (!name.contains('.')) {
      messenger.showSnackBar(
        const SnackBar(content: Text('请输入文件扩展名，例如 document.pdf')),
      );
      return;
    }
    final fileType = _detectedType ?? _inferType(name.split('.').last);
    widget.onFilesPicked([
      FileAttachment(name: name, path: name, type: fileType),
    ]);
    Navigator.pop(context);
  }

  AttachmentType _inferType(String ext) {
    switch (ext.toLowerCase()) {
      case 'doc':
      case 'docx':
        return AttachmentType.word;
      case 'pdf':
        return AttachmentType.pdf;
      case 'xls':
      case 'xlsx':
        return AttachmentType.excel;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return AttachmentType.video;
      case 'ppt':
      case 'pptx':
        return AttachmentType.ppt;
      default:
        return AttachmentType.other;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPicking ? null : _pickFromDevice,
                icon: _isPicking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.phone_android_outlined),
                label: Text(_isPicking ? '正在打开文件选择器...' : '从设备选择文件'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '或手动输入',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            TextField(
              controller: _nameController,
              onChanged: _onNameChanged,
              decoration: InputDecoration(
                hintText: '输入文件名，例如 report.pdf',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: _detectedType != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            _detectedTypeLabel!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('确定添加', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
