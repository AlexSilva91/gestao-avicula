import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/utils/password_hasher.dart';

void main() {
  test('password hash never stores the raw password and can be verified', () {
    const password = 'Senha#Segura2026';
    final hash = PasswordHasher.hash(password);
    expect(hash, isNot(contains(password)));
    expect(PasswordHasher.verify(password, hash), isTrue);
    expect(PasswordHasher.verify('invalida', hash), isFalse);
  });
}
