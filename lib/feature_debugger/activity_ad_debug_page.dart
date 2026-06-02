import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/toast_util.dart';
import '../widgets/activity_ad_dialog.dart';
import 'debug_settings.dart';

class ActivityAdDebugPage extends StatefulWidget {
  const ActivityAdDebugPage({super.key});

  @override
  State<ActivityAdDebugPage> createState() => _ActivityAdDebugPageState();
}

class _ActivityAdDebugPageState extends State<ActivityAdDebugPage> {
  bool _startupEnabled = false;
  AdSource _adSource = AdSource.api;
  int _delaySeconds = 2;
  String _imageUrl = '';
  String _title = '';
  String _content = '';
  late TextEditingController _delayController;
  late TextEditingController _imageController;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _delayController = TextEditingController();
    _imageController = TextEditingController();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _delayController.dispose();
    _imageController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ds = await DebugSettings.getInstance();
    setState(() {
      _startupEnabled = ds.adStartupEnabled;
      _adSource = ds.adSource;
      _delaySeconds = ds.adDelaySeconds;
      _imageUrl = ds.adImageUrl;
      _title = ds.adTitle;
      _content = ds.adContent;
      _delayController.text = _delaySeconds.toString();
      _imageController.text = _imageUrl;
      _titleController.text = _title;
      _contentController.text = _content;
    });
  }

  void _showAd() {
    ActivityAdDialog.show(
      context,
      config: ActivityAdConfig(
        title: _title.isNotEmpty ? _title : '限时特惠活动',
        description: _content.isNotEmpty ? _content : '全场商品低至5折！',
        imageUrl: _imageUrl.isNotEmpty
            ? _imageUrl
            : 'https://picsum.photos/600/300?random=999',
        actionText: '立即查看',
        onAction: () {
          ToastUtil.show(context, '广告点击回调');
        },
      ),
    );
  }

  Future<void> _autoSave() async {
    final ds = await DebugSettings.getInstance();
    await ds.setAdStartupEnabled(_startupEnabled);
    await ds.setAdSource(_adSource);
    await ds.setAdDelaySeconds(_delaySeconds);
    await ds.setAdImageUrl(_imageUrl);
    await ds.setAdTitle(_title);
    await ds.setAdContent(_content);
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
          '活动广告调试',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        centerTitle: true,
        actions: [TextButton(onPressed: _save, child: const Text('保存'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('启动 APP 开启活动广告'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SwitchListTile(
              title: const Text('启动 APP 开启活动广告'),
              subtitle: const Text(
                '关闭后 APP 启动时不再弹出活动广告',
                style: TextStyle(fontSize: 12),
              ),
              value: _startupEnabled,
              onChanged: (v) {
                setState(() => _startupEnabled = v);
                _autoSave();
              },
              activeColor: AppColors.primary,
            ),
          ),
          _buildSectionTitle('广告配置来源'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                RadioListTile<AdSource>(
                  title: const Text('使用配置的活动信息'),
                  subtitle: const Text(
                    '手动编辑标题、延迟、图片、文案',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: AdSource.config,
                  groupValue: _adSource,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _adSource = v!);
                    _autoSave();
                  },
                ),
                RadioListTile<AdSource>(
                  title: const Text('读取正式活动接口返回的广告配置'),
                  subtitle: const Text(
                    '使用线上正式活动接口数据',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: AdSource.api,
                  groupValue: _adSource,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _adSource = v!);
                    _autoSave();
                  },
                ),
              ],
            ),
          ),
          if (_adSource == AdSource.config) ...[
            _buildSectionTitle('弹出默认广告'),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAd,
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('立即弹出广告'),
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
            _buildSectionTitle('广告活动标题'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '输入活动标题',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) {
                  _title = v;
                  _autoSave();
                },
              ),
            ),
            _buildSectionTitle('启动延迟（秒）'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _delayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '输入秒数，如 2',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null) {
                    _delaySeconds = parsed;
                    _autoSave();
                  }
                },
              ),
            ),
            _buildSectionTitle('活动图片链接'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  hintText: '输入图片 URL',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) {
                  _imageUrl = v;
                  _autoSave();
                },
              ),
            ),
            _buildSectionTitle('广告活动文案'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '活动详情描述',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) {
                  _content = v;
                  _autoSave();
                },
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
