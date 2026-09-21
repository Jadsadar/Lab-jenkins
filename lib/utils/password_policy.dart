/// กฎความแข็งแรงของรหัสผ่าน แยกไว้ที่เดียวเพื่อให้หน้าอื่น เช่น หน้าเปลี่ยนรหัสผ่าน ใช้ซ้ำได้
class PasswordRule {
  const PasswordRule(this.label, this.passed);

  final String label;
  final bool passed;
}

class PasswordPolicy {
  PasswordPolicy._();

  static const int minLength = 8;

  /// ตรวจรหัสผ่านทีละข้อ ใช้ทั้งตอนกดสมัครและตอนแสดงรายการเงื่อนไขใต้ช่องกรอก
  static List<PasswordRule> check(
    String password, {
    String username = '',
    String email = '',
  }) {
    final lower = password.toLowerCase();
    final user = username.trim().toLowerCase();
    final emailName = email.split('@').first.trim().toLowerCase();
    final hasIdentity = (user.length >= 3 && lower.contains(user)) ||
        (emailName.length >= 3 && lower.contains(emailName));

    return [
      PasswordRule(
          'ยาวอย่างน้อย $minLength ตัวอักษร', password.length >= minLength),
      PasswordRule('มีตัวพิมพ์ใหญ่ A-Z อย่างน้อย 1 ตัว',
          RegExp(r'[A-Z]').hasMatch(password)),
      PasswordRule('มีตัวพิมพ์เล็ก a-z อย่างน้อย 1 ตัว',
          RegExp(r'[a-z]').hasMatch(password)),
      PasswordRule(
          'มีตัวเลข 0-9 อย่างน้อย 1 ตัว', RegExp(r'[0-9]').hasMatch(password)),
      PasswordRule('มีอักขระพิเศษ เช่น ! @ # \$ % อย่างน้อย 1 ตัว',
          RegExp(r'[^A-Za-z0-9]').hasMatch(password)),
      PasswordRule('ไม่มีช่องว่าง', !password.contains(' ')),
      PasswordRule('ไม่มีชื่อผู้ใช้หรือชื่ออีเมลอยู่ข้างใน', !hasIdentity),
    ];
  }

  /// คืนข้อความบอกเงื่อนไขข้อแรกที่ยังไม่ผ่าน ถ้าผ่านครบคืน null
  static String? firstError(
    String password, {
    String username = '',
    String email = '',
  }) {
    for (final rule in check(password, username: username, email: email)) {
      if (!rule.passed) return 'รหัสผ่านต้อง${rule.label}';
    }
    return null;
  }

  /// สัดส่วนเงื่อนไขที่ผ่าน 0.0 ถึง 1.0 เอาไว้ทำแถบวัดความแข็งแรง
  static double strength(
    String password, {
    String username = '',
    String email = '',
  }) {
    if (password.isEmpty) return 0;
    final rules = check(password, username: username, email: email);
    return rules.where((r) => r.passed).length / rules.length;
  }
}
