class ValidatorUtil {
  ValidatorUtil._();

  static final RegExp _phoneRegex = RegExp(r'^1[3-9]\d{9}$');

  static bool isValidPhone(String phone) => _phoneRegex.hasMatch(phone);

  static String? validatePhone(String phone) {
    if (phone.isEmpty) return '请输入手机号';
    if (!isValidPhone(phone)) return '请输入正确的手机号格式';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return '请输入密码';
    if (password.length < 8) return '密码长度不能少于8位';
    if (password.contains(' ')) return '密码不能包含空格';
    if (!password.contains(RegExp(r'[a-z]'))) return '密码必须包含小写字母';
    if (!password.contains(RegExp(r'[A-Z]'))) return '密码必须包含大写字母';
    if (!password.contains(RegExp(r'[0-9]'))) return '密码必须包含数字';
    if (!password.contains(RegExp(r'[^a-zA-Z0-9\s]'))) {
      return '密码必须包含特殊字符';
    }
    return null;
  }
}
