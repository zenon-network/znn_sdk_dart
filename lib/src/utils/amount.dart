import 'package:big_decimal/big_decimal.dart';

class AmountUtils {
  // This methods removes decimals and returns a BigInt
  static BigInt extractDecimals(num num, int decimals) =>
      BigInt.parse(num.toStringAsFixed(decimals).replaceAll('.', ''));

  static String addDecimals(BigInt number, int decimals) {
    return BigDecimal.createAndStripZerosForScale(number, decimals, 0)
        .toPlainString();
  }
}
