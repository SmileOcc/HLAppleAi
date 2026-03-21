import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import 'privacy_policy_page.dart';
import 'user_agreement_page.dart';
import 'account_security_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  bool _isLocationEnabled = true;
  double _cacheSize = 23.5;

  @override
  Widget build(BuildContext context) {
    // 监听语言切换
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.read<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.generalSettings),
          _buildSwitchItem(
            icon: Icons.dark_mode_outlined,
            title: l10n.darkMode,
            subtitle: '',
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
          _buildSwitchItem(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: '',
            value: _isNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _isNotificationEnabled = value;
              });
            },
          ),
          _buildSwitchItem(
            icon: Icons.location_on_outlined,
            title: l10n.locationServices,
            subtitle: '',
            value: _isLocationEnabled,
            onChanged: (value) {
              setState(() {
                _isLocationEnabled = value;
              });
            },
          ),
          _buildSectionHeader(l10n.privacySettings),
          _buildNavigationItem(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          _buildNavigationItem(
            icon: Icons.description_outlined,
            title: l10n.userAgreement,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserAgreementPage()),
            ),
          ),
          _buildNavigationItem(
            icon: Icons.security_outlined,
            title: l10n.accountSecurity,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSecurityPage()),
            ),
          ),
          _buildSectionHeader(''),
          _buildNavigationItem(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: localeProvider.currentLanguageName,
            onTap: () => _showLanguageDialog(localeProvider, l10n),
          ),
          _buildNavigationItem(
            icon: Icons.storage_outlined,
            title: l10n.clearCache,
            subtitle: l10n.cachedSize(_cacheSize),
            onTap: () => _showClearCacheDialog(l10n),
          ),
          _buildNavigationItem(
            icon: Icons.check_circle_outline,
            title: l10n.checkUpdate,
            subtitle: '${l10n.currentVersion} 1.0.0',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.latestVersion)));
            },
          ),
          _buildSectionHeader(''),
          _buildLogoutButton(l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(l10n.logout),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    LocaleProvider localeProvider,
    AppLocalizations l10n,
  ) {
    final languages = [
      {'name': '简体中文', 'locale': const Locale('zh', 'CN')},
      {'name': 'English', 'locale': const Locale('en', 'US')},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.language,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(languages.length, (index) {
                final isSelected =
                    localeProvider.locale.languageCode ==
                    (languages[index]['locale'] as Locale).languageCode;
                return ListTile(
                  title: Text(
                    languages[index]['name'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    localeProvider.setLocale(
                      languages[index]['locale'] as Locale,
                    );
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.confirmClearCache),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cacheSize = 0;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.logout)));
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
