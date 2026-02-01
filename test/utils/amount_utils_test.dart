import 'package:test/test.dart';
import 'package:znn_sdk_dart/src/utils/amount.dart';

void main() {
  group('AmountUtils.addDecimals', () {
    test('matches documented examples', () {
      expect(AmountUtils.addDecimals(BigInt.from(1234500), 3), '1234.5');
      expect(AmountUtils.addDecimals(BigInt.from(100000), 2), '1000');
    });

    test('does not strip beyond provided decimals (scale floor at 0)', () {
      // number ends with more zeros than decimals -> should strip only until scale==0
      expect(AmountUtils.addDecimals(BigInt.from(1000), 2), '10');
      expect(AmountUtils.addDecimals(BigInt.from(1000), 0), '1000');
    });

    test(
      'preserves significant digits while stripping trailing fractional zeros',
      () {
        // 1200 with 3 decimals = 1.200 -> strip -> 1.2
        expect(AmountUtils.addDecimals(BigInt.from(1200), 3), '1.2');

        // 123400 with 4 decimals = 12.3400 -> strip -> 12.34
        expect(AmountUtils.addDecimals(BigInt.from(123400), 4), '12.34');
      },
    );

    test('handles negative numbers', () {
      // -1000 with 2 decimals = -10.00 -> strip -> -10
      expect(AmountUtils.addDecimals(BigInt.from(-1000), 2), '-10');

      // -1200 with 3 decimals = -1.200 -> strip -> -1.2
      expect(AmountUtils.addDecimals(BigInt.from(-1200), 3), '-1.2');
    });

    test('zero stays zero regardless of decimals', () {
      expect(AmountUtils.addDecimals(BigInt.zero, 0), '0');
      expect(AmountUtils.addDecimals(BigInt.zero, 1), '0');
      expect(AmountUtils.addDecimals(BigInt.zero, 18), '0');
    });
  });
}
