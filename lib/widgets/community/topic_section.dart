import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/toast_util.dart';

class TopicSection extends StatelessWidget {
  final List<String> selectedTopics;
  final int maxTopics;
  final ValueChanged<List<String>> onTopicsChanged;

  const TopicSection({
    super.key,
    required this.selectedTopics,
    this.maxTopics = 5,
    required this.onTopicsChanged,
  });

  static const List<Map<String, dynamic>> availableTopics = [
    {'id': '1', 'name': '#好物分享#', 'count': '2.3万'},
    {'id': '2', 'name': '#今日穿搭#', 'count': '1.8万'},
    {'id': '3', 'name': '#开箱测评#', 'count': '1.5万'},
    {'id': '4', 'name': '#省钱攻略#', 'count': '1.2万'},
    {'id': '5', 'name': '#购物心得#', 'count': '9800'},
    {'id': '6', 'name': '#新品上市#', 'count': '8600'},
    {'id': '7', 'name': '#限时优惠#', 'count': '7200'},
    {'id': '8', 'name': '#种草推荐#', 'count': '6500'},
  ];

  void showTopicPicker(BuildContext context) {
    final tempSelectedTopics = List<String>.from(selectedTopics);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '选择话题 (${tempSelectedTopics.length}/$maxTopics)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableTopics.length,
                    itemBuilder: (context, index) {
                      final topic = availableTopics[index];
                      final isSelected = tempSelectedTopics.contains(
                        topic['name'] as String,
                      );
                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          topic['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          '${topic['count']} 参与',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              tempSelectedTopics.remove(topic['name']);
                            } else {
                              if (tempSelectedTopics.length < maxTopics) {
                                tempSelectedTopics.add(topic['name'] as String);
                              } else {
                                ToastUtil.show(
                                  context,
                                  '最多只能选择 $maxTopics 个话题',
                                );
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
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
                    child: ElevatedButton(
                      onPressed: () {
                        onTopicsChanged(tempSelectedTopics);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showTopicPicker(context),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tag, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  selectedTopics.isEmpty ? '添加话题' : '已选话题',
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedTopics.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (selectedTopics.isNotEmpty)
                  GestureDetector(
                    onTap: () => onTopicsChanged([]),
                    child: const Text(
                      '清除',
                      style: TextStyle(fontSize: 14, color: AppColors.primary),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            if (selectedTopics.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedTopics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            final newTopics = List<String>.from(selectedTopics)
                              ..remove(topic);
                            onTopicsChanged(newTopics);
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
