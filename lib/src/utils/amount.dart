import 'package:big_decimal/big_decimal.dart';

class AmountUtils {
  // This methods removes decimals and returns a BigInt
  static BigInt extractDecimals(String amount, int decimals) {
    if (!amount.contains('.')) {
      return BigInt.parse(amount + ''.padRight(decimals, '0'));
    }
    List<String> parts = amount.split('.');

    return BigInt.parse(parts[0] +
        (parts[1].length > decimals
            ? parts[1].substring(0, decimals)
            : parts[1].padRight(decimals, '0')));
  }

  static String addDecimals(BigInt number, int decimals) {
    return BigDecimal.createAndStripZerosForScale(number, decimals, 0)
        .toPlainString();
  }
}
