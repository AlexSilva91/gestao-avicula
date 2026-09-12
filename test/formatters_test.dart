import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/utils/formatters.dart';

void main() {
  test('kg formatter keeps up to three decimal places', () {
    expect(kg(1), '1 kg');
    expect(kg(1.2), '1,2 kg');
    expect(kg(1.234), '1,234 kg');
    expect(kg(1.2345), '1,234 kg');
    expect(kg(-0.0), '0 kg');
    expect(kg(-0.0001), '0 kg');
    expect(kg(-2), '0 kg');
  });

  test('decimal parser accepts grams and kilograms', () {
    expect(parseDecimal('61,32'), 61.32);
    expect(parseDecimal('61,32 kg'), 61.32);
    expect(parseDecimal('540 g'), .54);
    expect(parseDecimal('540 gramas'), .54);
  });
}
