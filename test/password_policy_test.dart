import 'package:flutter_test/flutter_test.dart';
import 'package:petpaws/utils/password_policy.dart';

void main() {
  group('PasswordPolicy', () {
    test('accepts a password that meets every rule', () {
      expect(PasswordPolicy.firstError('Str0ng!Pass'), isNull);
      expect(PasswordPolicy.strength('Str0ng!Pass'), 1.0);
    });

    test('reports the first failing rule, starting with length', () {
      expect(PasswordPolicy.firstError('Ab1!'), contains('8'));
    });

    test('requires upper case, lower case, a digit and a symbol', () {
      final rules = PasswordPolicy.check('alllowercase');
      final failed = rules.where((r) => !r.passed).length;
      expect(failed, 3); // no upper case, no digit, no symbol
    });

    test('rejects spaces', () {
      expect(PasswordPolicy.firstError('Str0ng! Pass'), isNotNull);
    });

    test('rejects a password containing the username or email name', () {
      expect(
        PasswordPolicy.firstError('Somchai#2024', username: 'somchai'),
        isNotNull,
      );
      expect(
        PasswordPolicy.firstError('Nidnoi#2024', email: 'nidnoi@example.com'),
        isNotNull,
      );
    });

    test('ignores usernames shorter than 3 characters', () {
      expect(PasswordPolicy.firstError('Ab#12345xyz', username: 'ab'), isNull);
    });

    test('strength is 0 for an empty password', () {
      expect(PasswordPolicy.strength(''), 0);
    });
  });
}
