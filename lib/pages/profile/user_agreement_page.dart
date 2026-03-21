import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.userAgreement)),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          _buildSection('一、服务条款', '''
欢迎使用 HLAppleAi！本用户协议（以下简称"本协议"）是您与 HLAppleAi 之间的法律协议。在使用我们的服务之前，请仔细阅读本协议。

通过访问或使用我们的服务，即表示您同意受本协议的约束。如果您不同意本协议的任何部分，请勿使用我们的服务。
          '''),
          _buildSection('二、服务描述', '''
HLAppleAi 提供以下服务：
• 商品浏览和搜索
• 在线购物和支付
• 订单管理
• 社区分享
• 个性化推荐

我们保留随时修改、暂停或终止任何服务的权利。
          '''),
          _buildSection('三、用户账户', '''
您需要创建一个账户才能使用某些功能。 您同意：
• 提供准确、完整的注册信息
• 维护账户安全，对账户活动负责
• 及时更新账户信息
• 不与他人共享账户
          '''),
          _buildSection('四、交易规则', '''
• 商品价格以页面显示为准
• 订单确认后，价格不可更改
• 我们保留取消异常订单的权利
• 用户需遵守购买数量限制
          '''),
          _buildSection('五、用户行为', '''
您同意不会：
• 违反任何法律法规
• 侵犯他人知识产权
• 发布虚假或误导性信息
• 进行任何非法活动
• 干扰服务正常运行
          '''),
          _buildSection('六、知识产权', '''
HLAppleAi 的所有内容、功能和软件均为我们的知识产权。未经授权，禁止复制、分发或使用。
          '''),
          _buildSection('七、免责声明', '''
服务按"现状"提供，我们不对服务的准确性、完整性或可靠性做出任何明示或暗示的保证。
          '''),
          _buildSection('八、责任限制', '''
对于任何间接、偶然、特殊或后果性损害，我们不承担责任。
          '''),
          _buildSection('九、争议解决', '''
本协议受中华人民共和国法律管辖。因本协议引起的争议，应提交深圳市人民法院管辖。
          '''),
          const SizedBox(height: 20),
          Text(
            '更新日期：2024年1月1日',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
