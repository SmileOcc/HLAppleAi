import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _availableCoupons = [
    {
      'id': 1,
      'name': '新人专享券',
      'amount': 50,
      'minAmount': 200,
      'desc': '全品类可用',
      'validUntil': '2024-12-31',
    },
    {
      'id': 2,
      'name': '数码专享券',
      'amount': 100,
      'minAmount': 500,
      'desc': '仅限数码品类',
      'validUntil': '2024-12-31',
    },
    {
      'id': 3,
      'name': '满减券',
      'amount': 30,
      'minAmount': 150,
      'desc': '全场通用',
      'validUntil': '2024-11-30',
    },
    {
      'id': 4,
      'name': '会员专享券',
      'amount': 80,
      'minAmount': 300,
      'desc': '会员专享',
      'validUntil': '2024-12-31',
    },
  ];

  final List<Map<String, dynamic>> _usedCoupons = [
    {
      'id': 5,
      'name': '中秋特惠券',
      'amount': 20,
      'minAmount': 100,
      'desc': '全品类可用',
      'usedDate': '2024-09-15',
    },
  ];

  final List<Map<String, dynamic>> _expiredCoupons = [
    {
      'id': 6,
      'name': '限时优惠券',
      'amount': 15,
      'minAmount': 80,
      'desc': '全品类可用',
      'expiredDate': '2024-08-01',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('优惠券'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '可用'),
            Tab(text: '已使用'),
            Tab(text: '已过期'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCouponList(_availableCoupons, 'available'),
          _buildCouponList(_usedCoupons, 'used'),
          _buildCouponList(_expiredCoupons, 'expired'),
        ],
      ),
    );
  }

  Widget _buildCouponList(List<Map<String, dynamic>> coupons, String type) {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'available'
                  ? '暂无可用优惠券'
                  : type == 'used'
                  ? '暂无已使用优惠券'
                  : '暂无已过期优惠券',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        return _buildCouponCard(coupons[index], type);
      },
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon, String type) {
    final isAvailable = type == 'available';
    final isExpired = type == 'expired';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isAvailable ? AppColors.primary : AppColors.divider,
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.primary
                  : isExpired
                  ? AppColors.textSecondary
                  : AppColors.divider,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppConstants.radiusMedium - 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¥',
                      style: TextStyle(
                        fontSize: 14,
                        color: isAvailable
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      coupon['amount'].toString(),
                      style: TextStyle(
                        fontSize: 32,
                        color: isAvailable
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '满${coupon['minAmount']}可用',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAvailable
                        ? AppColors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isExpired
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon['desc'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable
                        ? '有效期至 ${coupon['validUntil']}'
                        : isExpired
                        ? '已过期 ${coupon['expiredDate']}'
                        : '已使用于 ${coupon['usedDate']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAvailable
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAvailable)
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.paddingMedium),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('使用'),
              ),
            ),
        ],
      ),
    );
  }
}
