import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/cart_provider.dart';
import '../../data/models/address.dart';
import '../address_select/address_select_page.dart';
import 'checkout_viewmodel.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutViewModel _viewModel;
  final List<Address> _addresses = Address.mockAddresses;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel();
    _viewModel.setSelectedAddress(_addresses.first);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            appBar: AppBar(title: const Text('确认订单')),
            body: Consumer<CartProvider>(
              builder: (context, provider, _) {
                final selectedItems = provider.items
                    .where((item) => item.isSelected)
                    .toList();
                final totalPrice = provider.totalPrice;
                final totalCount = provider.selectedCount;

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          _buildAddressSection(newContext),
                          _buildOrderItemsSection(selectedItems),
                          _buildPaymentSection(newContext),
                          _buildRemarkSection(),
                        ],
                      ),
                    ),
                    _buildBottomBar(totalPrice, totalCount, newContext),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressSection(BuildContext ctx) {
    return GestureDetector(
      onTap: () => _navigateToAddressSelect(ctx),
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Consumer<CheckoutViewModel>(
          builder: (context, vm, _) {
            final address = vm.selectedAddress;
            if (address == null) {
              return _buildEmptyAddressContent();
            }
            return Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
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
                          const SizedBox(width: 8),
                          Text(
                            address.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '默认',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyAddressContent() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            '请选择收货地址',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildOrderItemsSection(List<dynamic> selectedItems) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '商品清单',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...selectedItems.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            child: CachedNetworkImage(
              imageUrl: item.product.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '¥${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Consumer<CheckoutViewModel>(
        builder: (context, vm, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '支付方式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(vm.paymentMethods.length, (index) {
                final method = vm.paymentMethods[index];
                final isSelected = vm.selectedPaymentIndex == index;
                return GestureDetector(
                  onTap: () => vm.setSelectedPaymentIndex(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: index < vm.paymentMethods.length - 1
                            ? const BorderSide(color: AppColors.divider)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method['icon'],
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRemarkSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: const Row(
        children: [
          Text(
            '订单备注',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '请输入备注信息',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double totalPrice, int totalCount, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<CheckoutViewModel>(
          builder: (context, vm, _) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '共$totalCount件商品',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text(
                            '合计: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '¥${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: vm.isSubmitting ? null : () => _submitOrder(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: vm.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('提交订单'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToAddressSelect(BuildContext ctx) async {
    final vm = ctx.read<CheckoutViewModel>();
    final result = await Navigator.push<Address>(
      ctx,
      MaterialPageRoute(
        builder: (_) => AddressSelectPage(selectedAddress: vm.selectedAddress),
      ),
    );
    if (result != null) {
      vm.setSelectedAddress(result);
    }
  }

  void _submitOrder(BuildContext ctx) async {
    final vm = ctx.read<CheckoutViewModel>();
    if (vm.selectedAddress == null) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('请选择收货地址')));
      return;
    }

    vm.setIsSubmitting(true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ctx.read<CartProvider>().clearCart();

      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('订单提交成功！')));

      Navigator.of(ctx).popUntil((route) => route.isFirst);
    }
  }
}
