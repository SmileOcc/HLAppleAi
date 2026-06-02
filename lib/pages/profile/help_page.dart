import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqs = [
    {'q': '如何下单购买商品？', 'a': '浏览商品页面，选择心仪商品加入购物车或直接购买，填写收货地址后提交订单并完成支付即可。'},
    {'q': '如何查看订单状态？', 'a': '进入"我的订单"页面，可以查看所有订单的状态，包括待付款、待发货、运输中、已完成等。'},
    {'q': '如何申请退款/退货？', 'a': '在订单详情页面点击"申请售后"，选择退款或退货类型，填写原因并提交，等待商家处理。'},
    {
      'q': '如何联系客服？',
      'a': '在"我的"页面点击"联系客服"，或拨打客服热线 400-888-8888（工作日 9:00-18:00）。',
    },
    {'q': '如何修改收货地址？', 'a': '进入"地址管理"页面，可以添加新地址或编辑已有地址，设置默认地址后下单将自动填充。'},
    {'q': '如何参与平台活动？', 'a': '进入"活动中心"页面，可以查看当前进行中的所有活动，点击参与即可享受优惠。'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用帮助')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          const Text(
            '常见问题',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (i) => _buildFaqItem(i)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          SizedBox(width: 8),
          Text(
            '搜索问题',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final faq = _faqs[index];
    final isExpanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              faq['q']!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textSecondary,
            ),
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? -1 : index),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                faq['a']!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
