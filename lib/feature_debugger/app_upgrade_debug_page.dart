import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/toast_util.dart';
import '../widgets/app_upgrade_dialog.dart';
import 'debug_settings.dart';

class AppUpgradeDebugPage extends StatefulWidget {
  const AppUpgradeDebugPage({super.key});

  @override
  State<AppUpgradeDebugPage> createState() => _AppUpgradeDebugPageState();
}

class _AppUpgradeDebugPageState extends State<AppUpgradeDebugPage> {
  bool _upgradeEnabled = false;
  String _title = '';
  String _version = '';
  String _description = '';
  String _downloadUrl = '';
  bool _forceUpdate = false;
  late TextEditingController _titleController;
  late TextEditingController _versionController;
  late TextEditingController _descriptionController;
  late TextEditingController _downloadUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _versionController = TextEditingController();
    _descriptionController = TextEditingController();
    _downloadUrlController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    _downloadUrlController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ds = await DebugSettings.getInstance();
    setState(() {
      _upgradeEnabled = ds.upgradeEnabled;
      _title = ds.upgradeTitle;
      _version = ds.upgradeVersion;
      _description = ds.upgradeDescription;
      _downloadUrl = ds.upgradeDownloadUrl;
      _forceUpdate = ds.upgradeForceUpdate;
      _titleController.text = _title;
      _versionController.text = _version;
      _descriptionController.text = _description;
      _downloadUrlController.text = _downloadUrl;
    });
  }

  void _showUpgradeDialog() {
    AppUpgradeDialog.show(
      context,
      config: AppUpgradeConfig(
        title: _title.isNotEmpty ? _title : '发现新版本',
        version: _version.isNotEmpty ? _version : 'v2.0.0',
        description: _description.isNotEmpty
            ? _description
            : '1. 优化用户体验\n2. 修复已知问题\n3. 提升性能表现',
        downloadUrl: _downloadUrl,
        forceUpdate: _forceUpdate,
      ),
      onUpdate: () {
        ToastUtil.show(
          context,
          '升级链接: ${_downloadUrl.isNotEmpty ? _downloadUrl : "未配置"}',
        );
      },
      onCancel: () {
        ToastUtil.show(context, '已取消升级');
      },
    );
  }

  Future<void> _autoSave() async {
    final ds = await DebugSettings.getInstance();
    await ds.setUpgradeEnabled(_upgradeEnabled);
    await ds.setUpgradeTitle(_title);
    await ds.setUpgradeVersion(_version);
    await ds.setUpgradeDescription(_description);
    await ds.setUpgradeDownloadUrl(_downloadUrl);
    await ds.setUpgradeForceUpdate(_forceUpdate);
  }

  Future<void> _save() async {
    await _autoSave();
    if (mounted) ToastUtil.show(context, '调试配置已保存');
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'APP升级弹窗调试',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        centerTitle: true,
        actions: [TextButton(onPressed: _save, child: const Text('保存'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('开启升级弹窗调试'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SwitchListTile(
              title: const Text('开启升级弹窗调试'),
              subtitle: const Text(
                '开启后 APP 启动时弹出升级提示',
                style: TextStyle(fontSize: 12),
              ),
              value: _upgradeEnabled,
              onChanged: (v) {
                setState(() => _upgradeEnabled = v);
                _autoSave();
              },
              activeColor: AppColors.primary,
            ),
          ),
          _buildSectionTitle('预览升级弹窗'),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUpgradeDialog,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('立即显示升级弹窗'),
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
          _buildSectionTitle('弹窗标题'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '如: 发现新版本',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) {
                _title = v;
                _autoSave();
              },
            ),
          ),
          _buildSectionTitle('版本号'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _versionController,
              decoration: const InputDecoration(
                hintText: '如: v2.0.0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) {
                _version = v;
                _autoSave();
              },
            ),
          ),
          _buildSectionTitle('更新内容'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '每行一条更新内容',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) {
                _description = v;
                _autoSave();
              },
            ),
          ),
          _buildSectionTitle('下载链接'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _downloadUrlController,
              decoration: const InputDecoration(
                hintText: '输入 APK / AppStore 链接',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) {
                _downloadUrl = v;
                _autoSave();
              },
            ),
          ),
          _buildSectionTitle('强制升级'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SwitchListTile(
              title: const Text('强制升级'),
              subtitle: const Text(
                '开启后用户必须更新才能使用 APP',
                style: TextStyle(fontSize: 12),
              ),
              value: _forceUpdate,
              onChanged: (v) {
                setState(() => _forceUpdate = v);
                _autoSave();
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
