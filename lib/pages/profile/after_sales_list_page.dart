import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AfterSalesListPage extends StatefulWidget {
  const AfterSalesListPage({super.key});

  @override
  State<AfterSalesListPage> createState() => _AfterSalesListPageState();
}

class _AfterSalesListPageState extends State<AfterSalesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['全部', '处理中', '已完成', '已拒绝'];

  final List<_AfterSalesOrder> _mockOrders = [
    _AfterSalesOrder(
      id: '1',
      orderNo: 'HL20240115001',
      type: '仅退款',
      status: 'processing',
      amount: 99.00,
      reason: '商品破损',
      createTime: '2024-01-15 10:30',
      statusDesc: '商家正在处理中',
    ),
    _AfterSalesOrder(
      id: '2',
      orderNo: 'HL20240110002',
      type: '退款退货',
      status: 'completed',
      amount: 199.00,
      reason: '商品与描述不符',
      createTime: '2024-01-10 14:20',
      statusDesc: '退款成功，已到账',
    ),
    _AfterSalesOrder(
      id: '3',
      orderNo: 'HL20240105003',
      type: '换货',
      status: 'rejected',
      amount: 0,
      reason: '商品损坏',
      createTime: '2024-01-05 09:15',
      statusDesc: '申请被拒绝，原因：不符合换货条件',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
        title: const Text('退款/售后'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildList(tab)).toList(),
      ),
    );
  }

  Widget _buildList(String filter) {
    List<_AfterSalesOrder> orders;
    switch (filter) {
      case '处理中':
        orders = _mockOrders.where((o) => o.status == 'processing').toList();
        break;
      case '已完成':
        orders = _mockOrders.where((o) => o.status == 'completed').toList();
        break;
      case '已拒绝':
        orders = _mockOrders.where((o) => o.status == 'rejected').toList();
        break;
      default:
        orders = _mockOrders;
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            '暂无售后记录',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(_AfterSalesOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '订单号: ${order.orderNo}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (order.amount > 0)
                      Text(
                        '¥${order.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '原因: ${order.reason}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '申请时间: ${order.createTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewDetail(order),
                  child: const Text('查看详情'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'processing':
        color = AppColors.warning;
        text = '处理中';
        break;
      case 'completed':
        color = AppColors.success;
        text = '已完成';
        break;
      case 'rejected':
        color = AppColors.error;
        text = '已拒绝';
        break;
      default:
        color = AppColors.textSecondary;
        text = '未知';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  void _viewDetail(_AfterSalesOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AfterSalesDetailPage(order: order),
      ),
    );
  }
}

class _AfterSalesOrder {
  final String id;
  final String orderNo;
  final String type;
  final String status;
  final double amount;
  final String reason;
  final String createTime;
  final String statusDesc;

  const _AfterSalesOrder({
    required this.id,
    required this.orderNo,
    required this.type,
    required this.status,
    required this.amount,
    required this.reason,
    required this.createTime,
    required this.statusDesc,
  });
}

class AfterSalesDetailPage extends StatelessWidget {
  final _AfterSalesOrder order;

  const AfterSalesDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('售后详情')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          _buildStatusSection(),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildOrderInfoSection(),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildReasonSection(),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildProgressSection(),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getStatusGradient(order.status),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(order.status), color: AppColors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(order.status),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.statusDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getStatusGradient(String status) {
    switch (status) {
      case 'processing':
        return [AppColors.warning, const Color(0xFFFFB74D)];
      case 'completed':
        return [AppColors.success, const Color(0xFF81C784)];
      case 'rejected':
        return [AppColors.error, const Color(0xFFE57373)];
      default:
        return [AppColors.primary, AppColors.secondary];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'processing':
        return Icons.hourglass_top;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'processing':
        return '处理中';
      case 'completed':
        return '已完成';
      case 'rejected':
        return '已拒绝';
      default:
        return '未知状态';
    }
  }

  Widget _buildOrderInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '售后信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('售后类型', order.type),
          _buildInfoRow('订单编号', order.orderNo),
          _buildInfoRow('申请时间', order.createTime),
          if (order.amount > 0)
            _buildInfoRow('退款金额', '¥${order.amount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '退款原因',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.reason,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final steps = _getProgressSteps();
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '处理进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            return _buildProgressItem(step, isLast);
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getProgressSteps() {
    final steps = [
      {
        'title': '提交申请',
        'time': order.createTime,
        'desc': '您提交了${order.type}申请',
      },
    ];

    switch (order.status) {
      case 'processing':
        steps.add({'title': '商家处理', 'time': '处理中', 'desc': '商家正在处理您的申请'});
        break;
      case 'completed':
        steps.add({'title': '商家处理', 'time': '已同意', 'desc': '商家已同意您的申请'});
        steps.add({'title': '退款完成', 'time': '已到账', 'desc': '退款已到账，请注意查收'});
        break;
      case 'rejected':
        steps.add({'title': '商家处理', 'time': '已拒绝', 'desc': '商家拒绝了您的申请'});
        break;
    }

    return steps;
  }

  Widget _buildProgressItem(Map<String, dynamic> step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isLast ? AppColors.primary : AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: AppColors.success),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['desc'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step['time'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: SafeArea(
        child: Row(
          children: [
            if (order.status == 'processing')
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _cancelApply(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('撤销申请'),
                ),
              ),
            if (order.status == 'processing') const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('返回'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelApply(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤销申请'),
        content: const Text('确定要撤销该售后申请吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('申请已撤销')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
