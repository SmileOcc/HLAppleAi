import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/address.dart';
import 'address_select_viewmodel.dart';

class AddressSelectPage extends StatefulWidget {
  final Address? selectedAddress;

  const AddressSelectPage({super.key, this.selectedAddress});

  @override
  State<AddressSelectPage> createState() => _AddressSelectPageState();
}

class _AddressSelectPageState extends State<AddressSelectPage> {
  late final AddressSelectViewModel _viewModel;
  late List<Address> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = Address.mockAddresses;
    _viewModel = AddressSelectViewModel();
    _viewModel.init(_addresses, widget.selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('选择收货地址'),
              actions: [
                TextButton(
                  onPressed: () => _showAddAddressDialog(newContext),
                  child: const Text('添加'),
                ),
              ],
            ),
            body: Consumer<AddressSelectViewModel>(
              builder: (context, vm, _) {
                if (vm.addresses.isEmpty) {
                  return _buildEmptyState(newContext);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: vm.addresses.length,
                  itemBuilder: (context, index) {
                    return _buildAddressCard(
                      vm.addresses[index],
                      vm,
                      newContext,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无收货地址',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddAddressDialog(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('添加地址'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    Address address,
    AddressSelectViewModel vm,
    BuildContext ctx,
  ) {
    final isSelected = vm.selectedAddress?.id == address.id;
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _selectAddress(address, ctx),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  address.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  address.phone,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${address.province} ${address.city} ${address.district}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              address.detail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '默认',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: AppConstants.paddingSmall,
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => _showEditAddressDialog(address, ctx),
                  child: const Text('编辑'),
                ),
                TextButton(
                  onPressed: () => _deleteAddress(address.id, ctx),
                  child: const Text(
                    '删除',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
                const Spacer(),
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => vm.setDefaultAddress(address.id),
                    child: const Text('设为默认'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectAddress(Address address, BuildContext ctx) {
    final vm = ctx.read<AddressSelectViewModel>();
    vm.setSelectedAddress(address);
    Navigator.pop(ctx, address);
  }

  void _showAddAddressDialog(BuildContext ctx) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final detailController = TextEditingController();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加收货地址',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '收货人',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    labelText: '详细地址',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final vm = context.read<AddressSelectViewModel>();
                      final newAddress = Address(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: nameController.text,
                        phone: phoneController.text,
                        province: '广东省',
                        city: '深圳市',
                        district: '南山区',
                        detail: detailController.text,
                        isDefault: vm.addresses.isEmpty,
                      );
                      vm.addAddress(newAddress);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('地址添加成功')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditAddressDialog(Address address, BuildContext ctx) {
    final nameController = TextEditingController(text: address.name);
    final phoneController = TextEditingController(text: address.phone);
    final detailController = TextEditingController(text: address.detail);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '编辑收货地址',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '收货人',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    labelText: '详细地址',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final vm = context.read<AddressSelectViewModel>();
                      final updatedAddress = address.copyWith(
                        name: nameController.text,
                        phone: phoneController.text,
                        detail: detailController.text,
                      );
                      vm.updateAddress(updatedAddress);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('地址更新成功')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteAddress(int id, BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除地址'),
        content: const Text('确定要删除该地址吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final vm = ctx.read<AddressSelectViewModel>();
              vm.deleteAddress(id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(const SnackBar(content: Text('地址已删除')));
            },
            child: const Text('确定', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
