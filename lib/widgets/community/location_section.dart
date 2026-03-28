import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class LocationSection extends StatelessWidget {
  final String? selectedLocation;
  final ValueChanged<String?> onLocationChanged;

  const LocationSection({
    super.key,
    this.selectedLocation,
    required this.onLocationChanged,
  });

  static const List<Map<String, dynamic>> locations = [
    {'id': '1', 'name': '北京市', 'district': '朝阳区'},
    {'id': '2', 'name': '上海市', 'district': '浦东新区'},
    {'id': '3', 'name': '广州市', 'district': '天河区'},
    {'id': '4', 'name': '深圳市', 'district': '南山区'},
    {'id': '5', 'name': '杭州市', 'district': '西湖区'},
    {'id': '6', 'name': '成都市', 'district': '锦江区'},
    {'id': '7', 'name': '南京市', 'district': '鼓楼区'},
    {'id': '8', 'name': '武汉市', 'district': '江汉区'},
  ];

  void showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择位置',
                    style: TextStyle(
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
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final fullLocation =
                      '${location['name']} ${location['district']}';
                  final isSelected = selectedLocation == fullLocation;
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      location['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      location['district'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      onLocationChanged(fullLocation);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showLocationPicker(context),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: selectedLocation != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedLocation ?? '显示位置',
                style: TextStyle(
                  fontSize: 15,
                  color: selectedLocation != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (selectedLocation != null)
              GestureDetector(
                onTap: () => onLocationChanged(null),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
