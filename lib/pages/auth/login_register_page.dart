import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validator_util.dart';
import '../../providers/profile_provider.dart';
import '../main/main_page.dart';

class LoginRegisterPage extends StatefulWidget {
  final bool fromOnboarding;

  const LoginRegisterPage({super.key, this.fromOnboarding = false});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();
  final _registerCodeController = TextEditingController();

  final _loginPhoneFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _registerPhoneFocus = FocusNode();
  final _registerPasswordFocus = FocusNode();
  final _registerConfirmFocus = FocusNode();
  final _registerCodeFocus = FocusNode();

  String? _loginPhoneError;
  String? _loginPasswordError;
  String? _registerPhoneError;
  String? _registerPasswordError;
  String? _registerConfirmError;
  String? _registerCodeError;

  bool _loginPasswordVisible = false;
  bool _registerPasswordVisible = false;
  bool _registerConfirmVisible = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loginPhoneFocus.addListener(() {
      if (!_loginPhoneFocus.hasFocus) _validateLoginPhoneOnBlur();
    });
    _loginPasswordFocus.addListener(() {
      if (!_loginPasswordFocus.hasFocus) _validateLoginPasswordOnBlur();
    });
    _registerPhoneFocus.addListener(() {
      if (!_registerPhoneFocus.hasFocus) _validateRegisterPhoneOnBlur();
    });
    _registerPasswordFocus.addListener(() {
      if (!_registerPasswordFocus.hasFocus) _validateRegisterPasswordOnBlur();
    });
    _registerConfirmFocus.addListener(() {
      if (!_registerConfirmFocus.hasFocus) _validateRegisterConfirmOnBlur();
    });
    _registerCodeFocus.addListener(() {
      if (!_registerCodeFocus.hasFocus) _validateRegisterCodeOnBlur();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    _registerCodeController.dispose();
    _loginPhoneFocus.dispose();
    _loginPasswordFocus.dispose();
    _registerPhoneFocus.dispose();
    _registerPasswordFocus.dispose();
    _registerConfirmFocus.dispose();
    _registerCodeFocus.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  void _handleClose() {
    if (widget.fromOnboarding) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _sendVerifyCode() async {
    final phone = _registerPhoneController.text.trim();
    final error = ValidatorUtil.validatePhone(phone);
    if (error != null) {
      setState(() => _registerPhoneError = error);
      return;
    }

    setState(() {
      _registerPhoneError = null;
    });

    _registerCodeController.text = '123456';
    _countdownSeconds = 60;
    _startCountdown();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('验证码已发送: 123456')));
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds <= 1) {
        timer.cancel();
        setState(() => _countdownSeconds = 0);
      } else {
        setState(() => _countdownSeconds--);
      }
    });
  }

  String? _validatePhoneValue(String phone) =>
      ValidatorUtil.validatePhone(phone);

  String? _validatePasswordValue(String password) =>
      ValidatorUtil.validatePassword(password);

  void _validateLoginPhone() {
    setState(
      () => _loginPhoneError = _validatePhoneValue(_loginPhoneController.text),
    );
  }

  void _validateLoginPhoneOnBlur() {
    if (_loginPhoneController.text.isEmpty) return;
    _validateLoginPhone();
  }

  void _validateLoginPassword() {
    setState(
      () => _loginPasswordError = _validatePasswordValue(
        _loginPasswordController.text,
      ),
    );
  }

  void _validateLoginPasswordOnBlur() {
    if (_loginPasswordController.text.isEmpty) return;
    _validateLoginPassword();
  }

  void _validateRegisterPhone() {
    setState(
      () => _registerPhoneError = _validatePhoneValue(
        _registerPhoneController.text,
      ),
    );
  }

  void _validateRegisterPhoneOnBlur() {
    if (_registerPhoneController.text.isEmpty) return;
    _validateRegisterPhone();
  }

  void _validateRegisterPassword() {
    setState(
      () => _registerPasswordError = _validatePasswordValue(
        _registerPasswordController.text,
      ),
    );
  }

  void _validateRegisterPasswordOnBlur() {
    if (_registerPasswordController.text.isEmpty) return;
    _validateRegisterPassword();
  }

  void _validateRegisterConfirm() {
    final confirm = _registerConfirmController.text;
    final password = _registerPasswordController.text;
    if (confirm.isEmpty) {
      setState(() => _registerConfirmError = '请再次输入密码');
    } else if (confirm != password) {
      setState(() => _registerConfirmError = '两次密码输入不一致');
    } else {
      setState(() => _registerConfirmError = null);
    }
  }

  void _validateRegisterConfirmOnBlur() {
    if (_registerConfirmController.text.isEmpty) return;
    _validateRegisterConfirm();
  }

  void _validateRegisterCode() {
    setState(() {
      _registerCodeError = _registerCodeController.text.isEmpty
          ? '请输入验证码'
          : null;
    });
  }

  void _validateRegisterCodeOnBlur() {
    if (_registerCodeController.text.isEmpty) return;
    _validateRegisterCode();
  }

  bool _validateAllLogin() {
    _validateLoginPhone();
    _validateLoginPassword();
    return _loginPhoneError == null && _loginPasswordError == null;
  }

  bool _validateAllRegister() {
    _validateRegisterPhone();
    _validateRegisterPassword();
    _validateRegisterConfirm();
    _validateRegisterCode();
    return _registerPhoneError == null &&
        _registerPasswordError == null &&
        _registerConfirmError == null &&
        _registerCodeError == null;
  }

  Future<void> _handleLogin() async {
    _unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_validateAllLogin()) return;

    await context.read<ProfileProvider>().login(
      _loginPhoneController.text.trim(),
      _loginPasswordController.text,
    );
    if (!mounted) return;

    if (widget.fromOnboarding) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleRegister() async {
    _unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_validateAllRegister()) return;

    await context.read<ProfileProvider>().register(
      _registerPhoneController.text.trim(),
      _registerPasswordController.text,
    );
    if (!mounted) return;

    if (widget.fromOnboarding) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  InputDecoration _buildDecoration({
    required String label,
    required IconData prefixIcon,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: errorText != null ? AppColors.error : null),
      prefixIcon: Icon(
        prefixIcon,
        color: errorText != null ? AppColors.error : null,
      ),
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorStyle: const TextStyle(fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? AppColors.error : const Color(0xFFD0D0D0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? AppColors.error : const Color(0xFFD0D0D0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? AppColors.error : AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(widget.fromOnboarding ? Icons.close : Icons.arrow_back),
          onPressed: _handleClose,
        ),
        title: const Text(''),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '登录'),
            Tab(text: '注册'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: _unfocus,
        child: TabBarView(
          controller: _tabController,
          children: [_buildLoginForm(), _buildRegisterForm()],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            '欢迎回来',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '登录您的账户继续购物',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _loginPhoneController,
            focusNode: _loginPhoneFocus,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_loginPhoneError != null) {
                setState(() => _loginPhoneError = null);
              }
            },
            decoration: _buildDecoration(
              label: '手机号',
              prefixIcon: Icons.phone_android,
              errorText: _loginPhoneError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginPasswordController,
            focusNode: _loginPasswordFocus,
            obscureText: !_loginPasswordVisible,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onChanged: (_) {
              if (_loginPasswordError != null) {
                setState(() => _loginPasswordError = null);
              }
            },
            decoration: _buildDecoration(
              label: '密码',
              prefixIcon: Icons.lock_outline,
              errorText: _loginPasswordError,
              suffixIcon: IconButton(
                icon: Icon(
                  _loginPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => setState(
                  () => _loginPasswordVisible = !_loginPasswordVisible,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('登录', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            '创建账户',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '注册后享受更多会员权益',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _registerPhoneController,
            focusNode: _registerPhoneFocus,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_registerPhoneError != null) {
                setState(() => _registerPhoneError = null);
              }
            },
            decoration: _buildDecoration(
              label: '手机号',
              prefixIcon: Icons.phone_android,
              errorText: _registerPhoneError,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _registerCodeController,
                  focusNode: _registerCodeFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    if (_registerCodeError != null) {
                      setState(() => _registerCodeError = null);
                    }
                  },
                  decoration: _buildDecoration(
                    label: '验证码',
                    prefixIcon: Icons.sms,
                    errorText: _registerCodeError,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _countdownSeconds > 0 ? null : _sendVerifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _countdownSeconds > 0
                        ? AppColors.secondary.withValues(alpha: 0.5)
                        : AppColors.secondary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _countdownSeconds > 0
                        ? '${_countdownSeconds}s后重新获取'
                        : '获取验证码',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _registerPasswordController,
            focusNode: _registerPasswordFocus,
            obscureText: !_registerPasswordVisible,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onChanged: (_) {
              if (_registerPasswordError != null) {
                setState(() => _registerPasswordError = null);
              }
            },
            decoration: _buildDecoration(
              label: '密码',
              prefixIcon: Icons.lock_outline,
              errorText: _registerPasswordError,
              suffixIcon: IconButton(
                icon: Icon(
                  _registerPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => setState(
                  () => _registerPasswordVisible = !_registerPasswordVisible,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _registerConfirmController,
            focusNode: _registerConfirmFocus,
            obscureText: !_registerConfirmVisible,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onChanged: (_) {
              if (_registerConfirmError != null) {
                setState(() => _registerConfirmError = null);
              }
            },
            decoration: _buildDecoration(
              label: '确认密码',
              prefixIcon: Icons.lock_outline,
              errorText: _registerConfirmError,
              suffixIcon: IconButton(
                icon: Icon(
                  _registerConfirmVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => setState(
                  () => _registerConfirmVisible = !_registerConfirmVisible,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('注册', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
