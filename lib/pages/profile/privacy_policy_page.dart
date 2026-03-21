import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          _buildSection('一、收集信息', '''
我们会收集您在使用服务过程中主动提供的信息，包括：
• 账户信息：手机号、昵称、头像等
• 交易信息：订单信息、收货地址、支付信息
• 设备信息：设备型号、操作系统、屏幕分辨率等
• 位置信息：基于您的位置为您提供附近服务
          '''),
          _buildSection('二、使用信息', '''
我们收集的信息将用于：
• 提供、维护和改进我们的服务
• 处理您的订单和交易
• 向您推送个性化的内容和广告
• 保护您的账户安全
• 与您沟通并提供客户支持
          '''),
          _buildSection('三、信息共享', '''
我们不会向第三方出售您的个人信息。在以下情况下，我们可能会共享您的信息：
• 获得您的明确同意
• 遵守法律法规要求
• 向服务提供商提供必要信息以完成交易
• 保护我们或公众的权利和利益
          '''),
          _buildSection('四、信息安全', '''
我们采用行业标准的安全措施保护您的个人信息，包括：
• 数据加密传输和存储
• 访问控制和身份验证
• 定期安全审计
• 员工隐私培训
          '''),
          _buildSection('五、您的权利', '''
您对您的个人信息享有以下权利：
• 访问和更正您的个人信息
• 删除您的个人信息
• 撤回同意
• 数据导出
• 投诉和举报
          '''),
          _buildSection('六、未成年人隐私', '''
我们非常重视对未成年人隐私的保护。我们不会在明知的情况下收集未满18周岁用户的个人信息。
          '''),
          _buildSection('七、政策更新', '''
我们可能会不时更新本隐私政策。重大变更将通过应用内通知或电子邮件方式告知您。
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
