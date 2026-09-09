import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/utils/formatters.dart';

void main() {
  test('kg formatter keeps up to three decimal places', () {
    expect(kg(1), '1 kg');
    expect(kg(1.2), '1,2 kg');
    expect(kg(1.234), '1,234 kg');
    expect(kg(1.2345), '1,234 kg');
  });
}
